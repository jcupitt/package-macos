#!/bin/bash

if [ "$#" -lt 2 ]; then
    echo "copy a set of exes and all required files to a prefix"
    echo "usage: $0 prefix exe1 ... "
    exit 1
fi

prefix="$1"
shift 
exes="$*"

echo build to prefix = $prefix
echo executables = $exes

brew_prefix=$(brew --prefix)
mkdir -p $prefix/lib
mkdir -p $prefix/bin

get_libs()
{
  local libs
  local lib
  local found_libs
  local i

  # start from line 2 of output, it's the path to the exe
  libs=$(otool -L $1 | awk '{print $1}' | tail -n +2)

  # exclude libs from /usr, /System 
  libs=$(echo $libs | sed 's/ /\n/g' | grep -v /usr | grep -v /System)

  # libs will include eg. @rpath/xxx.dylib and Cellar/lib ... drop all
  # dirnames and make sure libs are within brew_prefix/lib
  found_libs=
  for i in $libs; do
    lib=$(basename $i)
    if [ -f $brew_prefix/lib/$lib ]; then
      found_libs="$found_libs $lib"
    fi
  done

  echo $found_libs
}

for i in $exes; do
  echo "copying $i ..."
  exe=$(which $i)
  libs=$(get_libs $exe)
  all_libs="$all_libs $libs"
  cp $exe $prefix/bin
done

# repeatedly expand each lib until we get no more deps
echo "expanding dependencies ..."
n=1
while true; do
  echo iteration $n
  n=$((n + 1))
  new_libs=
  for lib in $all_libs; do
    sub_libs=$(get_libs $brew_prefix/lib/$lib)
    new_libs="$new_libs $lib $sub_libs"
  done

  # sort, remove duplicates, loop if our set of libs has changed
  new_libs=$(echo $new_libs | sed 's/ /\n/g' | sort | uniq)

  if [ "$new_libs" = "$all_libs" ]; then
      break
  fi

  all_libs="$new_libs"
done 

echo "copying libraries ..."
for i in $all_libs; do
  cp $brew_prefix/lib/$i $prefix/lib
done

# some libs shadow system libs and must be copied by hand
cp $brew_prefix/opt/libxml2/lib/libxml2.* $prefix/lib
cp $brew_prefix/opt/libarchive/lib/libarchive.* $prefix/lib
cp $brew_prefix/opt/mozjpeg/lib/libjpeg.* $prefix/lib
cp $brew_prefix/opt/lz4/lib/liblz4.* $prefix/lib
cp $brew_prefix/opt/libb2/lib/libb2.* $prefix/lib
cp $brew_prefix/opt/libomp/lib/libomp.dylib $prefix/lib

echo "copying support files ..."
for i in $exes; do
  if [ -d $brew_prefix/share/$i ]; then
    mkdir -p $prefix/share
    cp -r $brew_prefix/share/$i $prefix/share
  fi
done

# the glib schema
mkdir -p $prefix/share/glib-2.0
cp -r $brew_prefix/share/glib-2.0/schemas $prefix/share/glib-2.0


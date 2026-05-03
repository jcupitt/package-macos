#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "package an app from a build"
    echo "usage: $0 prefix app-name"
    exit 1
fi

prefix=$(realpath $1)
app="$2"

version=$($prefix/bin/$app --version | head -1 | sed 's/nip4-//')
long_version="$app-$version"
year=`date +%Y`
copyright="© $year libvips.org, London"

function escape () {
  # escape slashes
  tmp=${1//\//\\\/}

  # escape colon
  tmp=${tmp//\:/\\:}

  # escape tilda
  tmp=${tmp//\~/\\~}

  # escape percent
  tmp=${tmp//\%/\\%}

  echo -n $tmp
}

function new () {
	echo > tmp/script.sed
}

function sub () {
  echo -n s/ >> tmp/script.sed
	escape "$1" >> tmp/script.sed
	echo -n / >> tmp/script.sed
	escape "$2" >> tmp/script.sed
	echo /g >> tmp/script.sed
}

function patch () {
	echo patching "$1"

	sed -f tmp/script.sed -i "" "$1"
}

mkdir -p tmp

echo "creating $app.app ..."
mkdir -p $app.app/Contents
mkdir -p $app.app/Contents/Resources
mkdir -p $app.app/Contents/MacOS

cp $app/Info.plist.in $app.app/Contents/Info.plist
new
sub @LONG_VERSION@ "$long_version"
sub @VERSION@ "$version"
sub @COPYRIGHT@ "$copyright"
patch $app.app/Contents/Info.plist

cp $app/PkgInfo $app.app/Contents

cp $app/128.icns $app.app/Contents/Resources
cp -r $prefix/* $app.app/Contents/Resources

cp $app/$app $app.app/Contents/MacOS

hdiutil create -srcfolder $app.app -o $app.app.dmg


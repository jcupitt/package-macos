#!/bin/bash

if [ "$#" -lt 2 ]; then
    echo "run an exe from the prefix"
    echo "usage: $0 prefix exe ... "
    exit 1
fi

prefix=$(realpath $1)
shift 
exe="$1"
shift 
args="$*"

unset VIPSHOME
export DYLD_LIBRARY_PATH=$prefix/lib
export GSETTINGS_SCHEMA_DIR=$prefix/share/glib-2.0/schemas

$prefix/bin/$exe $args


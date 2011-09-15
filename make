#!/bin/bash
mkdir -p bin .libs

if [[ ! -e $PREFIX ]]; then
    export PREFIX=$PWD/prefix
    mkdir -p $PREFIX
fi

if [[ ! -e $LIBDIR ]]; then
    export LIBDIR=$PREFIX/lib
    mkdir -p $LIBDIR
fi

OC_DIST=../oc
OOC_FLAGS="-v -g -nolines +-rdynamic"

mkdir -p $OC_DIST/plugins
rock $OOC_FLAGS -packagefilter=frontend/magog/ -dynamiclib=$OC_DIST/plugins/magog_frontend.so -sourcepath=source frontend/magog/Frontend

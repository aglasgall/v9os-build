#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=zlib
VER=1.2.8
PKG=library/zlib
SUMMARY="$PROG - A massively spiffy yet delicately unobtrusive compression library"
DESC="$SUMMARY"

DEPENDS_IPS="system/library/gcc-4-runtime"
#BUILD_DEPENDS_IPS="$DEPENDS_IPS developer/sunstudio12.1"


CFLAGS="-DNO_VIZ"

CONFIGURE_OPTS_32="--prefix=$PREFIX
    --includedir=$PREFIX/include
    --libdir=$PREFIX/lib"

CONFIGURE_OPTS_64="--prefix=$PREFIX
    --includedir=$PREFIX/include
    --libdir=$PREFIX/lib/$ISAPART64"

install_license(){
    # This is fun, take from the zlib.h header
    /bin/awk '/Copyright/,/\*\//{if($1 != "*/"){print}}' \
        $TMPDIR/$BUILDDIR/zlib.h > $DESTDIR/license
}

make_prog32() {
    pushd $TMPDIR/$BUILDDIR > /dev/null
    logcmd gmake LDSHARED="gcc -shared -nostdlib" || logerr "gmake failed"
    popd > /dev/null
}

make_prog64() {
    pushd $TMPDIR/$BUILDDIR > /dev/null
    logcmd gmake LDSHARED="gcc -shared -nostdlib" || logerr "gmake failed"
    popd > /dev/null
}

# Relocate the libs to /lib, to match upstream
move_libs() {
    logcmd mkdir -p $DESTDIR/lib/sparcv9
    logcmd ln -s $DESTDIR/lib/64 sparcv9
    logcmd mv $DESTDIR/usr/lib/lib* $DESTDIR/lib || \
        logerr "failed to move libs (32-bit)"
    logcmd mv $DESTDIR/usr/lib/sparcv9/lib* $DESTDIR/lib/sparcv9 || \
        logerr "failed to move libs (64-bit)"
    pushd $DESTDIR/usr/lib >/dev/null
    logcmd ln -s ../../lib/libz.so.1.2.8 libz.so
    logcmd ln -s ../../lib/libz.so.1.2.8 libz.so.1
    logcmd ln -s ../../lib/libz.so.1.2.8 libz.so.1.2.8
    popd >/dev/null
    pushd $DESTDIR/usr/lib/sparcv9 >/dev/null
    logcmd ln -s ../../../lib/64/libz.so.1.2.8 libz.so
    logcmd ln -s ../../../lib/64/libz.so.1.2.8 libz.so.1
    logcmd ln -s ../../../lib/64/libz.so.1.2.8 libz.so.1.2.8
    popd>/dev/null
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_lintlibs z /usr/lib /usr/include
make_isa_stub
install_license
move_libs
make_package
#clean_up

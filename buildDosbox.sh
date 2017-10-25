#!/bin/sh
set -e

BUILD_DIR=`mktemp -d dosbox-build.XXX`

cd $BUILD_DIR
mkdir installed

INSTALL_DIR=`pwd`/installed
PATH=$PATH:$INSTALL_DIR/bin

# Autoconf
curl -LOs http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz
tar xzpf autoconf-2.69.tar.gz
cd autoconf-2.69
./configure --prefix=$INSTALL_DIR
make
make install
cd ..
rm -rf autoconf-2.69 autoconf-2.69.tar.gz

# Automake
curl -LOs http://ftp.gnu.org/gnu/automake/automake-1.15.tar.gz
tar xzpf automake-1.15.tar.gz
cd automake-1.15
./configure --prefix=$INSTALL_DIR
make
make install
cd ..
rm -rf automake-1.15 automake-1.15.tar.gz

# SDL
curl -LOs https://www.libsdl.org/release/SDL-1.2.15.tar.gz
tar xzpf SDL-1.2.15.tar.gz
cd SDL-1.2.15
./configure --prefix=$INSTALL_DIR --enable-static --disable-shared --disable-video-x11
sed -i "" "/CGDirectPaletteRef palette;/d" src/video/quartz/SDL_QuartzVideo.h
make
make install
cd ..
rm -rf SDL-1.2.15 SDL-1.2.15.tar.gz

# Dosbox
svn checkout svn://svn.code.sf.net/p/dosbox/code-0/dosbox/trunk dosbox
cd dosbox
DOSBOXVERSION=$(svn log | head -2 | awk '/^r/ { print $1 }')
./autogen.sh
./configure --with-sdl-prefix=INSTALL_DIR
make
mv src/dosbox ../dosbox-$DOSBOXVERSION

cd ..
rm -rf installed dosbox

#!/bin/sh
AUTOCONF_VERSION=2.69
AUTOMAKE_VERSION=1.15
SDL_VERSION=1.2.15
DOSBOX_DMG_VERSION=0.74-3-3

set -e

BUILD_DIR=`pwd`/`mktemp -d dosbox-build.XXX`
COPYRIGHT_TEXT="Copyright 2002-`date +'%Y'` The DOSBox Team, compiled by $USER"

cd $BUILD_DIR
mkdir dependencies

DEPENDENCIES_DIR=$BUILD_DIR/dependencies
PATH=$PATH:$DEPENDENCIES_DIR/bin

# Autoconf
curl -LOs http://ftp.gnu.org/gnu/autoconf/autoconf-$AUTOCONF_VERSION.tar.gz
tar xzpf autoconf-$AUTOCONF_VERSION.tar.gz
cd autoconf-$AUTOCONF_VERSION
./configure --prefix=$DEPENDENCIES_DIR
make
make install
cd $BUILD_DIR

# Automake
curl -LOs http://ftp.gnu.org/gnu/automake/automake-$AUTOMAKE_VERSION.tar.gz
tar xzpf automake-$AUTOMAKE_VERSION.tar.gz
cd automake-$AUTOMAKE_VERSION
./configure --prefix=$DEPENDENCIES_DIR
make
make install
cd $BUILD_DIR

# SDL
curl -LOs https://www.libsdl.org/release/SDL-$SDL_VERSION.tar.gz
tar xzpf SDL-$SDL_VERSION.tar.gz
cd SDL-$SDL_VERSION
eval ./configure --prefix=$DEPENDENCIES_DIR --enable-static --disable-shared --disable-video-x11
sed -i "" "/CGDirectPaletteRef palette;/d" src/video/quartz/SDL_QuartzVideo.h
make
make install
cd $BUILD_DIR

# Dosbox
svn checkout svn://svn.code.sf.net/p/dosbox/code-0/dosbox/trunk dosbox-src
cd dosbox-src
DOSBOX_VERSION=$(svn log | head -2 | awk '/^r/ { print $1 }')
./autogen.sh
eval ./configure --with-sdl-prefix=DEPENDENCIES_DIR $OPTIONS
make
mv src/dosbox $BUILD_DIR/dosbox
cd $BUILD_DIR

# Create App
curl -Ls -o DOSBox-$DOSBOX_DMG_VERSION.dmg "https://sourceforge.net/projects/dosbox/files/dosbox/0.74-3/DOSBox-$DOSBOX_DMG_VERSION.dmg/download"
hdiutil attach DOSBox-$DOSBOX_DMG_VERSION.dmg -quiet
cp -R /Volumes/DOSBox\ $DOSBOX_DMG_VERSION/DOSBox.app .
hdiutil detach /Volumes/DOSBox\ $DOSBOX_DMG_VERSION/ -quiet
mv dosbox DOSBox.app/Contents/MacOS/DOSBox

/usr/libexec/PlistBuddy -c "Set :CFBundleGetInfoString ${DOSBOX_VERSION}, $COPYRIGHT_TEXT" DOSBox.app/Contents/Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $DOSBOX_VERSION" DOSBox.app/Contents/Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $DOSBOX_VERSION" DOSBox.app/Contents/Info.plist
/usr/libexec/PlistBuddy -c "Set :NSHumanReadableCopyright $COPYRIGHT_TEXT" DOSBox.app/Contents/Info.plist

# Cleanup
rm -rf autoconf-$AUTOCONF_VERSION autoconf-$AUTOCONF_VERSION.tar.gz
rm -rf automake-$AUTOMAKE_VERSION automake-$AUTOMAKE_VERSION.tar.gz
rm -rf SDL-$SDL_VERSION SDL-$SDL_VERSION.tar.gz
rm -rf dependencies dosbox-src
rm DOSBox-$DOSBOX_DMG_VERSION.dmg

echo "Successfully built DOSBox from SVN revision $DOSBOX_VERSION $BUILD_DIR/DOSBox.app"

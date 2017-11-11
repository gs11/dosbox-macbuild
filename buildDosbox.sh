#!/bin/sh
set -e

BUILD_DIR=`pwd`/`mktemp -d dosbox-build.XXX`
COPYRIGHT_TEXT="Copyright 2002-`date +'%Y'` The DOSBox Team, compiled by $USER"

if [ "$1" = "32" ]
then
	OPTIONS='--build=i386-apple-darwin CFLAGS="-arch i386 -O2 -pipe" CXXFLAGS="-arch i386 -O2 -pipe" LDFLAGS="-arch i386"'
elif [ "$1" = "64" ]
then
	OPTIONS=""
else
	echo "Please specify the target architecture as either 32 or 64"
	echo "Usage: buildDosbox.sh <architecture>"
	exit
fi

cd $BUILD_DIR
mkdir dependencies

DEPENDENCIES_DIR=$BUILD_DIR/dependencies
PATH=$PATH:$DEPENDENCIES_DIR/bin

# Autoconf
curl -LOs http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz
tar xzpf autoconf-2.69.tar.gz
cd autoconf-2.69
./configure --prefix=$DEPENDENCIES_DIR
make
make install
cd $BUILD_DIR

# Automake
curl -LOs http://ftp.gnu.org/gnu/automake/automake-1.15.tar.gz
tar xzpf automake-1.15.tar.gz
cd automake-1.15
./configure --prefix=$DEPENDENCIES_DIR
make
make install
cd $BUILD_DIR

# SDL
curl -LOs https://www.libsdl.org/release/SDL-1.2.15.tar.gz
tar xzpf SDL-1.2.15.tar.gz
cd SDL-1.2.15
eval ./configure --prefix=$DEPENDENCIES_DIR --enable-static --disable-shared --disable-video-x11 $OPTIONS
sed -i "" "/CGDirectPaletteRef palette;/d" src/video/quartz/SDL_QuartzVideo.h
make
make install
cd $BUILD_DIR

# Dosbox
svn checkout svn://svn.code.sf.net/p/dosbox/code-0/dosbox/trunk dosbox-src
cd dosbox-src
DOSBOXVERSION=$(svn log | head -2 | awk '/^r/ { print $1 }')
./autogen.sh
eval ./configure --with-sdl-prefix=DEPENDENCIES_DIR $OPTIONS
make
mv src/dosbox $BUILD_DIR/dosbox
cd $BUILD_DIR

# Create App
curl -Ls -o DOSBox-0.74-1.dmg https://sourceforge.net/projects/dosbox/files/dosbox/0.74/DOSBox-0.74-1_Universal.dmg/download
hdiutil attach DOSBox-0.74-1.dmg -quiet
cp -R /Volumes/DOSBox\ 0.74-1/DOSBox.app .
hdiutil detach /Volumes/DOSBox\ 0.74-1/ -quiet
mv dosbox DOSBox.app/Contents/MacOS/DOSBox

/usr/libexec/PlistBuddy -c "Set :CFBundleGetInfoString ${DOSBOXVERSION}, $COPYRIGHT_TEXT" DOSBox.app/Contents/Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $DOSBOXVERSION" DOSBox.app/Contents/Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $DOSBOXVERSION" DOSBox.app/Contents/Info.plist
/usr/libexec/PlistBuddy -c "Set :NSHumanReadableCopyright $COPYRIGHT_TEXT" DOSBox.app/Contents/Info.plist

# Cleanup
rm -rf autoconf-2.69 autoconf-2.69.tar.gz
rm -rf automake-1.15 automake-1.15.tar.gz
rm -rf SDL-1.2.15 SDL-1.2.15.tar.gz
rm -rf dependencies dosbox-src
rm DOSBox-0.74-1.dmg

echo "Successfully built DOSBox from SVN revision $DOSBOXVERSION $BUILD_DIR/DOSBox.app"

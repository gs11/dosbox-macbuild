# dosbox-macbuild
Script to build the DOSBox App from SVN latest including build dependencies.

Description
-----------
Downloads & builds
- autoconf
- automake
- SDL
- DOSBox

All dependencies are sandboxed to the build folder

Credits to Hexeract for the build instructions https://hexeract.wordpress.com/2016/09/10/building-dosbox-as-x64-binary-for-macos-sierra/

Usage
-----
`buildDosbox.sh <architecture>`

Architecture can either be 32 (32-bit) or 64 (64-bit) (_Please note that the 64-bit version is currently much slower than the 32-bit version_)

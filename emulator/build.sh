set -e
sh build/prebuild.sh
make -f build/makefile.linux
./eris bin/kernel.prg bin/basic.prg bin/basiccode.prg



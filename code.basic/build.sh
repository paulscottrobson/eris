set -e
#
#		Convert BASIC to programs
#
python ../basic/scripts/makeprogram.py pong.bas storage/pong.prg
#
#		Copy one file (current working) as autoexec.prg
#
cp storage/pong.prg storage/autoexec.prg
#
#		Copy current binary
#
cp ../emulator/eris .
#
#		Build graphics and copy to storage
#
pushd graphics
python ../../basic/scripts/gfxconv.py
cp *.spr ../storage
popd
#
#		Run emulator
#
./eris
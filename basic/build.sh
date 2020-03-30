rm generated/token_test.inc >/dev/null
rm scripts/prg/autoexec.prg >/dev/null
rm ../emulator/storage/autoexec.prg >/dev/null
set -e

pushd scripts 
python tables.py
# python gentokentest.py
# python systests.py ComplexVariable
#
#python makeprogram.py source/sed.bas prg/autoexec.prg
python makeprogram.py source/sed.bas prg/sed
python makeprogram.py source/test.bas prg/autoexec.prg
python makeprogram.py source/sprites.bas prg/sprites.prg

cp prg/test.prg ../../emulator/bin 
cp prg/*.* ../../emulator/storage -v 
popd

pushd messages 
python msgconv.py
popd 

cp ../kernel/bin/a.lbl generated/kernel.labels 
#
python ../assembler/easm.zip
cp bin/a.prg ../emulator/bin/basic.prg 
cp bin/_binary.h ../emulator/bin/_basic.h 

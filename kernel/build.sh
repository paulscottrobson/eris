set -e
pushd fonts
python font5x7.py
popd
pushd keyboard-map 
python keyconv.py
popd 
python ../assembler/easm.zip 
cp bin/a.out ../emulator/bin/kernel.rom 
cp bin/a.prg ../emulator/bin/kernel.prg 
cp bin/_binary.h ../emulator/bin/_kernel.h 

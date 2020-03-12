set -e
pushd fonts >/dev/null
python font.py
popd >/dev/null
pushd keyboard-map >/dev/null
python keyconv.py
popd >/dev/null
python ../assembler/easm.zip 
cp bin/a.out ../emulator/bin/kernel.rom
cp bin/a.prg ../emulator/bin/kernel.prg
cp bin/_binary.h ../emulator/bin/_kernel.h

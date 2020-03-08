rm easm.zip
set -e
zip -q easm.zip *.py
python easm.zip 
cp bin/a.prg ../emulator/bin/asm.prg 
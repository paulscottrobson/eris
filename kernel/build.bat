@echo off
pushd fonts
python3 font5x7.py
popd
pushd keyboard-map 
python3 keyconv.py
popd 
python3 ..\assembler\easm.zip 
if errorlevel 1 goto exit
copy bin\a.out ..\emulator\bin\kernel.rom >NUL
copy bin\a.prg ..\emulator\bin\kernel.prg >NUL
copy bin\_binary.h ..\emulator\bin\_kernel.h >NUL
:exit 

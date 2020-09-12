@echo off
pushd fonts
python font5x7.py
popd
pushd keyboard-map 
python keyconv.py %1
popd 
python ..\assembler\easm.zip 
if errorlevel 1 goto exit
copy bin\a.out ..\emulator\bin\kernel.rom >NUL
copy bin\a.prg ..\emulator\bin\kernel.prg >NUL
copy bin\_binary.h ..\emulator\bin\_kernel.h >NUL
:exit 

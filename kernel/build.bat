@echo off
pushd fonts
python font.py
popd
pushd keyboard-map 
python keyconv.py
popd 
pushd prompt 
python prompt.py
popd 
python ..\assembler\easm.zip 
if errorlevel 1 goto exit
copy bin\a.out ..\emulator\bin\kernel.rom >NUL
copy bin\a.prg ..\emulator\bin\kernel.prg >NUL
copy bin\_binary.h ..\emulator\bin\_kernel.h >NUL
:exit 

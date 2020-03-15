@echo off
rem pushd ..\assembler >NUL
rem call build.bat
rem popd >NUL
rem
del /Q generated\token_test.inc 2>NUL
pushd scripts >NUL
python tables.py
python program.py
rem python gentokentest.py
rem python systests.py Comparison
copy basiccode.prg ..\..\emulator\bin >NUL
popd
pushd messages >NUL
python msgconv.py
popd messages
copy ..\kernel\bin\a.lbl generated\kernel.labels >NUL
rem
python ..\assembler\easm.zip
if errorlevel 1 goto exit
copy bin\a.prg ..\emulator\bin\basic.prg >NUL
copy bin\_binary.h ..\emulator\bin\_basic.h >NUL
:exit

@echo off
del /Q easm.zip >NUL
zip -q easm.zip *.py
python easm.zip 
if errorlevel 1 goto exit
copy bin\a.prg ..\emulator\bin\asm.prg >NUL
:exit 

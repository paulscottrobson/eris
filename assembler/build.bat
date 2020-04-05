@echo off
del /Q easm.zip >NUL
zip -q easm.zip *.py
rem --- testing stuff disabled ---
rem python easm.zip 
rem if errorlevel 1 goto exit
rem copy bin\a.prg ..\emulator\bin\asm.prg >NUL
:exit 

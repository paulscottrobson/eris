@echo off
call build\prebuild.bat
if errorlevel 1 goto exit
mingw32-make -f build\makefile
if errorlevel 1 goto exit
eris.exe bin\kernel.prg bin\basic.prg bin\basiccode.prg
:exit


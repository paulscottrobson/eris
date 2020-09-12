@echo off
call build.files\prebuild.bat %*
if errorlevel 1 goto exit
mingw32-make -f build.files\makefile
if errorlevel 1 goto exit
eris.exe bin\kernel.prg bin\basic.prg bin\test.prg
:exit


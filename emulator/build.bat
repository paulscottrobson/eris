@echo off
call build.files\prebuild.bat
if errorlevel 1 goto exit
del /Q src\*.o
del /Q framework\*.o
mingw32-make -f build.files\makefile
del /Q src\*.o
del /Q framework\*.o
if errorlevel 1 goto exit
eris.exe bin\kernel.prg bin\basic.prg bin\test.prg
:exit


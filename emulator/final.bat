@echo off
pushd ..\code.basic
call build.bat
popd
del /Q eris.exe
del /Q src\*.o
del /Q framework\*.o
call build.bat

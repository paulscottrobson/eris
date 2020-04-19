@echo off
pushd ../emulator
del /Q eris.exe >NUL
call build.bat
popd 
@echo off
call prebuild.bat
pushd ..\esp32
call build.bat
popd





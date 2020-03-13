@echo off
call build\prebuild.bat
pushd ..\esp32
call build.bat
popd





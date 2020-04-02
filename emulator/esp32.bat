@echo off
call build.files\prebuild.bat
pushd ..\esp32
call build.bat
popd





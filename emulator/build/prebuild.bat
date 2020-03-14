@echo off
pushd ..\assembler
call build.bat
popd 
pushd ..\processor
call build.bat
popd
rem python uasm.py
pushd ..\kernel
call build.bat
popd
pushd ..\basic
call build.bat
popd

@echo off
pushd ..\assembler
call build.bat
popd 
if errorlevel 1 goto exit
pushd ..\processor
call build.bat
popd
if errorlevel 1 goto exit
rem python uasm.py
pushd ..\kernel
call build.bat
popd
if errorlevel 1 goto exit
pushd ..\basic
call build.bat
popd
pushd build.files
python extractv.py
popd
:exit
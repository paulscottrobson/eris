@echo off
pushd c:\emsdk 
call emsdk_env.bat
popd
rem
rem		Download all the emulator source as is, and stop it auto running
rem
xcopy /S /Y /Q ..\emulator\src src
xcopy /S /Y /Q ..\emulator\include include
xcopy /S /Y /Q ..\emulator\framework framework
xcopy /S /Y /Q ..\emulator\cpu cpu
xcopy /S /Y /Q ..\emulator\bin bin
xcopy /S /Y /Q ..\emulator\storage storage

del /Q storage\autoexec.prg >NUL
rem
rem		Build the emulator in javascript.
rem
emcc framework\main.cpp framework\gfx.cpp framework\debugger.cpp src\sys_processor.cpp src\sys_debug_cpu.cpp src\hardware.cpp src\blitter.cpp -D EMSCRIPTEN -D LINUX -D NO_DEBUGGER -DINCLUDE_OS_SUPPORT -I. -I framework -I.\cpu -I.\bin -I include -O2 -s USE_SDL=2 -s WASM=1 -s --preload-file storage -o eris.html

@echo off
rem
rem		Convert BASIC to programs
rem
python ..\basic\scripts\makeprogram.py pong.bas storage\pong.prg
rem
rem		Copy one file (current working) as autoexec.prg
rem
copy storage\pong.prg storage\autoexec.prg
rem
rem		Copy current binary
rem
copy ..\emulator\eris.exe .
copy ..\emulator\SDL2.dll .
rem
rem		Build graphics and copy to storage
rem
pushd graphics
python ..\..\basic\scripts\gfxconv.py
copy *.spr ..\storage
popd
rem
rem		Run emulator
rem
eris.exe
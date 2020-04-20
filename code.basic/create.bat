rem @echo off
rem
rem		Convert BASIC to programs
rem
python ..\basic\scripts\makeprogram.py %1\%1.bas %1\%1.prg
python ..\basic\scripts\gfxconv.py %1\%1.png
rem
rem		Copy to storage and make it the autoexec.
rem
copy %1\%1.prg storage >NUL
copy %1\%1.spr storage >NUL
copy %1\%1.dat storage >NUL
copy %1\%1.prg storage\autoexec.prg >NUL
rem
rem		Copy all the storage to emulator, where it will go to esp32 and javascript
rem
copy storage\* ..\emulator\storage  >NUL

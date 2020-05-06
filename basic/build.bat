@echo off
rem pushd ..\assembler >NUL
rem call build.bat
rem popd >NUL
rem
del generated\token_test.inc >NUL 
del ..\emulator\storage\autoexec.prg >NUL

pushd scripts >NUL
del prg\autoexec.prg >NUL
python tables.py
python3 rpldoc.py >..\..\documents\rpl.html

python makeprogram.py source\sed.bas prg\sed
python makeprogram.py source\bgr.bas prg\bgr.prg
python makeprogram.py source\test.bas prg\autoexec.prg
python makeprogram.py source\test.bas prg\test.prg
python makeprogram.py source\sprites.bas prg\sprites.prg
python makeprogram.py source\spritecoll.bas prg\spritecoll.prg
python makeprogram.py source\tilemap.bas prg\tilemap.prg


copy prg\test.prg ..\..\emulator\bin >NUL
copy prg\*.* ..\..\emulator\storage >NUL

popd

pushd messages >NUL
python msgconv.py
popd messages

copy ..\kernel\bin\a.lbl generated\kernel.labels >NUL

python ..\assembler\easm.zip
if errorlevel 1 goto exit
copy bin\a.prg ..\emulator\bin\basic.prg >NUL
copy bin\_binary.h ..\emulator\bin\_basic.h >NUL
:exit

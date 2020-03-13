@echo off
copy ..\emulator\src\sys_processor.cpp src
copy ..\emulator\src\blitter.cpp src
copy ..\emulator\src\hardware.cpp src
copy ..\emulator\include\*.h include
copy ..\emulator\bin\*.h include
copy ..\emulator\framework\gfxkeys.h include
copy ..\emulator\src\hardware_*.cpp include
copy ..\emulator\cpu\*.h src\include
copy ..\emulator\bin\basiccode.prg data
rem  === FabGL Library ===
pio lib install 6143 	
pio run -t upload
pio run -t uploadfs
set -e
cp ../emulator/src/sys_processor.cpp src
cp ../emulator/src/blitter.cpp src
cp ../emulator/src/hardware.cpp src
cp ../emulator/include/*.h include
cp ../emulator/bin/*.h include
cp ../emulator/framework/gfxkeys.h include
cp ../emulator/src/hardware_*.cpp include
cp ../emulator/cpu/* src/cpu
cp ../emulator/bin/basiccode.prg data
# === FabGL Library ===
pio lib install 6143 	
pio run -t upload
pio run -t uploadfs
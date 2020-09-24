ifeq ($(OS),Windows_NT)
# ***********************************************************************************
#
#										Windows Build
#
# ***********************************************************************************
CCOPY = copy
CMAKE = mingw32-make
CDEL = del /Q
APPNAME = eris.exe
S = \\
CXXFLAGS = -IC:\sdl2\include\SDL2 -Iframework -I .\include -I .\bin -I .\cpu -DINCLUDE_OS_SUPPORT -DWINDOWS
LDFLAGS = -LC:\sdl2\lib -lmingw32 -lSDL2main -lSDL2
else
# ***********************************************************************************
#
#											Linux Build
#
# ***********************************************************************************
CCOPY = cp
CDEL = rm -f
CMAKE = make
APPNAME = eris
S = /
SDL_CFLAGS := $(shell sdl2-config --cflags)
SDL_LDFLAGS := $(shell sdl2-config --libs)
CXXFLAGS := $(SDL_CFLAGS) -O2 -DLINUX -DINCLUDE_OS_SUPPORT \
			-I. -I .$(S)include -I.$(S)framework -I$(S)usr$(S)include$(S)SDL2 -I.$(S)cpu -I.$(S)bin
LDFLAGS := $(SDL_LDFLAGS)
endif

# ***********************************************************************************
#
#											Common Build
#
# ***********************************************************************************

SOURCES = framework$(S)main.o framework$(S)gfx.o framework$(S)debugger.o \
		  src$(S)sys_processor.o src$(S)sys_debug_cpu.o src$(S)hardware.o src$(S)blitter.o
		  
CC = g++

.PHONY: all clean emulator prebuild final
#
#		Basic, Kernel and Emulator
#
all: prebuild emulator
#
#		Emulator only
#
emulator: cpu$(S)_instructions.h $(APPNAME)
#
#		Basic Kernel Emulator DemoGames
#
final : clean prebuild emulator
	$(CMAKE) -B -C ..$(S)code.basic

prebuild:
	$(CMAKE) -C ..$(S)assembler
	$(CMAKE) -C ..$(S)kernel
	$(CMAKE) -C ..$(S)basic
	$(CMAKE) -C ..$(S)images
	
clean:
	$(CDEL) $(APPNAME) 
	$(CDEL) src$(S)*.o 
	$(CDEL) bin$(S)*

src$(S)hardware.o: src$(S)hardware.cpp src$(S)hardware_emu.cpp
	gcc $(CXXFLAGS) -c -o src$(S)hardware.o src$(S)hardware.cpp

cpu$(S)_instructions.h : 
	$(CMAKE) -C ..$(S)processor

$(APPNAME): $(SOURCES)
	$(CC) $(SOURCES) $(LDFLAGS) -o $@
	

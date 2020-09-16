SOURCES = framework/main.o framework/gfx.o framework/debugger.o \
		  src/sys_processor.o src/sys_debug_cpu.o src/hardware.o src/blitter.o
		  
APPNAME = eris

SDL_CFLAGS := $(shell sdl2-config --cflags)
SDL_LDFLAGS := $(shell sdl2-config --libs)

CXXFLAGS := $(SDL_CFLAGS) -O2 -DLINUX -DINCLUDE_OS_SUPPORT \
			-I. -I ./include -I./framework -I/usr/include/SDL2 -I./cpu -I./bin

LDFLAGS := $(SDL_LDFLAGS)

CC = g++

.PHONY: all clean emulator prebuild

all: prebuild emulator

emulator: cpu/_instructions.h $(APPNAME)

prebuild:
	make -C ../assembler
	make -C ../kernel
	make -C ../basic

clean:
	rm -f $(APPNAME) src/*.o bin/*

src/hardware.o: src/hardware.cpp src/hardware_emu.cpp
	gcc $(CXXFLAGS) -c -o src/hardware.o src/hardware.cpp

cpu/_instructions.h : 
	make -C ../processor

$(APPNAME): $(SOURCES)
	$(CC) $(SOURCES) $(LDFLAGS) -o $@




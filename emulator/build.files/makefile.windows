#OBJS specifies which files to compile as part of the project
OBJS = framework\main.o framework\gfx.o framework\debugger.o src\sys_processor.o src\sys_debug_cpu.o src\hardware.o src\blitter.o
#CC specifies which compiler we're using
CC = g++

#INCLUDE_PATHS specifies the additional include paths we'll need
INCLUDE_PATHS = -IC:\sdl2\include\SDL2 -Iframework -I .\include -I .\bin -I .\cpu

#LIBRARY_PATHS specifies the additional library paths we'll need
LIBRARY_PATHS = -LC:\sdl2\lib

#COMPILER_FLAGS specifies the additional compilation options we're using
# -w suppresses all warnings
# -Wl,-subsystem,windows gets rid of the console window
COMPILER_FLAGS = -DINCLUDE_OS_SUPPORT -DWINDOWS

#LINKER_FLAGS specifies the libraries we're linking against
LINKER_FLAGS = -lmingw32 -lSDL2main -lSDL2

#OBJ_NAME specifies the name of our exectuable
OBJ_NAME = eris.exe

%.o: %.cpp
	gcc -c $(COMPILER_FLAGS) $(INCLUDE_PATHS) -o $*.o $<

#This is the target that compiles our executable
$(OBJ_NAME) : $(OBJS)
	$(CC) $(OBJS) $(INCLUDE_PATHS) $(LIBRARY_PATHS) $(COMPILER_FLAGS) $(LINKER_FLAGS) -o $(OBJ_NAME)

src\hardware.o: src\hardware.cpp src\hardware_emu.cpp
	gcc -c $(COMPILER_FLAGS) $(INCLUDE_PATHS) -o $*.o $*.cpp


all : ${OBJ_NAME}

clean:
	del /Q $(OBJ_NAME) 
	del /q src\*.o
	del /q framework\*.o

.PHONY: all clean 

	

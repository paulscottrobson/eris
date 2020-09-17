ifeq ($(OS),Windows_NT)
CCOPY = copy
CCOPYQ = >NUL
CMAKE = mingw32-make
S = \\
else
CCOPY = cp
CCOPYQ = 
CMAKE = make
S = /
endif

.PHONY: all

all : 
	$(CMAKE) -C fonts
	$(CMAKE) -C keyboard-map 
	python ..$(S)assembler$(S)easm.zip 
	$(CCOPY) bin$(S)a.out ..$(S)emulator$(S)bin$(S)kernel.rom $(CCOPYQ)
	$(CCOPY) bin$(S)a.prg ..$(S)emulator$(S)bin$(S)kernel.prg $(CCOPYQ) 
	$(CCOPY) bin$(S)_binary.h ..$(S)emulator$(S)bin$(S)_kernel.h  $(CCOPYQ)

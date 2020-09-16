
.PHONY: all

all : 
	make -C fonts
	make -C keyboard-map 
	python3 ../assembler/easm.zip 
	cp bin/a.out ../emulator/bin/kernel.rom 
	cp bin/a.prg ../emulator/bin/kernel.prg 
	cp bin/_binary.h ../emulator/bin/_kernel.h 


.PHONY : all

all :
	make -C messages
	make -C scripts
	cp ../kernel/bin/a.lbl generated/kernel.labels 
	python3 ../assembler/easm.zip
	cp bin/a.prg ../emulator/bin/basic.prg 
	cp bin/_binary.h ../emulator/bin/_basic.h 


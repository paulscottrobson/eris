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

.PHONY : all

all :
	$(CMAKE) -C messages
	$(CMAKE) -C scripts
	$(CCOPY) ..$(S)kernel$(S)bin$(S)a.lbl generated$(S)kernel.labels $(CCOPYQ)
	python ..$(S)assembler$(S)easm.zip
	$(CCOPY) bin$(S)a.prg ..$(S)emulator$(S)bin$(S)basic.prg  $(CCOPYQ)
	$(CCOPY) bin$(S)_binary.h ..$(S)emulator$(S)bin$(S)_basic.h $(CCOPYQ)


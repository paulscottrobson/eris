ifeq ($(OS),Windows_NT)
CCOPY = copy
S = \\
else
CCOPY = cp
S = /
endif

_instructions.h : process.py 
	python process.py
	$(CCOPY) *.h ..$(S)emulator$(S)cpu
	

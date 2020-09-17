LANGUAGE = uk

ifeq ($(OS),Windows_NT)
CCOPY = copy
CMAKE = mingw32-make
S = \\
else
CCOPY = cp
CMAKE = make
S = /
endif

error_intl.inc : $(LANGUAGE).messages
	python msgconv.py $(LANGUAGE)
	$(CCOPY) error_intl.inc ..$(S)generated
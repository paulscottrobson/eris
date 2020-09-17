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
#
#	Convert basic source to .prg
#
CONVERT = python makeprogram.py $^ prg$(S)$(notdir $@)
#
#	Test programs to convert
#
BASTEST = prg$(S)bgr.prg prg$(S)test.prg prg$(S)sprites.prg prg$(S)spritecoll.prg prg$(S)tilemap.prg

.PHONY : all

all : obj$(S)tok_const.inc $(BASTEST) prg$(S)sed
	python rpldoc.py >..$(S)..$(S)documents$(S)rpl.html
	$(CCOPY) obj$(S)* ..$(S)generated $(CCOPYQ)
	$(CCOPY) prg$(S)test.prg prg$(S)autoexec.prg $(CCOPYQ)
	$(CCOPY) prg$(S)test.prg ..$(S)..$(S)emulator$(S)bin  $(CCOPYQ)
	$(CCOPY) prg$(S)* ..$(S)..$(S)emulator$(S)storage  $(CCOPYQ)

obj$(S)tok_const.inc : tables.py
	python tables.py

prg$(S)sed : source$(S)sed.bas
	$(CONVERT)

prg$(S)export : source$(S)export.bas
	$(CONVERT)

prg$(S)%.prg : source$(S)%.bas
	$(CONVERT) $^  prg$(S)$(notdir $@)


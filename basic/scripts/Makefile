#
#	Convert basic source to .prg
#
CONVERT = python3 makeprogram.py $^ prg/$(notdir $@)
#
#	Test programs to convert
#
BASTEST = prg/bgr.prg prg/test.prg prg/sprites.prg prg/spritecoll.prg prg/tilemap.prg

.PHONY : all

all : obj/tok_const.inc $(BASTEST) prg/sed
	python3 rpldoc.py >../../documents/rpl.html
	cp obj/* ../generated
	cp prg/test.prg prg/autoexec.prg
	cp prg/test.prg ../../emulator/bin 
	cp prg/* ../../emulator/storage 

obj/tok_const.inc : tables.py
	python3 tables.py

prg/sed : source/sed.bas
	$(CONVERT)

prg/export : source/export.bas
	$(CONVERT)

prg/%.prg : source/%.bas
	$(CONVERT) $^  prg/$(notdir $@)


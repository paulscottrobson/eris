.PHONY : all

%.eim : %.png
	python ../imec.zip $< $@

%.eim : %.jpg
	python ../imec.zip $< $@

all : $(patsubst %.png,%.eim,$(wildcard *.png)) $(patsubst %.jpg,%.eim,$(wildcard *.jpg))

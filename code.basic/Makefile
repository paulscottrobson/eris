

%.prg : %.bas
	python3 ../basic/scripts/makeprogram.py $^ $@
	cp $@ storage
	cp $@ storage/autoexec.prg

%.spr : %.png
	python3 ../basic/scripts/gfxconv.py $^
	cp $@ storage

.PHONY : all
	
all : asteroids aticatac breakout dodge frogger invaders maze pacman squash
	cp storage/* ../emulator/storage

asteroids: asteroids/asteroids.prg asteroids/asteroids.spr

aticatac: aticatac/aticatac.prg aticatac/aticatac.spr	

breakout: breakout/breakout.prg breakout/breakout.spr	

dodge: dodge/dodge.prg dodge/dodge.spr	

frogger: frogger/frogger.prg frogger/frogger.spr	

invaders: invaders/invaders.prg invaders/invaders.spr	

maze: maze/maze.prg maze/maze.spr		

pacman: pacman/pacman.prg pacman/pacman.spr		
	cp pacman/pacman.dat storage

squash: squash/squash.prg squash/squash.spr		

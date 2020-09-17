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

%.prg : %.bas
	python ..$(S)basic$(S)scripts$(S)makeprogram.py $^ $@
	$(CCOPY) $@ storage 
	$(CCOPY) $@ storage$(S)autoexec.prg

%.spr : %.png
	python ..$(S)basic$(S)scripts$(S)gfxconv.py $^
	$(CCOPY) $@ storage

.PHONY : all
	
all : asteroids aticatac breakout dodge frogger invaders maze pacman squash
	$(CCOPY) storage$(S)* ..$(S)emulator$(S)storage  $(CCOPYQ)

asteroids: asteroids$(S)asteroids.prg asteroids$(S)asteroids.spr

aticatac: aticatac$(S)aticatac.prg aticatac$(S)aticatac.spr	

breakout: breakout$(S)breakout.prg breakout$(S)breakout.spr	

dodge: dodge$(S)dodge.prg dodge$(S)dodge.spr	

frogger: frogger$(S)frogger.prg frogger$(S)frogger.spr	

invaders: invaders$(S)invaders.prg invaders$(S)invaders.spr	

maze: maze$(S)maze.prg maze$(S)maze.spr		

pacman: pacman$(S)pacman.prg pacman$(S)pacman.spr		
	$(CCOPY) pacman$(S)pacman.dat storage

squash: squash$(S)squash.prg squash$(S)squash.spr		

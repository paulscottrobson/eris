' **************************************************************************************************
'
'											Pacman
'
' **************************************************************************************************

screen 2,2
palette 1,0,4:palette 2,0,3:palette 3,0,6
palette 1,1,3:palette 2,1,1:palette 2,1,6
call setup.data(4)
call reset.game()
end
'
'						Set up Game Data
'
proc setup.data(n)
	sprite load "pacman.spr":ghost.count = n
	' Set up game map
	tile.map = alloc(520)
	load "pacman.dat",tile.map
	map.w = 19:map.h = 14
	dim map(map.w-1,map.h-1)
endproc
'
'						Reset for new game
'
proc reset.game()
	game = 0:lives = 3:level = 1:x.org = 8:y.org = 16
	call reset.screen()
endproc
'
'						 Reset the screen
'
proc reset.screen()
	local i,x,y,p,x1,y1
	cls:tile x.org,y.org,0,0,24,15,tile.map:call drawScore():call drawLives()
	' draw maze and fill with dots. -10 for six in tunnel, four power pills
	dot.count = -10:ink 2
	for y = 0 to map.h-1
		p = tile.map + 5 + 32 * y:x1 = x.org:y1 = y.org+y*16
		for x = 0 to map.w-1
			if (p!x and 15) <> 15 then draw x1,y1,14
			x1 = x1 + 16
		next x
	next y
	' ghost area (though they never go in)
	x = map.w/2*16+x.org:y = 7 * 16 + y.org:ink 3:rect x,y-1 to x+15,y+1
	' power pills
	for i = 0 to 3
		x = x.org+(i and 1)*(map.w-1)*16+8
		y = y.org+(i/2)*176+24
		sprite 16+i to x,y ink 1 draw 16
		ink 0:rect x-4,y-4 to x+4,y+4
	next i
	' clear out tunnel
	y = y.org+6*16
	ink 0:rect x.org,y+1 to x.org+47,y+14:rect x.org+map.w*16,y+1 to x.org+map.w*16-47,y+14
endproc
'
'							Draw score
'
proc drawScore()
	local x = 160-36:local y = 2
	blit x,y,score/100000 mod 10,&0303,12:x = x + 12
	blit x,y,score/10000 mod 10,&0303,12:x = x + 12
	blit x,y,score/1000 mod 10,&0303,12:x = x + 12
	blit x,y,score/100 mod 10,&0303,12:x = x + 12
	blit x,y,score/10 mod 10,&0303,12:x = x + 12
	blit x,y,score mod 10,&0303,12:x = x + 12
endproc
'
'						   Draw lives
'
proc drawLives()
	local i:ink 0:rect 0,0 to 100,15:ink 2
	if lives > 0 
		for i = 1 to lives
			draw i*20,0,11
		next i
	endif
endproc
' **************************************************************************************************
'
'											Pacman
'
' **************************************************************************************************

screen 2,2
palette 1,0,4:palette 2,0,3:palette 3,0,6
palette 1,1,3:palette 2,1,1:palette 3,1,6
call setup.data(4)
call reset.game()
call play.game()
end
'
'						 Play one game
'
proc play.game()
	local i,d,c,life.lost
	call reset.Objects()
	e.pills = 0:e.move = 0
	life.lost = false
	repeat
		if event(e.pills,70) then call flash.pills()
		if event(e.move,4) 
			for i = 0 to ghost.count
				d = game.speed:if d > odist(i) then d = odist(i)
				ox(i) = ox(i)+d*oxi(i):oy(i) = oy(i)+d*oyi(i)
				odist(i) = odist(i)-d
				sprite i to ox(i)+x.org+8,oy(i)+y.org+8
				if odist(i) = 0
					x = ox(i) >> 4:y = oy(i) >> 4
					if i = 0 
						call redirect.Player(x,y)
					else
						call redirect.Ghost(i,x,y)
					endif					
					odist(i) = 16
				else
					rem "Todo : if joy<axis> = -dir<axis> reverse"
				endif
			next i
		endif
	until life.lost or dot.count = 0
endproc
'
'						  Redirect player
'
proc redirect.player(x,y)
endproc
'
'						   Redirect ghost
'
proc redirect.ghost(n,x,y)
endproc
'
'						Flash power pills
'
proc flash.pills()
	local i,c
	pill.count = pill.count + 1
	c = (pill.count and 1)
	for i = 0 to 3:sprite i+16 ink c:next i	
endproc
'
'						Set up Game Data
'
proc setup.data(n)
	x.org = 8:y.org = 16:map.w = 19:map.h = 14
	sprite load "pacman.spr":ghost.count = n
	' Load tile map and set up map.
	tile.map = alloc(520):load "pacman.dat",tile.map
	dim map(map.w-1,map.h-1)
	' Game object data
	dim ox(n),oy(n):rem "Position offset from x.org,y.org"
	dim oxi(n),oyi(n):rem "Direction of travel -1,0,1"
	dim odist(n):rem "Pixels to next 16 pixel boundary"	
endproc
'
'						Reset for new game
'
proc reset.game()
	game = 0:lives = 3:level = 1
	call reset.screen()
endproc
'
'						Reset game objects
'
proc reset.objects()
	game.speed = 4:chase.mode = false
	ox(0) = map.w/2*16:oy(0) = 11*16:oxi(0) = 0:oyi(0) = 0:odist(i) = 16
	sprite 0 ink 1 draw 11
	if ghost.count > 0
		for i = 1 to ghost.count:call reset.ghost(i):next i
	endif
	for i = 0 to ghost.count
		sprite i to ox(i)+x.org+8,oy(i)+y.org+8
	next i
endproc
'
'		Reset a ghost
'
proc reset.ghost(i)
	ox(i) = map.w/2*16:oy(i) = 7*16:oxi(i) = 0:oyi(i) = -1:odist(i) = 16
	sprite i ink (i mod 3)+1 draw 13
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
			map(x,y) = p!x and 15
			if map(x,y) <> 15 then draw x1,y1,14:map(x,y) = map(x,y)+16
			x1 = x1 + 16
		next x
	next y
	' ghost area (though they never go in)
	x = map.w/2*16+x.org:y = 7 * 16 + y.org:ink 3:rect x,y-1 to x+15,y+1
	' power pills
	for i = 0 to 3
		x = (i and 1)*(map.w-1):y = (i/2)*9+3
		map(x,y) = map(x,y)-16+32
		x = x * 16+x.org+8:y = y*16+y.org+8
		ink 0:rect x-4,y-4 to x+4,y+4
		sprite 16+i to x,y ink 0 draw 16
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


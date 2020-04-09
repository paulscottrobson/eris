' **************************************************************************************************
'
'											Pacman
'
' **************************************************************************************************
'
'		Make ghosts intelligent
'		Add power pill code
' 		Add collision
' 		Add bonuses
'		Add sfx
'		Add levels
' 		Fix tunnel.
'
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
	local life.lost = false
	call reset.Objects()
	e.pills = 0:e.move = 0:e.animate = 0
	repeat
		if event(e.pills,70) then call flash.pills()
		if event(e.animate,20) then call animate.objects()
		if event(e.move,8) then call move.objects()
	until life.lost or dot.count = 0
endproc
'
'						Move objects
'
proc move.objects()
	local i,x,y,d
	for i = 0 to ghost.count
		d = game.speed:if d > odist(i) then d = odist(i)
		ox(i) = ox(i)+d*oxi(i):oy(i) = oy(i)+d*oyi(i)
		if ox(i) < 0 then ox(i) = map.w*16
		if ox(i) > map.w*16 then ox(i) = 0
		odist(i) = odist(i)-d
		sprite i to ox(i)+x.org+8,oy(i)+y.org+8
		if odist(i) = 0
			x = ox(i) >> 4:y = oy(i) >> 4
			if i = 0 
				call redirect.Player(x,y)
			else
				call redirect.Ghost(i,x,y)
			endif					
		else
			rem "Todo : if joy<axis> = -dir<axis> reverse"
		endif
	next i
	if oxi(0) <> 0 and joyx() = -oxi(0) then call redirect.fine(-oxi(0),0)
	if oyi(0) <> 0 and joyy() = -oyi(0) then call redirect.fine(-oxi(0),0)
endproc
'
'						  Redirect player
'
proc redirect.player(x,y)
	local dx,dy,erase = False:
	dy = joyy():dx = 0:if joyx() <> 0 then dx = joyx():dy = 0
	call set.Direction(0,dx,dy,map(x,y))
	if map(x,y) and 16
		map(x,y) = map(x,y)-16
		game.score = game.score + 10:dot.count = dot.count - 1:erase = true
		game.score = dot.count
		call draw.score()
	endif
	if erase then x = x * 16+x.org:y = y*16+y.org:ink 0:rect x+1,y+1 to x+14,y+14
	call update.player.graphic()
endproc
'
'
'
proc redirect.fine(dx,dy)
	if odist(0) > 0
		local d = odist(0)
		call set.direction(0,dx,dy,0)
		odist(0) = 16-d
		call update.player.graphic()
	endif
endproc
'
'
'
proc update.player.graphic()
	if oxi(0) <> 0 then player.graphic = 11:player.graphic.flip = 1-oxi(0)
	if oyi(0) <> 0 then player.graphic = 12:player.graphic.flip = (1-oyi(0))/2
endproc
'
'
'						   Redirect ghost
'
proc redirect.ghost(n,x,y)
	local dx,dy,d
	local c = map(x,y) and 15
	if (c = 5 and oxi(n) <> 0) or c = 10 
		dx = oxi(n):dy = oyi(n)
	else
		d = random(0,3)
		while (c and (1<<d)):d = random(0,3):wend
		dx = 0:dy = sgn(d-1):if (d and 1) then dx = sgn(2-d):dy = 0
		oxi(n) = 0:oyi(n) = 0
		call set.direction(n,dx,dy,c)
	endif
	odist(n) = 16
	if oxi(n) <> 0 then sprite n flip 1-oxi(n)
endproc
'
'					  Set player direction
'
proc set.direction(n,dx,dy,cell)
	is.okay = false
	local b = 0
	if dx <> 0 then b = 8-(dx+1)*3
	if dy <> 0 then b = 1:if dy > 0 then b = 4
	if (cell and b) = 0 then is.okay = true:oxi(n) = dx:oyi(n) = dy:odist(n) = 16
endproc
'
'					  Animate game objects
'
proc animate.objects()
	animate.count = animate.count + 1
	if animate.count and 1
		sprite 0 draw 10
	else
		sprite 0 draw player.graphic flip player.graphic.flip
	endif	
endproc
'
'						Flash power pills
'
proc flash.pills()
	local i,c
	pill.anim = pill.anim + 1
	c = (pill.anim and 1)
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
	dim ochase(n):rem "Object being chased ?"
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
	game.speed = 4
	chase.mode = false:player.graphic = 11:player.graphic.flip = 0
	ox(0) = map.w/2*16:oy(0) = 11*16:oxi(0) = 0:oyi(0) = 0:odist(i) = 16
	sprite 0 ink 1 draw player.graphic flip 0
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
	ox(i) = map.w/2*16:oy(i) = 7*16-i*4:oxi(i) = 0:oyi(i) = -1:odist(i) = 16-i*4
	sprite i ink (i mod 3)+1 draw 13
endproc
'
'						 Reset the screen
'
proc reset.screen()
	local i,x,y,p,x1,y1
	cls:tile x.org,y.org,0,0,24,15,tile.map:call draw.score():call draw.lives()
	' draw maze and fill with dots. -10 for six in tunnel, four power pills
	dot.count = -10:ink 2
	for y = 0 to map.h-1
		p = tile.map + 5 + 32 * y:x1 = x.org:y1 = y.org+y*16
		for x = 0 to map.w-1
			map(x,y) = p!x and 15
			if map(x,y) <> 15 then draw x1,y1,14:map(x,y) = map(x,y)+16:dot.count = dot.count+1
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
proc draw.score()
	local x = 160-36:local y = 2
	blit x,y,game.score/100000 mod 10,&0303,&080C:x = x + 12
	blit x,y,game.score/10000 mod 10,&0303,&080C:x = x + 12
	blit x,y,game.score/1000 mod 10,&0303,&080C:x = x + 12
	blit x,y,game.score/100 mod 10,&0303,&080C:x = x + 12
	blit x,y,game.score/10 mod 10,&0303,&080C:x = x + 12
	blit x,y,game.score mod 10,&0303,&080C:x = x + 12
endproc
'
'						   Draw lives
'
proc draw.lives()
	local i:ink 0:rect 0,0 to 100,15:ink 2
	if lives > 0 
		for i = 1 to lives
			draw i*20,0,11
		next i
	endif
endproc


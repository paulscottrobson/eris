' **************************************************************************************************
'
'											Frogger
'
' **************************************************************************************************

'	Diving turtles.
'	Scoring / SFX - score on DY +/- and home.
'	Lose life/Lives display.
'	Bonus
'	Level up on end.
'
screen 3,1:palette 1,1,2
!&FFFD = true:call initialise():!&FFFD = false
call play.level(1)

proc play.level(level)
	local i
	for i = 1 to 5:home.used(i) = false:next i
	game.time = 6:home.count = 5
	call reset.player()
	time.nextMove = timer()
	while not life.lost and home.count > 0
		if timer()-time.nextMove >= 0
			call move.tilemaps()	
			if pl.moving call move.player() else call check.move() endif
		endif
	wend
endproc
'
'		Check for player move.
'
proc check.move()
	local n = joyx()
	if n <> 0 then pl.dx = n*4:sprite 0 draw 1 flip 1-n
	if n = 0 then n = joyy():if n <> 0 then pl.dy = n*4:sprite 0 draw 0 flip (1+n) >> 1
	if pl.dx<>0 or pl.dy<>0
		pl.moving = true:pl.count = 4
	endif
endproc
'
'		Move Player
'
proc move.player()
	pl.x = pl.x+pl.dx:pl.y = pl.y+pl.dy:sprite 0 to pl.x,pl.y
	pl.count = pl.count-1
	if pl.count = 0
		pl.moving = false:pl.dx = 0:pl.dy = 0
		if pl.y = 2*16+8 then call check.player.home()
	endif
endproc
'
'		check player home.
'
proc check.player.home()
	local i,t:t = 0
	for i = 1 to 5
		if not home.used(i) and abs(pl.x-home.x(i))<home.width/2 then t = i
	next i
	if t = 0 
		call lose.life()
	else
		ink 2:draw home.x(t)-8,32,2
		ink 1:draw home.x(t)-8,32,3
		home.used(t) = true
		home.count = home.count - 1
	endif
	call reset.player()
endproc
'
'		Reset player
'
proc reset.player()
	pl.x = 160:pl.y = 14*16+8:pl.dx = 0:pl.dy = 0
	sprite 0 ink 1 to pl.x,pl.y draw 0 flip 0
	pl.moving = false:life.lost = false
endproc
'
'		Move all the tilemaps. This adjusts the shifting granularity
'		to make scrolling work. speed.mask is the granularity level.
'
proc move.tilemaps()
	local n,d,p,m
	frame.count = frame.count+1
	d = (frame.count and 1)*8
	time.nextMove = time.nextMove+game.time
	m = mask(speed.mask)
	;ink speed.mask+1:cursor 0,0:print speed.mask;
	for p = d to d+7
		d = map(p)
		if d <> 0
			n = (!d+(d!1)):!d = n and &01FFF
			if ((d!2 xor n) and m) 
				if p < 8 and p = (pl.y>>4) then pl.x = pl.x-(n-d!2)/16:sprite 0 to pl.x,pl.y
				d!2 = !d:tile 0,p*16,!d>>4,0,64,1,d+3
			endif
		endif
	next p
	if timer()-time.nextMove >= 0
		speed.mask = min(speed.mask+1,3)
	else
		speed.mask = max(speed.mask-1,0)
	endif
endproc
'
'		Initialise game data
'
proc initialise()
	sprite load "frogger.spr"
	game.hiScore = 1000
	dim mask(3):speed.mask = 0
	mask(0) = &1FF0:mask(1) = &1FE0:mask(2) = &1FC0:mask(3) = &1F80
	call draw.background()
	call create.tilemaps()
endproc
'
'		Draw background
'
proc draw.background()
	local i
	' Frame part
	ink 3:cursor 24,0:print "HI-SCORE":cursor 12,0:print "1-UP";
	ink 1:cursor 11,1:print "000000";:cursor 25,1:print "001000";
	for i = 0 to 304 step 16
		ink 2:draw i,16,16:draw i,32,15
		ink 5:draw i,128,15:draw i,224,15
	next i
	' Home spaces
	dim home.x(5),home.used(5):n = 60:home.width = 24
	for i = 1 to 5
		home.x(i) = 160+n*(i-1)-2*n
		ink 0:rect home.x(i)-home.width/2,2*16 to home.x(i)+home.width/2,2*16+15
	next i:ink 1
endproc
'
'		Create tilemaps for the lanes.
'
proc create.tilemaps()
	local t,a,i,n
	dim map(15):rem "addresses +0 pos.16 +1 speed.16 +2 last.16 +3 tilemap as per spec 64 x 1"
	map.table = alloc(16)
	dim turtle.addr(32),turtle.size(32),turtle.change(32):turtle.count = 0
	for i = 0 to 15:map(i) = 0:map.table!i = 0:next i
	for i = 3 to 13
		if i <> 8
			a = alloc(72):map(i) = a:map.table!i = 0
			a!0 = random(0,31*16*16-1):a!1 = 0:a!2 = a!0
			t = a + 3
			t!0=&ABCD:t!1=16:t!2=64:t!3=1:t!4 = 0
			for n = 5 to 31+5:t!n=0:next n
			if i = 13 then call generate.lane(t+5,10,7,4,6,&4000):speed = -1
			if i = 12 then call generate.lane(t+5,11,6,4,8,0):speed = 1
			if i = 11 then call generate.lane(t+5,12,5,4,6,&4000):speed = -2
			if i = 10 then call generate.lane(t+5,10,3,4,8,0):speed = 2
			if i = 9 then call generate.lane(t+5,14,7,5,8,&4000):speed = -1

			if i = 7 then call generate.river(t+5,4,3,3,2,4,0):speed = 1
			if i = 6 then call generate.river(t+5,7,1,3,2,4,&4000):speed = -1
			if i = 5 then call generate.river(t+5,7,1,2,2,4,0):speed = 2
			if i = 4 then call generate.river(t+5,4,3,2,3,4,0):speed = -2
			if i = 3 then call generate.river(t+5,7,1,2,2,4,0):speed = 3

			a!1 = -speed * 16
			tile 0,i*16,(a!0)>>4,0,64,1,t

			a = t + 32
			for n = 5 to 36:a!n = t!n:next n
		endif
	next i
endproc
'
proc generate.lane(map,graphic,col,n1,n2,bits)
	local c = 0
	while c < 32
		map!c = graphic+col*256+bits:if graphic = 14 then map!(c+1) = (map!c)-1
		c = c + random(n1,n2)
	wend
endproc
'
proc generate.river(map,graphic,col,size,n1,n2,bits)
	local c = 0:local i
	while c < 32-size
		if graphic = 7
			turtle.count = turtle.count + 1
			turtle.addr(turtle.count) = map+c
			turtle.size(turtle.count) = size
		endif
		for i = 1 to size
			if graphic = 7 
				map!c = graphic+col*256+bits
			else
				g = graphic:if i > 1 then g = g+1:if i = size then g = g+1
				map!c = g+col*256+bits				
			endif
			c =c+1
			next i
		c = c + random(n1,n2)
	wend
endproc

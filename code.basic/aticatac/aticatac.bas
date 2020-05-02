
'	Shooting monsters (not invulnerable ones)
' 	Design right side, live strength.
'	Monster collisions (some invulnerable destroy on impact)
'
map.size = 10:call create.game()
repeat
	call do.room()
until true
end


proc do.room()
	!&FFFD=1
	call unpack.current():call draw.room(1)
	call reset.monsters():call reset.missile()
	!&FFFD=0
	e.pMove = 0:e.mMove = 0
	left.room = false:life.lost = false
	repeat
		if event(e.pMove,7) then call move.player()
		if event(e.mMove,6) then call move.missile()
		call move.monsters()
	until left.room or life.lost
endproc

;
;		Move the Player
;
proc move.player()
	local x,y,dx,dy,allow = true
	x = player.x+joyx()*3:y = player.y+joyy()*3
	dx = abs(x-128):dy = abs(y-120)
	if dx >= x.width then allow = false:if dy < door.width then call check.exit(x,y)
	if dy >= y.height then allow = false:if dx < door.width then call check.exit(x,y)
	if x<>player.x or y<>player.y then sprite 0 draw timer() and 8
	if allow then sprite 0 to x,y:player.x = x:player.y = y
	if joyx() then sprite 0 flip 1-joyx()
endproc
;
;		Move the missile
;
proc move.missile()
	if m.active
		if timer() < m.endTime 
			m.x = m.x+m.xi:m.y = m.y+m.yi
			if abs(m.x-128) >= x.width then m.xi = -m.xi
			if abs(m.y-120) >= y.height then m.yi = -m.yi
			sprite 1 to m.x,m.y ink 3 flip random(0,3) draw random(16,17)
		else
			call reset.missile()
		endif
	else
		if joyb(1) and (joyx() <> 0 or joyy() <> 0)
			m.active = true
			m.x = player.x:m.y = player.y:m.xi = 5*joyx():m.yi = 5*joyy()
			m.endTime = timer()+250
		endif
	endif
endproc
;
;		Reset the missile
;
proc reset.missile()
	m.x = 0:m.y = 0:m.active = false:m.xi = 0:m.yi = 0:sprite 1 end
endproc
;
;		Check exit when at x,y
;
proc check.exit(x,y)
	left.room = True
	if dx >= x.width
		player.x = 255-player.x
		room.x = room.x + sgn(x-128)
	else
		player.y = 239-player.y
		room.y = room.y + sgn(y-120)
	endif
endproc
;
;		Move monsters
;
proc move.monsters()
	local i,s
	for i = 1 to m.count
		if timer() > m.ev(i) 
			s = m.stat(i)
			if s = 0 then m.stat(i) = 1:m.ev(i) = timer()+80:sprite m.spr(i) to m.x(i),m.y(i) ink random(1,3) draw 16
			if s = 1 then call promote.monster(i):m.stat(i) = 2
			if s = 2 then call move.monster(i)
		endif
		if m.stat(i) = 1 then sprite m.spr(i) draw random(16,17) flip random(0,3)
	next i
endproc
;
;		Move monster
;
proc move.monster(n)
	local f
	m.ev(i) = timer()+m.spd(i)
	m.x(i) = m.x(i)+m.xi(i):m.y(i) = m.y(i)+m.yi(i)
	if abs(m.x(i)-128) > x.width then m.xi(i) = -m.xi(i)
	if abs(m.y(i)-120) > y.height then m.yi(i) = -m.yi(i)
	if random(0,m.tgt(i)) = 0 then call retarget.monster(i)
	f = 0::if m.xi(i) < 0 then f = 2
	sprite m.spr(i) to m.x(i),m.y(i) flip f
endproc
;
;		Make sprite 'real'
;
proc promote.monster(i)
	local n = random(1,5)
	sprite m.spr(i) draw n+20 flip 0
	m.ev(i) = timer():m.inv(i) = 0:m.tgt(i) = 20:m.spd(i) = 8
	rem "Wizard, Skeleton, Ghost, Bat Head"
	if n = 1 then m.tgt(i) = 10
	if n = 2 then m.tgt(i) = 999:m.spd(i) = 6
	if n = 3 then m.inv(i) = 1:m.spd(i) = 12
	if n = 4 then m.tgt(i) = 10:m.spd(i) = 6
	if n = 5 then m.inv(i) = 2:m.tgt(i) = 0:m.spd(i) = 16
	call retarget.monster(i)

endproc
;
;		Retarget sprite
;
proc retarget.monster(i)
	m.xi(i) = sgn(player.x-m.x(i))
	m.yi(i) = sgn(player.y-m.y(i))
endproc
;
;		Initialise the game
;
proc create.game()
	screen 2,2:palette 1,1,6
	room.size = 32:door.width = 14
	sprite load "aticatac.spr"
	dim door$(map.size,map.size):rem "col/type x 4 NESW"
	dim size(map.size,map.size):rem "1 = 1x2,2 = 2x1,3 = 2x2"
	dim type(map.size,map.size):rem "0 = New,1 = Cave, 2 = Room"
	dim exit(3,1):rem "NSEW exit. 0=exit type (0 = shut),1 = exit colour"	
	player.x = 128:player.y = 120:room.x = map.size:room.y = map.size/2
	;
	door$(room.x,room.y) = "14243424":size(room.x,room.y) = 3:type(room.x,room.y) = 2
	;
	m.max = 5:m = 5
	dim m.stat(m):rem "0 not present 1 materialising 2 active"
	dim m.x(m),m.xi(m),m.y(m),m.yi(m):rem "Position/direction"
	dim m.spr(m),m.ev(m),m.spd(m),m.tgt(m),m.inv(m):rem "Sprite, next event, speed, retarget chance,invulnerable"
endproc
;
;		Unpack current room doors
;
proc unpack.current()
	local i,a$
	for i = 0 to 3
		a$ = mid$(door$(room.x,room.y),i*2+1,2)
		exit(i,0) = val(mid$(a$,1,1))
		exit(i,1) = val(mid$(a$,2,1))
		ink 2:print exit(i,0),exit(i,1)
	next i
	x.Scale = size(room.x,room.y):y.Scale = 3-x.Scale
	if size(room.x,room.y) >= 3 then x.scale = 2:y.scale = 2
	x.width = room.size*x.scale:y.height = room.size*y.scale
endproc
;
;		Reset monsters
;
proc reset.monsters()
	local i
	m.count = random(2,3):if size(room.x,room.y) = 3 then m.count = random(3,5)
	for i = 1 to m.count:call reset.one.monster(i):next i
endproc
;
proc reset.one.monster(i)
	m.stat(i) = 0:m.x(i) = random(128-x.width,128+x.width):m.y(i) = random(120-y.height,120+y.height)
	m.spr(i) = i + 4:m.ev(i) = random(10,200)+timer():sprite m.spr(i) end
endproc
;
;		Draw a room in current scale and givn style
;
proc draw.room(type)
	local x.scale1 = x.scale*10:if x.scale1 = 10 then x.scale1 = 13
	local y.scale1 = y.scale*10:if y.scale1 = 10 then y.scale1 = 13
	ink 0:rect 0,0 to 255,239:palette 3,0,7
		local cx,cy:cx = 128:cy = 120+58*y.scale:ink 3
	if type = 1
		cy = 128+52*y.scale
		call line(12,56):call line(24,49):call line(40,57)
		call line(52,52):call line(47,35):call line(55,15)
		call line(50,0)
	else
		call line(45,58):call line(58,45):call line(58,0)
	endif
	ink 0:rect 128-room.size*x.scale,120-room.size*y.scale to 128+room.size*x.scale,120+room.size*y.scale
	ink 3:frame 128-room.size*x.scale,120-room.size*y.scale to 128+room.size*x.scale,120+room.size*y.scale
	;
	local i
	for i = 0 to 3:
		if exit(i,0) <> 0 then call draw.door(i,exit(i,1),exit(i,0) mod 8)
	next i
	sprite 0 to player.x,player.y ink 1 draw 0
endproc
;
;		Draw one door
;
proc draw.door(door,gfx,col)
	local x = 128-16:local y = 120-16:local bflip = 0
	if gfx > 7 then gfx=7
	if door = 0 then y = y - room.size*y.Scale-16
	if door = 1 then x = room.size*x.Scale+128:gfx = gfx+8
	if door = 2 then y = room.size*y.Scale+120:bflip = &6000
	if door = 3 then x = x - room.size*x.scale-16:gfx = gfx+8:bflip = &6000
	blit x,y,sysvar(3)+gfx*16,&0300+col,&1010+bflip
endproc
;
;		Line drawer, support routine for room draw, draws in four quadrants
;
proc line(x,y)
	local x1,y1:x1 = x*x.scale1/10+128:y1 = y*y.scale1/10+120
	if y <> 0
		line 128,120 to x1,y1:line 128,120 to 256-x1,y1
		line 128,239-120 to x1,239-y1:line 128,239-120 to 256-x1,239-y1
	endif
	line cx,cy to x1,y1:line 256-cx,cy to 256-x1,y1
	line cx,239-cy to x1,239-y1:line 256-cx,239-cy to 256-x1,239-y1
	cx = x1:cy = y1
endproc

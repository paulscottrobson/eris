'
'		Sword of Fargoal
'
'	Todo:
'		Position Player
'		Open Player
'		Position Monsters (hidden)
'		Bring to life and move
'		Collect things
'		Fighting
'
!&FFFD = 1
randomise 32
screen 2,2:cls
call initialise()
call reset.player()
call create.level.map(level,level = sword.level,sword.found)
call player.new.level()
;call spiral.draw()
end
;
;		Reset the player
;
proc reset.player()
	level = 1:exp.level = 1
	start.time = 0:time100 = timer()
	hit.points = random(1,6)+random(1,6)+random(1,6)
	battle.skill = random(1,6)+random(1,6)+random(1,6)
	max.hit.points = hit.points
	exp.points.next.level = 200
	sword.level = random(15,20)
	heal.potions = 1:teleport.spells = 1:gold.max = 100
	gold = 0:sword.found = false
	deepest.level = 0:total.kills = 0
endproc
;
;		Player enters new level
;
proc player.new.level()
	hidden.gold.count = 0:pit.change = 0:light.on = false
	autoheal.rate = 50:monster.speed = max(20-level,1)
	deepest.level = max(level,deepest.level)
endproc
;
;		Create a new map
;
proc create.level.map(level,isSword,hasSword)
	local i,r,x,y,w,h
	; Create rooms
	for i = 0 to map.w*map.h-1:map!i = g.wall:next i
	for r = 0 to map.rooms-1
		w = random(3,map.w/6):h = random(3,map.h/4)
		x = random(1,map.w-2-w):y = random(1,map.h-2-h)
		room.x(r) = x + w / 2:room.y(r) = y + h/2
		for i = 1 to w:for j = 1 to h:!(map+x+i+(j+y)*map.w) = g.space:next j:next i
	next r
	; Open up links between rooms
	for r = 0 to map.rooms-1
		call open.route(room.x(r),room.y(r))
	next r
	; Place objects
	i = g.temple:if isSword then i = g.sword
	call place.object(1,i)
	call place.object(random(2,4),g.stairs.down)
	if level > 1 or hasSword then call place.object(1,g.stairs.up)

	call place.object(random(6,11),g.gold)
	call place.object(random(level,level+3),g.traps)

	for y = 0 to map.h-1:for x = 0 to map.w-1:call draw(x,y,map!(x+y*map.w)):next x:next y
endproc
;
;		Place objects
;
proc place.object(count,obj)
	local x,y
	while count > 0
		call get.empty():!(map+x+y*map.w) = obj:count = count - 1
	wend
endproc
;
;		Find empty slot
;
proc get.empty()
	repeat
		x = random(0,map.w-1):y = random(0,map.h-1)
	until !(map+x+y*map.w) = g.space
endproc
;
;		Open up a pathway from the given coordinates
;
proc open.route(xp,yp)
	local xi,yi:local hit.wall.yet:local complete = false
	local i,x,y,l,count,edge,inRoom
	call new.direction()
	repeat	
		x = xp:y = yp:hit.wall.yet = false:l = random(5,10):size = 0
		repeat
			x = x + xi:y = y + yi:c = !(map+x+y*map.w):l = l - 1
			if c = g.wall then hit.wall.yet = true
			!(map+x+y*map.w) = g.space
			edge = x = 0 or x = map.w-1 or y = 0 or y = map.h-1
			inRoom = (hit.wall.yet and c = g.space)
		until edge or inRoom or l = 0
		if inRoom then complete = true
		if edge then !(map+x+y*map.w) = g.wall:x = x - xi:y = y - yi
		call new.direction():xp = x:yp = y
	until complete
endproc	
;
;		Calculate a new direction which isn't back the way you came.
;
proc new.direction()
	local x,y:x = -xi:y = -yi
	repeat
		xi = 0:yi = random(0,1)*2-1:if random(0,1) = 0 then xi = yi:yi = 0
	until xi <> x or yi <> y
endproc
;
proc draw(x,y,c)
	blit x*8,y*8+8,graphic+(c and 255)*8,&0300+(c >> 8),8
endproc
;
;		Spiral Draw
;
proc spiral.draw()
	local i,x,y,t = 0:cls
	while i <  map.h/2+1
		for x = i to map.w-i-1
			call Draw(x,i,g.wall)
		next x
		for y = i to map.h-i-1
			call draw(map.w-1-i,y,g.wall)
		next y
		for x = i to map.w-i-1
			call draw(map.w-1-x,map.h-1-i,g.wall)
		next x
		for y = i to map.h-i-1
			call draw(i,map.h-1-y,g.wall)
		next y
		i = i + 1
	wend
endproc
;
;		Initialise 
;
proc initialise()
	graphic = alloc(512):load "fargoal.dat",graphic:palette 2,0,6
	map.w = 40:map.h = 29:map = alloc(map.w * map.h)
	map.rooms = map.w * map.h / 110
	dim room.x(map.rooms),room.y(map.rooms)
	g.wall = &0324:g.space = &0020:g.temple = &0226:g.sword = &0225
	g.stairs.down = &0123:g.gold = &032F:g.traps = &0200:g.stairs.up = &0122
	;
	dim m.prefix$(19),m.name$(19),m.graphic(19),m.type(19):n = 0
	call loadMonster("an,ogre,27,a,barbarian,41,a,hobgoblin,27,an,elvin ranger,41,a,werebear,27,a,dwarven guard,43,a,gargoyle,28")
	call loadMonster("a,mercenary,41,a,troll,27,a,swordsman,41,a,wyvern,30,a,monk,41,a,dimension spider,29,a,dark warrior,41")
	call loadMonster("a,shadow dragon,30,an,assassin,40,a,fyre drake,30,a,war lord,41")
	m.noise$ = "crunch,clang,claw,ouch!,gnarl,slash,ugh!,clink,growl!,chop,shred,thud,thump,shriek!"
	m.noise.count = sub.count(m.noise$,",")
	;
	dim m.x(19),m.y(19),m.hitpoint(19),m.damage(19),m.strength(19)
endproc
;
proc loadMonster(d$)
	local i
	for i = 1 to sub.count(d$,",") step 3
		m.prefix$(n) = sub.get$(d$,",",i):m.name$(n) = sub.get$(d$,",",i+1)
		m.graphic(n) = to.number(sub.get$(d$,",",i+2))+(random(1,3)*256)
		m.type(n) = (n mod 2)+1
		n = n + 1
	next i
endproc


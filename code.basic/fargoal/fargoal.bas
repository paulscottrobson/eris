'
'		Sword of Fargoal
'
'	Todo:
'		Player move loop / actions
'		Monster move loop
'		Collect things
'		Fighting
'
!&FFFD = 1
randomise 6
screen 2,2:cls
call initialise()
call reset.player()
call create.level.map(level,level = sword.level,sword.found)
call player.new.level()
if has.map(level) or true then call wake.all.monsters():call show.map()
;call spiral.draw()
call player.open()
end
;
;		Open squares around player
;
proc player.open()
	local x,y,m
	for x = player.x-1 to player.x+1
		for y = player.y-1 to player.y+1
			m = !(map+x+y*map.w)
			if (m and &FF00) = &0F00 then call wake.monster(m and &FF):m = g.space
			call Draw(x,y,m,true)
		next y
	next x
endproc
;
;		Wake all monsters
;
proc wake.all.monsters()
	local r
	for r = 0 to monster.count-1
		if not m.active(r) then call wake.monster(r)
	next r
endproc
;
;		Wake an individual monster
;
proc wake.monster(n)
	!(map+m.x(n)+m.y(n)*map.w) = g.space
	m.active(n) = true
	sprite n to m.x(n)*8,m.y(n)*8+8 ink m.type(n)+1 draw m.graphic(n)-26
endproc
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
	player.sprite = 20
endproc
;
;		Player enters new level
;
proc player.new.level()
	local x,y
	hidden.gold.count = 0:pit.change = 0:light.on = false
	autoheal.rate = 50:monster.speed = max(20-level,1)
	deepest.level = max(level,deepest.level)
	call get.empty():player.x = x:player.y = y
	sprite player.sprite to x*8,y*8+8 ink 1 draw 0
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
	monster.count = random(3,9)
	for r = 0 to monster.count-1
		call get.empty():m.x(r) = x:m.y(r) = y
		m.damage(r) = 1:m.active(r) = false
		!(map+x+y*map.w) = &0F00+r
	next r
endproc
;
;		Paint the map
;
proc show.map()
	local x,y
	for y = 0 to map.h-1:for x = 0 to map.w-1:call draw(x,y,map!(x+y*map.w),true):next x:next y
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
proc draw(x,y,c,e)
	if e then ink 0:rect x*8,y*8+8 to x*8+7,y*8+15:ink 1
	blit x*8,y*8+8,graphic+(c and 255)*8,&0300+(c >> 8),8
endproc
;
;		Spiral Draw
;
proc spiral.draw()
	local i,x,y,t = 0
	while i <  map.h/2+1
		for x = i to map.w-i-1
			call Draw(x,i,g.wall,true)
		next x
		for y = i to map.h-i-1
			call draw(map.w-1-i,y,g.wall,true)
		next y
		for x = i to map.w-i-1
			call draw(map.w-1-x,map.h-1-i,g.wall,true)
		next x
		for y = i to map.h-i-1
			call draw(i,map.h-1-y,g.wall,true)
		next y
		i = i + 1
	wend
endproc
;
;		Initialise 
;
proc initialise()
	local i
	graphic = alloc(512):load "fargoal.dat",graphic:palette 2,0,6
	palette 1,1,5:palette 2,1,7
	map.w = 40:map.h = 29:map = alloc(map.w * map.h)
	map.rooms = map.w * map.h / 100
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
	call sprite.copy(0,26)
	for i = 27 to 41:call sprite.copy(i-26,i):next i
	;
	dim m.x(19),m.y(19),m.hitpoint(19),m.damage(19),m.strength(19),m.active(19)
	dim has.map(25):for i = 0 to 25:has.map(i) = false:next i	
endproc
;
proc loadMonster(d$)
	local i,r
	for i = 1 to sub.count(d$,",") step 3
		r = n
		m.prefix$(r) = sub.get$(d$,",",i):m.name$(r) = sub.get$(d$,",",i+1)
		m.graphic(r) = to.number(sub.get$(d$,",",i+2))
		m.type(r) = (n mod 2)+1
		n = n + 1
	next i
endproc
;
proc sprite.copy(spriteID,gfxID)
	local i
	spriteID = spriteID * 16 + sysvar(3):gfxID = gfxID * 8 + graphic
	for i = 0 to 15:spriteID!i = 0:next i
	for i = 0 to 7:spriteID!(i+8) = gfxID!i >> 8::next i
endproc
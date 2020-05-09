' **************************************************************************************************
'
'										Space Invaders
'
' **************************************************************************************************
'
cls:screen 2,2:palette 1,1,5
call initialise()
call new.game()
call new.level()
repeat
	call play.level()
until game.lives = 0
cls:end
'
'		Play one level
'
proc play.level()
	life.lost = false
	e.pMissile = 0:e.iMove = 0:e.pMove = 0:e.sMove = 0:i.speed = 0:e.killExplosion = -1
	e.m(1) = 0:e.m(2) = 0
	repeat
		if event(e.iMove,i.speed) then call move.invaders()
		if event(e.pMove,9) then call move.player()
		if event(e.sMove,6) then call move.saucer()
		if pm.x > 0 then if event(e.pMissile,5) then call move.pmissile()
		if event(e.m(1),11) then call move.emissile(1)
		if event(e.m(2),11) then call move.emissile(2)
		if event(e.killExplosion,20) then sprite 15 to -10,-10:e.killExplosion = -1
	until life.lost or inv.count = 0
	if life.lost 
		game.lives = game.lives-1:call update.lives()
		call reset.inv.missiles()
		sound 0,150,10:e.pMove = 0
		while not event(e.pMove,150)
			sprite 0 ink random(0,3)
		wend
		sprite 0 ink 2
	else
		game.level = game.level+1
		call new.level()
	endif

endproc
'
'		Move player
'
proc move.player()
	local x
	if joyx() <> 0
		x = player.dx + joyx()*2
		if abs(x) <= 6 then player.dx = x
	else
		if player.dx <> 0 then player.dx = (abs(player.dx)-1)*sgn(player.dx)
	endif
	player.x = max(4,min(player.x+player.dx,316))
	sprite 0 to player.x,player.y
	if joyb(1)<>0 and pm.x < 0 
		pm.x = player.x:pm.y = player.y-8:sprite 1 to pm.x,pm.y:e.pMissile = 0
		sound 2,4444,2
	endif
endproc
'
'		Move player missile
'
proc move.pMissile()
	pm.y = pm.y - 8
	if pm.y < 16 then pm.x = -10
	if pm.y >= sh.y1 and pm.y < sh.y2 then call hit.shield(pm.x,pm.y):if hit then pm.x = -10
	if pm.y >= inv.y+16 and pm.y < inv.y+inv.lowest * 16+16
		local d = abs(pm.x-inv.x) and 15
		if pm.x >= inv.x+inv.left*16 and pm.x < inv.x+inv.right*16+16 and d >= 3 and d <= 13 then call hit.invader()
	endif
	if hit(1,5) 
		call reset.saucer()
		game.score = game.score + 10:call update.score()
		sound 0,1000,4
	endif
	sprite 1 to pm.x,pm.y
endproc
'
'		Move enemy missile
'
proc move.eMissile(n)
	if mx(n) < 0
		if inv.count > 0 then call fire.eMissile(n)
	else
		my(n) = my(n)+8:if my(n) > 240 then mx(n) = -10
	endif
	if my(n) >= sh.y1 and my(n) < sh.y2 then call hit.shield(mx(n),my(n)):if hit then mx(n) = -10
	sprite n+2 to mx(n),my(n)
	if hit(0,n+2,8) then life.lost = True
endproc	
'
'
'
proc fire.eMissile(n)
	local r,i,t
	repeat:r = random(1,inv.width-2):until col.count(r) <> 0
	t = inv.map+5+r+inv.width
	mx(n) = r*16+inv.x+8
	for i = 1 to 5
		if (!t and &FF) < 4 then my(n) = i*16+inv.y+16
		t = t + inv.width
	next i
endproc
'
'		Check hit invader
'
proc hit.invader()
	local x = (pm.x-inv.x) >> 4
	local y = (pm.y-inv.y) >> 4
	local t = inv.map+5+x+y*inv.width
	if (!t and &FF) < 4
		pm.x = -10:!t = &1F
		inv.count = inv.count - 1
		col.count(x) = col.count(x)-1:row.count(y) = row.count(y)-1
		tile inv.x,inv.y,0,0,inv.width,inv.height+1,inv.map
		if col.count(x) = 0  then call calc.left.right()
		if row.count(y) = 0  then call calc.lowest()
		game.score = game.score + 3 - y/2:call update.score()
		sound 0,1000,4
		sprite 15 ink 3 draw 3 to inv.x+x*16+8,inv.y+y*16+8
		e.killExplosion = 0
	endif	
endproc
'
'		Calc lowest row
'
proc calc.lowest()
	local i:inv.lowest = 0
	for i = 1 to inv.height
		if row.count(i) <> 0 then inv.lowest = i
	next i
endproc
'
'		Calc left/right boundaries
'
proc calc.left.right()
	local i
	inv.left = inv.width-2:inv.right = 1
	for i = 1 to inv.width-2
		if col.count(i) <> 0 then inv.left = min(inv.left,i):inv.right = max(inv.right,i)
	next i
endproc
'
'		Check hit shield
'
proc hit.shield(x,y)
	x = x >> 3:y = (y - sh.y1) >> 3
	hit = false
	if shields(x,y) > 0
		hit = true
		local n = shields(x,y)-1
		ink 0:shields(x,y) = n
		x = x * 8:y = y * 8 + sh.y1:ink 0:draw x,y,n+4:ink 1
	endif
endproc
'
'		Move invaders
'
proc move.invaders()
	local c,p = sysvar(3)
	i.speed = 6+inv.count*2
	inv.x = inv.x + inv.dx * 4 
	if inv.x+inv.left*16 < 4 or inv.x+inv.right*16 > 300
		inv.dx = -inv.dx:inv.y = inv.y+8:inv.x = inv.x + inv.dx * 4
		if inv.y + inv.lowest*16 > player.y-24 then life.lost = true
	endif
	inv.frame = inv.frame + 1
	c = &420:if inv.frame and 1 then c = &1008
	p!15 = c:p!31=c:p!47=c
	tile inv.x,inv.y,0,0,inv.width,inv.height+1,inv.map	
	sound 1,48000+(inv.frame and 3)*2000,1
endproc
'
'		Set up game
'
proc initialise()
	sprite load "invaders.spr"
	inv.width = 13:inv.height = 5:rem "One row of spaces on left and right"
	inv.map = alloc(inv.width*inv.height+inv.width+5)
	!inv.map = &ABCD:inv.map!1 = 16:inv.map!2 = inv.width:inv.map!3 = inv.height+1:inv.map!4 = 0
	dim shields(39,3),col.count(inv.width-1),row.count(inv.height),mx(2),my(2),e.m(2)
	palette 1,0,6:game.hiScore = 100
endproc
'
'		Update score
'
proc update.score()
	local a$ = right$("00000"+str$(game.score),5)
	cursor 13-3,1:ink 1:print a$;"0";
	if game.score > game.hiScore then game.hiScore = game.score:cursor 26-3,1:print a$;"0";
endproc
'
'		Update lives display
'
proc update.lives()
	local i
	for i = 1 to 5
		ink 0:if game.lives >= i then ink 1
		draw i*20-12,232,8
	next i:ink 2
endproc
'
'		New game
'
proc new.game()
	game.level = 1:game.score = 0:game.lives = 3
endproc
'
'		Reset the saucer
'
proc reset.saucer()
	saucer.x = random(500,1000):saucer.y = 24	
	if saucer.x < 320 
		sprite 5 ink 1 draw 9 to saucer.x,saucer.y
	else
		sprite 5 to -10,-10
	endif
endproc
'
'		Move saucer
'
proc move.saucer()
	saucer.x = saucer.x-3:if saucer.x < 320 then sprite 5 to saucer.x,saucer.y
	if saucer.x < 0 then call reset.saucer()
endproc
'
'		New level - reset invaders, shields, score
'
proc new.level()
	local x,y,p,c,d,i
	cls:call update.score():call update.lives()
	ink 2:line 0,230 to 319,230
	ink 3:text 255,232,"CREDIT":ink 1:text 300,232,"00"
	for i = 0 to inv.width-1:!(inv.map+5+i) = &01F:next i
	for y = 0 to inv.height-1
		row.count(y+1) = inv.width-2
		p = inv.map+5+inv.width*(y+1)
		c = (y+1)/2
		p!0 = &01F:p!(inv.width-1) = &01F
		for x = 1 to inv.width-2
			p!x = &100+c*&101
		next x
	next y
	for i = 1 to inv.width-2:col.count(i) = inv.height:next i
	inv.count = (inv.width-2)*inv.height
	call calc.lowest():call calc.left.right()
	inv.x = 160-inv.width*8:inv.y = 16+3*game.level:inv.dx = 1
	;tile inv.x,inv.y,0,0,inv.width,inv.height+1,inv.map
	ink 3:cursor 26-4,0:print "HI-SCORE";:cursor 13-4,0:print "SCORE<1>";:cursor 39-4,0:print "SCORE<2>";
	ink 1:cursor 26-3,1:print right$("00000"+str$(game.hiScore),5);"0";:cursor 39-3,1:print "000000";
	sh.y1 = 176:sh.y2 = sh.y1+32
	for i = 1 to 3
		x = 80*i-8
		for c = -1 to 1
			blit x+c*16,sh.y1,7,&0302,16
			blit x+c*16,sh.y1+16,7,&0302,16
		next c
		for y = 0 to 3
			d = (x-16) >> 3:for p = 0 to 5:shields(p+d,y) = 3:next p
		next y
	next i
	player.x = 120:player.y = 224:sprite 0 ink 2 draw 8 to player.x,player.y:player.dx = 0
	pm.x = -10:pm.y = 0:sprite 1 ink 1 draw 10 to pm.x,pm.y
	call reset.inv.missiles()
	call reset.saucer()
endproc
'
proc reset.inv.missiles()
	local i
	for i = 1 to 2:mx(i) = -10:e.m(i) = 0:sprite i+2 ink 1 draw 10 to -10,0:next i
endproc



' **************************************************************************************************
'
'										Space Invaders
'
' **************************************************************************************************

'	Player shoot fix hitting things
'	Invaders shoot fix aiming and hitting things
'	Flying saucer
'
screen 2,2:palette 1,1,5
call initialise()
call new.game()
call new.level()
call play.level()
end
'
'		Play one level
'
proc play.level()
	life.lost = false
	e.pMissile = 0:e.iMove = 0:e.pMove = 0:i.speed = 0
	repeat
		if event(e.iMove,i.speed) then call move.invaders()
		if event(e.pMove,12) then call move.player()
		if pm.x > 0 then if event(e.pMissile,5) then call move.pmissile()
		if event(e.m(1),7) then call move.emissile(1)
		if event(e.m(2),7) then call move.emissile(2)
	until life.lost or inv.count = 0
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
	endif
endproc
'
'		Move player missile
'
proc move.pMissile()
	pm.y = pm.y - 8
	if pm.y < 16 then pm.x = -10
	sprite 1 to pm.x,pm.y
endproc
'
'		Move enemy missile
'
proc move.eMissile(n)
	if mx(n) < 0
		mx(n) = random(10,310):my(n) = 40
	else
		my(n) = my(n)+8:if my(n) > 240 then mx(n) = -10
	endif
	sprite n+2 to mx(n),my(n)
	if hit(0,n+2,8) then life.lost = True
endproc	
'
'		Move invaders
'
proc move.invaders()
	local c,p = sysvar(3)
	i.speed = 6+inv.count*2
	inv.x = inv.x + inv.dx * 4
	if inv.x+inv.left*16 < 4 or inv.x+inv.right*16 > 316
		inv.dx = -inv.dx:inv.y = inv.y+8
		if inv.y + inv.lowest*16 > player.y then life.lost = true
	endif
	inv.frame = inv.frame + 1
	c = &420:if inv.frame and 1 then c = &1008
	p!15 = c:p!31=c:p!47=c
	tile inv.x,inv.y,0,0,inv.width,inv.height+1,inv.map
endproc
'
'		Set up game
'
proc initialise()
	sprite load "invaders.spr"
	inv.width = 13:inv.height = 5:rem "One row of spaces on left and right"
	inv.map = alloc(inv.width*inv.height+inv.width+5)
	!inv.map = &ABCD:inv.map!1 = 16:inv.map!2 = inv.width:inv.map!3 = inv.height+1:inv.map!4 = 0
	dim shields(39,5),col.count(inv.width-1),mx(2),my(2),e.m(2)
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
'		New level - reset invaders, shields, score
'
proc new.level()
	local x,y,p,c,d,i
	cls:call update.score():call update.lives()
	ink 2:line 0,230 to 319,230
	ink 3:text 255,232,"CREDIT":ink 1:text 300,232,"00"
	for i = 0 to inv.width-1:!(inv.map+5+i) = &01F:next i
	for y = 0 to inv.height-1
		p = inv.map+5+inv.width*(y+1)
		c = (y+1)/2
		p!0 = &01F:p!(inv.width-1) = &01F
		for x = 1 to inv.width-2
			p!x = &100+c*&101
		next x
	next y
	for i = 1 to inv.width-2:col.count(i) = height:next i
	inv.count = (inv.width-2)*inv.height
	inv.lowest = inv.height:inv.left = 1:inv.right = inv.width-1
	inv.x = 160-inv.width*8:inv.y = 32:inv.dx = 1
	;tile inv.x,inv.y,0,0,inv.width,inv.height+1,inv.map
	ink 3:cursor 26-4,0:print "HI-SCORE";:cursor 13-4,0:print "SCORE<1>";:cursor 39-4,0:print "SCORE<2>";
	ink 1:cursor 26-3,1:print "000000";:cursor 39-3,1:print "001000";
	sh.y1 = 180:sh.y2 = sh.y1+24
	for x = 0 to 39:for y = 0 to 4:shields(x,y) = false:next y:next x
	for i = 1 to 3
		x = 80*i
		for c = -1 to 1
			d = &10:if c > 0 then d = &4010
			blit x+c*16,sh.y1,7-abs(c)*2,&0302,d
			blit x+c*16,sh.y1+16,6,&0302,16
		next c
		for y = 0 to 4
			d = (x-32) >> 3:for p = 0 to 5:shields(p+d,y) = true:next p
		next y
	next i
	player.x = 160:player.y = 224:sprite 0 ink 2 draw 8 to player.x,player.y:player.dx = 0
	pm.x = -10:pm.y = 0:sprite 1 ink 1 draw 4 to pm.x,pm.y
	for i = 1 to 2:mx(i) = 0:e.m(i) = 0:sprite i+2 ink 1 draw 4 to -10,0:next i
endproc

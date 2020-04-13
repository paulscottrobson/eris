' **************************************************************************************************
'
'										Space Invaders
'
' **************************************************************************************************

'	Lives display
'	Play level. Reset base position.
'	Move base. 
'	Invaders move pattern. 
'	Invaders shoot
'	Player shoot
'	Flying saucer
'
screen 2,2
call initialise()
call new.game()
call new.level()
end
'
'		Set up game
'
proc initialise()
	sprite load "invaders.spr"
	inv.width = 13:inv.height = 5:rem "One row of spaces on left and right"
	inv.map = alloc(inv.width*inv.height+5)
	!inv.map = &ABCD:inv.map!1 = 16:inv.map!2 = inv.width:inv.map!3 = inv.height:inv.map!4 = 0
	dim shields(39,4),col.count(inv.width-1)
	palette 1,0,6:game.hiScore = 100
endproc
'
'		Update score
'
proc update.score()
	local a$ = right$("00000"+str$(game.score),5)
	cursor 13-3,1:ink 3:print a$;"0";
	if game.score > game.hiScore then game.hiScore = game.score:cursor 26-3,1:print a$;"0";
endproc
'
'		New game
'
proc new.game()
	game.level = 1:game.score = 0:call update.score():game.lives = 3
endproc
'
'		New level - reset invaders, shields, score
'
proc new.level()
	local x,y,p,c,d,i
	for y = 0 to inv.height-1
		p = inv.map+5+inv.width*y
		c = (y+1)/2
		p!0 = &01F:p!(inv.width-1) = &01F
		for x = 1 to inv.width-2
			p!x = &100+c*&101
		next x
	next y
	for i = 1 to inv.width-2:col.count(i) = 5:next i
	im.x = 160-inv.width*8:im.y = 32:im.dx = random(0,1)*2-1
	tile im.x,im.y,0,0,inv.width,inv.height,inv.map
	ink 3:cursor 26-4,0:print "HI-SCORE";:cursor 13-4,0:print "SCORE<1>";:cursor 39-4,0:print "SCORE<2>";
	cursor 26-3,1:print "000000";
	cursor 39-3,1:print "001000";
	for x = 0 to 39:for y = 0 to 4:shields(x,y) = false:next y:next x
	for i = 1 to 3
		x = 80*i
		for c = -1 to 1
			d = &10:if c > 0 then d = &4010
			blit x+c*16,180,12-abs(c)*2,&0302,d
			blit x+c*16,196,11,&0302,16
		next c
		for y = 0 to 4
			d = (x-32) >> 3:for p = 0 to 5:shields(p+d,y) = true:next p
		next y
	next i
endproc

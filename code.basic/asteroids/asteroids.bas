' ********************************************
'				Asteroids Game
' ********************************************

call initialise()
call new.level(13,20)
call new.player()
call show(0)
repeat
	if event(e.move,6) then sys move.all
until false
end
'
'	Set up game
'
proc initialise()
	local i
	cls:screen 2,2:sprite load "asteroids.spr":palette 3,0,7
	dim p.char(23),p.flip(23),sine(23),cosine(23)
	rem "Set up data for rotating ship"
	for i = 0 to 11
		p.char(i) = i mod 7:p.flip(i) = &0010
		if i >= 7 then p.char(i) = 12-i:p.flip(i) = &2010
		p.char(i) = sysvar(3)+p.char(i)*16
		p.char(i+12) = p.char(i):p.flip(i+12) = p.flip(i) xor &6000
	next i
	rem "Set up sine and cosine tables"
	sine(1) = 66:sine(2) = 128:sine(3) = 181:sine(4) = 222:sine(5) = 247:sine(6) = 256
	for i = 0 to 6:sine(12-i) = sine(i):next i
	for i = 0 to 11:sine(i+12) = -sine(i):next i
	for i = 0 to 23:cosine(i) = sine((6+24-i) mod 24):next i
	rem "Set up the RPL code"
	call setup.code()
	rem "Set up object data"
	mCount = 4:aCount = 32:oCount = mCount+aCount+1
	objects = alloc(16*(mCount+aCount+1)):rem "Memory for objects"
	dim q.mi(4),q.as(32):rem "Queues for missiles and objects"	
endproc
'
'		Set up new level
'
proc new.level(nAst,speed)
	local i:level.speed = speed
	for i = 0 to aCount+mCount+1:!(objects+i*16+6) = 0:next i
	for i = 1 to aCount:q.as(i) = i + mCount:next i:qt.as = aCount
	asteroid.count = 0
	for i = 1 to nAst
		call create.asteroid(random(),random(),random(0,23),i mod 3+1)
	next i
endproc
'
'		Initialise player
'
proc new.player()
	local i:local p = objects:p.angle = 0
	p!0 = &8000:p!1 = &8000
	p!2 = 0:p!3 = 0:p!4 = -1:p!5 = -1	
	p!6 = 9:p!7 = p.char(0):p!8 = &0303:p!9 = p.flip(0)
	for i = 1 to mCount
		!(objects+i*16+6) = 0
		q.mi(i) = i
	next i:qt.mi = mCount
endproc
'
'		Create an asteroid
'
proc create.asteroid(x,y,angle,s)
	if qt.as > 0
		local n = q.as(qt.as)
		local p = n*16+objects
		rem "print p,q.as(qt.as),qt.as"
		qt.as = qt.as - 1
		asteroid.count = asteroid.count+1
		p!0 = x:p!1 = y
		p!2 = cosine(angle)*s*level.speed/10
		p!3 = sine(angle)*s*level.speed/10
		p!4 = 0:p!5 = 0
		p!6 = 16:g = 8:p!8 = &0303:p!9 = &1010:p!10 = s:p!11 = angle
		if s = 2 then p!9 = &10:p!6 = 8
		if s = 3 then p!9 = &10:p!6 = 4:g = 9
		p!7 = sysvar(3)+g*16
		p!9 = p!9 + random(0,3)*&2000
	endif
endproc
'
'		Show object
'
proc show(p)
	p = p * 16 + objects:sys ltop.x:sys ltop.y:sys draw.on
endproc
'
'	Create RPL Code
'
proc setup.code()
	code alloc(1024),0
	rem "(addr offset - ) copy word to address"
		blitter.copy = rpl(#p + @ swap !)
	rem "( - ) wait for blitter"
		wait.blitter = rpl(0 2 sys drop)
	rem "(mask - ) display data to blitter masking colourmask with given mask"
		draw.masked = rpl(wait.blitter &FF20 4 blitter.copy &FF21 5 blitter.copy &FF22 7 blitter.copy #p 8 + @ and &FF23 ! &FF24 9 blitter.copy)
	rem "( - ) show or hide given display object"
		draw.on = rpl(&FFFF draw.masked)
		draw.off = rpl(&FF00 draw.masked)
	rem "( - ) convert logical to physical positions"
		ltop.x = rpl(#p @ bswap &ff and 5 * >> >> #p 6 + @ - #p 4 + ,!)
		ltop.y = rpl(#p 1 + @ bswap &ff and #p 6 + @ - #p 5 + ,!)
	rem "(addr - equal) move "		
		move.1 = rpl(^t #t @ dup #t 2 + @ + #t ! #t @ xor &FF00 and 0= 0=)
		move.it = rpl(#p move.1 #p 1 + move.1 or if draw.off ltop.x ltop.y draw.on then)		
	rem "(addr - ) move.check"
		move.check = rpl(#p 6 + @ if move.it then)
	rem "( - ) move.all"
		move.all = rpl(#oCount 1 + for i 16 * #objects + dup ^p 6 + @ if move.check then  next)
endproc
;
;	Memory Allocation for each element.
;
;		0 = Player, 1+ Missiles, later = Asteroids
;
;	+0 		X Position (64k)
;	+1		Y Position (64k)
;	+2 		X Move (64k)
;	+3 		Y Move (64k)
;	+4 		X Current (scaled), centred
;	+5 		Y Current (scaled), centred
;' 	+6 		Radius (scaled) (if zero, then not in use)
; 	+7 		Graphic address
; 	+8 		Colour word
; 	+9 		Control word
;	+10 	Life (missiles only) before self destructing
;	+10 	Size (asteroids only)
;	+11 	Angle (asteroids only)
;

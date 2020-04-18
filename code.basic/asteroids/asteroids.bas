' ********************************************
'				Asteroids Game
' ********************************************

call initialise()

count = 45:dim s(count)
for i = 0 to count-1
	test = alloc(10):s(i) = test
	test!0 = (i mod 6) * &1200+&1000:test!1 = (i / 6) * &1200+&1000
	test!2 = random(100,512)*(random(0,1)*2-1)
	test!3 = random(100,512)*(random(0,1)*2-1)
	test!4 = 0:test!5 = 0
	test!6 = 8
	test!7 = sysvar(3)+8*16:test!8 = &0303:test!9 = p.flip(i mod 24)
next i

t1 = timer()
for i = 1 to 100
	for j = 0 to count-1
		p = s(j):sys draw.off:sys ltop.x:sys ltop.y
		p!7 = p.char((i+j) mod 24)
		p!9 = p.flip((i+j) mod 24)
		sys draw.on
	next j
next i
print timer()-t1
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
	objects = alloc(32*16):rem "Memory for objects"
	dim q.mi(4),q.as(32):rem "Queues for missiles and objects"
endproc
;
;	Memory Allocation for each element.
;
;		0 = Player, 1-4 = Missiles, 5-31 = Asteroids
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
;
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
endproc

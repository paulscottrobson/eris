' ********************************************
'				Asteroids Game
' ********************************************

cls:screen 2,2:sprite load "asteroids.spr":palette 3,0,7
call setup.code()

for i = 0 to 15:draw i*20,20,i:next i	
ink 1:line 160,0 to 160,239:line 0,128 to 319,128

count = 25:dim s(count)
for i = 1 to count
	test = alloc(10):s(i) = test
	test!0 = &8000:test!1 = &8000
	test!2 = random(100,512)*(random(0,1)*2-1)
	test!3 = random(100,512)*(random(0,1)*2-1)
	test!4 = 0:test!5 = 0
	test!6 = 8
	test!7 = sysvar(3)+8*16:test!8 = &0303:test!9 = &2010
next i

t1 = timer()
for i = 1 to 1000
	for j = 1 to count
		p = s(j):sys move.2
	next j
next i
print timer()-t1
end




;
;	+0 		X Position (64k)
;	+1		Y Position (64k)
;	+2 		X Move (64k)
;	+3 		Y Move (64k)
;	+4 		X Current (scaled), centred
;	+5 		Y Current (scaled), centred
;' 	+6 		Radius (scaled)
; 	+7 		Graphic address
; 	+8 		Colour word
; 	+9 		Control word
;
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
		move.2 = rpl(12345 #p move.1 #p 1 + move.1 or if draw.off ltop.x ltop.y draw.on then)
endproc
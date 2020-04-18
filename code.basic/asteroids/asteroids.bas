' ********************************************
'				Asteroids Game
' ********************************************

cls:screen 2,2:sprite load "asteroids.spr":palette 3,0,7
call setup.code()

for i = 0 to 15:draw i*20,20,i:next i	
ink 1:line 160,0 to 160,239:line 0,128 to 319,128

test = alloc(10)
test!0 = &8000:test!1 = &8000
test!2 = 0:test!3 = 0
test!4 = 0:test!5 = 0
test!6 = 8
test!7 = sysvar(3)+2*16:test!8 = &0303:test!9 = &2010

test!4 = (test!0 >> 8)*5/4 - test!6
test!5 = (test!1 >> 8) - test!6
print test!0,test!0 >> 8,test!4,test!5
;blit test!4,test!5,test!7,test!8,test!9
p = test:print blitter.copy-draw.off
for i = 1 to 10000:sys draw.on:next
end




;
;	+0 		X Position (64k)
;	+1		Y Position (64k)
;	+2 		X Move (64k)
;	+3 		Y Move (64k)
;	+4 		X Current (scaled), centred
;	+5 		Y Current (scaled), centred
' 	+6 		Radius (scaled)
; 	+7 		Graphic address
; 	+8 		Colour word
; 	+9 		Control word
;
proc setup.code()
	code alloc(1024),0
	rem "(addr offset - ) copy word to address"
		blitter.copy = rpl(#p + @ swap !)
	rem "( - ) wait for blitter"
		wait.blitter = rpl(0 2 sys)
	rem "(mask - ) display data to blitter masking colourmask with given mask"
		draw.masked = rpl(wait.blitter &FF20 4 blitter.copy &FF21 5 blitter.copy &FF22 7 blitter.copy #p 8 + @ and &FF23 ! &FF24 9 blitter.copy)
	rem "( - ) show or hide given display object"
		draw.on = rpl(&FFFF draw.masked)
		draw.off = rpl(&FF00 draw.masked)
endproc
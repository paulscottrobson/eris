
cls
call drawGame(2,4,5)
ink 4:rect 10,10 to 16,26
end


'
'		Game type. Bit 0 hockey goals, bit 1 solid wall on RHS, bit 2 2 bats / side
'
proc drawGame(gameType,lScore,rScore)
	cls:ink 2
	local y
	goal.width = 100
	for y = 0 to 220 step 20:rect 160-2,y to 160+2,y+10:next y
	for y = 0 to 235 step 235:rect 0,y to 319,y+4:next y
	if gameType and 1 
		for x = 0 to 315 step 315
			rect x,0 to x+4,120-goal.width/2
			rect x,239 to x+4,120+goal.width/2
		next x
	endif
	if gameType and 2 then rect 315,0 to 319,239

	ink 3
	call drawDigit(160-30,16,14,14,lScore mod 10)
	call drawDigit(160-50,16,14,14,lScore/10)
	call drawDigit(160+16,16,14,14,rScore/10)
	call drawDigit(160+36,16,14,14,rScore mod 10)
endproc
'
'		7 segment display
'
proc drawDigit(x,y,xs,ys,digit)
	if seg7.init = 0 
		seg7.init = 1
		dim seg7.patterns(10)
		seg7.patterns(0) = &3F
		seg7.patterns(1) = &0C
		seg7.patterns(2) = &76
		seg7.patterns(3) = &5E
		seg7.patterns(4) = &4D
		seg7.patterns(5) = &5B
		seg7.patterns(6) = &7B
		seg7.patterns(7) = &0E
		seg7.patterns(8) = &7F
		seg7.patterns(9) = &5F
	endif
	call drawPattern(x,y,xs,ys,seg7.patterns(digit))
endproc

proc drawPattern(x,y,xs,ys,pattern)
	local w = (xs+ys)/8:if w = 0 then w = 1
	if pattern and 1 then rect x,y to x+w,y+xs
	if pattern and 2 then rect x,y to x+xs,y+w
	if pattern and 4 then rect x+xs-w,y to x+xs,y+ys
	if pattern and 8 then rect x+xs-w,y+ys to x+xs,y+ys*2
	if pattern and 16 then rect x,y+ys*2-w to x+xs,y+ys*2
	if pattern and 32 then rect x,y+ys to x+w,y+ys*2
	if pattern and 64 then rect x,y+ys-w/2 to x+xs,y+ys-w/2+w
endproc




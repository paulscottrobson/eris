
'
'	First go at a sprite editor. 
'	This is very much dog food.
'	
screen 4,0:cls
call initialise():call codeRoutine()
if exists("sprites.dat") then load "sprites.dat",sprites.addr
call redrawSelector():call redrawDisplay()
prompt$ = "Next Back Copy Paste Quit XFlip YFlip Invert"
cursor 26-len(prompt$)/2,28
for i = 1 to len(prompt$)
	c$ = mid$(prompt$,i,1)
	if c$ <= "Z" ink 3 else ink 2 endif
	print c$;
next i
ink 6:a$ = "Sprite Editor 1.0 (Dogfood version)"
cursor 27-len(a$)/2,29:print a$;
repeat
	call mainLoop()
	command$ = upper$(inkey$())
	if command$ = "N" then sprites.current=(sprites.current+1) and 15:call redrawSelector():call redrawDisplay()
	if command$ = "B" then sprites.current=(sprites.current-1) and 15:call redrawSelector():call redrawDisplay()
	if command$ = "C" 
		for i = 0 to 15:clip(i) = !(sprites.addr+sprites.current*16+i):next i
	endif
	if command$ = "P" 
		for i = 0 to 15:!(sprites.addr+sprites.current*16+i) = clip(i):next i
		call redrawDisplay()
		call redrawSelector()
	endif
	if command$ = "X":
		for i = 0 to 15
			v = !(sprites.addr+sprites.current*16+i):w = 0
			for b = 0 to 15
				if (v and bits(b)) <> 0 then w = w or bits(15-b)
			next b
			!(sprites.addr+sprites.current*16+i) = w
		next i
		call redrawDisplay()
		call redrawSelector()
	endif
	if command$ = "I":
		for i = 0 to 15
			v = !(sprites.addr+sprites.current*16+i)
			!(sprites.addr+sprites.current*16+i) = v xor &FFFF
		next i
		call redrawDisplay()
		call redrawSelector()
	endif
	if command$ = "Y"
		for i = 0 to 15:temp(i) = !(sprites.addr+sprites.current*16+i):next i
		for i = 0 to 15:!(sprites.addr+sprites.current*16+i) = temp(15-i):next i
		call redrawDisplay()
		call redrawSelector()
	endif	
until command$ = "Q"
save "sprites.dat",sprites.addr,256
cls
end
'
'	Main loop code
'
proc mainloop()
	if !systemTimer-nextMove >= 0
		nextMove = !systemTimer + 12
		local x = (cursor.x+joyx()) and 15
		local y = (cursor.y+joyy()) and 15
		if x <> cursor.x or y <> cursor.y 
			local oldY:oldY = cursor.y
			cursor.x = x:cursor.y = y
			call redrawLine(cursor.y)
			if oldY <> cursor.y then call RedrawLine(oldy)
		endif
		if joyb(1) <> 0 then call setPixel(cursor.x,cursor.y,1)
		if joyb(2) <> 0 then call setPixel(cursor.x,cursor.y,0)
	endif
endproc
'
'	Set or clear pixel
'
proc setPixel(x,y,isSet)
	local addr:addr = sprites.addr+sprites.current*16+y
	if isSet
		!addr = !addr or bits(x)
	else
		!addr = !addr and (bits(x) xor &FFFF)
	endif
	call redrawLine(y)
	call redrawOneSelector(sprites.current)
endproc
'
'	Redraw main selector
'
proc redrawSelector()
	local i
	for i = 0 to sprites.count-1
		call redrawOneSelector(i)
	next i
	local a$:a$ = " Sprite #"+str$(sprites.current)+" "
	ink 7:cursor 26-len(a$)/2,1:print a$
endproc
'
proc redrawOneSelector(i)
	local x = i/8*24+10
	local y = i mod 8*24+10
	if i = sprites.current col = 1 else col = 4 endif
	blit x,y,blockGfx,&F00+col,&8010
	if i = sprites.current col = 7 else col = 2 endif
	blit x,y,sprites.addr+i*16,&F00+col,16
endproc
'
'	Redraw whole display
'
proc redrawDisplay()
	local i
	for i = 0 to 15
		call redrawLine(i)
	next i
endproc
'
'	Redraw one line
'
proc redrawLine(y)
	local a,b,c:b = 96:c = y*8+32:a = !(sprites.addr+sprites.current*16+y):sys fastDraw
	if y = cursor.y then blit b+cursor.x*8,c,cursorGfx,&F07,8
endproc
'
'	Initialisation
'
proc initialise()
	local i,j
	dim bits(16),clip(16),temp(16)
	j = &8000:for i = 0 to 15:bits(i) = j:j = (j / 2) and &7FFF:next i
	sprites.addr = sysvar(3):sprites.count = sysvar(4):sprites.current = 0
	cursor.x = 8:cursor.y = 8
	solidGfx = alloc(8):cursorGfx = alloc(8):blockGfx = alloc(1)
	systemTimer = &FF30:nextMove = !systemTimer
	for i = 0 to 7:solidGfx!i = &FF00:cursorGfx!i = &8100:next
	cursorGfx!0 = &FF00:cursorGfx!7 = &FF00:!blockGfx=&FFFF
endproc
'
'	Fast blit routine
'
proc codeRoutine()
	fastDraw = alloc(64)
	for pass = 0 to 1
	code fastDraw,pass
		push rd
		ldm r1,r0,#0:ldm r2,r0,#1:ldm r3,r0,#2
		mov r4,#16
		.loop
		jsr #2
		stm r2,#&FF20:stm r3,#&FF21
		mov r0,#solidGfx:stm r0,#&FF22
		mov r0,#&0F01:skp r1:add r0,re,#1:stm r0,#&FF23
		mov r0,#8:stm r0,#&FF24
		add r1,r1,#0:add r2,re,#8		
		sub r4,re,#1:skz r4:jmp #loop
		pop rd:ret
	next pass
endproc

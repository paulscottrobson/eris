'
'	First go at a sprite editor. 
'	This is very much dog food.
'	
screen 4,0:cls
call initialise():call codeRoutine()
call redrawSelector():call redrawDisplay()
repeat
	call mainLoop()
	command$ = inkey$()
	if command$ <> "" then print command$
until command$ = "Q"
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
	ink 7:cursor 20,1:print "Sprite : ";sprite.current;"  "
endproc
'
'	Redraw one line
'
proc redrawLine(y)
	local a,b,c:b = 128:c = y*8+32:a = !(sprites.addr+sprites.current*16+y):sys fastDraw
	if y = cursor.y then blit b+cursor.x*8,c,cursorGfx,&F07,8
endproc
'
'	Initialisation
'
proc initialise()
	local i,j
	dim bits(16):j = &8000:for i = 0 to 15:bits(i) = j:j = (j / 2) and &7FFF:next i
	sprites.addr = sysvar(3):sprites.count = sysvar(4):sprites.current = 2
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

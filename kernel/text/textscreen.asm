; *****************************************************************************
; *****************************************************************************
;
;		Name:		textscreen.asm
;		Purpose:	Text Screen character
;		Created:	8th March 2020
;		Reviewed: 	16th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;		Write character R0 (bits 0-7 only) for control characters see 
;		documentation :)
;
; *****************************************************************************

.OSXPrintCharacter
		push 	r0,r1,r2,r3,r4,link
		;
		and 	r0,#$FF 						; mask out bits 0-7
		mov 	r3,r0,#0 						; check if it is a control char 0-31
		sub 	r3,#32
		skp		r3 		
		jmp 	#_OSPCControl 					; this handles those.
		;
		;		Standard character 32-255
		;		
		jsr 	#_OSPrintCharacterAtXY 			; write character to display.
		ldm 	r0,#xTextPos 					; move right in text coordinates
		inc 	r0
		stm 	r0,#xTextPos
		;
		;		Check if new line required (e.g. on char after far right on screen)
		;
._OSPCCheckNewLine		
		ldm 	r0,#xTextPos 					; get current text position
		xor 	r0,#charWidth 					; reached RHS ?
		skz 	r0
		jmp 	#_OSPCExit 						; if not exit.
		;
		;		Free return - go to the start of the next line - by location only
		;		no overwrite of the rest of the line.
		;
._OSPCFreeReturn
		stm 	r14,#xTextPos 					; back to left side
		ldm 	r0,#yTextPos 					; down 1 line
		inc 	r0
		stm 	r0,#yTextPos
		;
		;		Check if scrolling required.
		;
._OSPCCheckScroll		
		ldm 	r3,#yTextPos 					; check if yPosition = screen height in characters
		xor 	r3,#CharHeight
		sknz 	r3
		jsr 	#_OSPCScroll 					; scroll screen up if it is.
		;
._OSPCExit		
		pop 	r0,r1,r2,r3,r4,link 			; and exit.
		ret
		;
		;		Handle control characters, first check for set fgr colour, 16-31
		;
._OSPCControl
		add 	r3,#16 							; now 0-15 if set fgr colour
		skp 	r3 								; 0-15 are control 16-31 colour
		jmp 	#_OSPCNotColour	 				; go here if was 16-31
		stm 	r3,#fgrColour 					; set the foreground and exit.
		jmp 	#_OSPCExit
		;
		; 		Handle characters 0-15, code in R0.
		;
._OSPCNotColour
		add 	r0,#_OSPCVectors 				; point R0 into vector table
		ldm 	r0,r0,#0 						; read address to call routine
		brl 	link,r0,#0 						; call there - can exit with jump out or ret
		jmp 	#_OSPCExit
		;
		;		Vector table for control codes 0-15
		;
._OSPCVectors
		word 	_OSPCExit 						; 0 null ignored
		word 	_OSPCMoveLeft 					; 1 left
		word 	_OSPCMoveRight 					; 2 right
		word 	_OSPCMoveUp 					; 3 up
		word 	_OSPCMoveDown 					; 4 down
		word 	_OSPCExit 						; 5
		word 	_OSPCExit 						; 6
		word 	_OSPCExit 						; 7
		word 	_OSPCBackspace 					; 8 backspace
		word 	_OSPCTab 						; 9 tab
		word 	_OSPCExit 						; 10
		word 	_OSPCHome 						; 11 home cursor
		word 	_OSPCClear 						; 12 clear screen home cursor
		word 	_OSPCReturn 					; 13 carriage return
		word 	_OSPCFreeReturn 				; 14 no-clear carriage return
		word 	_OSPCSwapColours 				; 15 foreground/background swap

; *****************************************************************************
;
;						 Code for control characters 0-15
;
; *****************************************************************************

		;
		;		11 home cursor to 0,0
		;
._OSPCHome 	
		stm 	r14,#xTextPos					; home cursor
		stm 	r14,#yTextPos
		ret
		;
		;		12 clear screen/home cursor
		;
._OSPCClear 									; chr(12) clear screen home cursor
		jsr 	#OSIClearScreen 				; physically clear screen to background colour
		jsr 	#_OSPCHome 						; home cursor
		ldm 	r1,#textMemory 					; erase screen memory.
		mov 	r3,#charWidth*charHeight 		; this many words to write
		ldm 	r0,#bgrColour 					; make bgr <0> <00> e.g. a zero background
		ror 	r0,#4 							; then fill the text screen with it.
._OSPCErase
		stm 	r0,r1,#0 						; write to map
		inc 	r1 								; bump pointer
		dec		r3 								; do it for whole screen )R3_ times.
		skz		r3
		jmp 	#_OSPCErase
		jmp 	#_OSPCExit 						; exit
		;
		;		13 Carriage Return erasing rest of line.
		;
._OSPCReturn
		clr 	r0								; print null/space until new line
		jsr 	#_OSPrintCharacterAtXY 			; we use $00 because this will tell us where code listings end
		ldm 	r0,#xTextPos 					; one to the right
		inc 	r0
		stm 	r0,#xTextPos
		xor 	r0,#charWidth 					; until reached past the RHS
		skz 	r0
		jmp 	#_OSPCReturn 
		jmp 	#_OSPCFreeReturn 				; go to next line check if we need to scroll.
		;
		;		9 Tab forward to next tab stop - non destructive.
		;
._OSPCTab
		ldm 	r0,#xTextPos 					; get current position
		add 	r0,#tabStop 					; forward by the tab size
		and 	r0,#$FFFF-(tabStop-1)			; fix it to a tab stop position and write back
		stm 	r0,#xTextPos
		jmp 	#_OSPCCheckNewLine				; check off rhs and return.
		;
		;		3/4 Move up/Down
		;
._OSPCMoveUp 									; chr(1-4) move cursor.
		mov 	r0,#-1
		sknz 	r0
._OSPCMoveDown
		mov 	r0,#1
		mov 	r2,#charHeight 					; R0 is the offset,R2 the address to change
		mov 	r3,#yTextPos 					; R3 the limit
		;
		;		Code used by Left/Right/Up/Down - wraps round.
		;
._OSPCAdjust		
		ldm 	r1,r3,#0 						; read it
		add 	r1,r0,#0 						; new position
		skp 	r1 								; add size if -ve
		add 	r1,r2,#0
		sub 	r1,r2,#0 						; subtract
		skp 	r1 	
		add 	r1,r2,#0 						; re-add if gone -ve
		stm 	r1,r3,#0 						; write back
		ret	
		;
		;		1/2 Move Left/Right uses the same code with different address and limit.
		;
._OSPCMoveLeft
		mov 	r0,#-1
		sknz 	r0
._OSPCMoveRight
		mov 	r0,#1
		mov 	r2,#charWidth
		mov 	r3,#xTextPos
		jmp 	#_OSPCAdjust
		;
		;		8 back space
		;
._OSPCBackSpace 								; chr(8) backspace
		ldm 	r0,#xTextPos 					; exit if x = 0
		sknz 	r0
		ret
		dec 	r0 								; back one, save position
		stm 	r0,#xTextPos 					
		mov 	r0,#32
		jsr 	#_OSPrintCharacterAtXY 			; and erase it with a space (e.g. not EOL)
		jmp 	#_OSPCExit
		;
		;		15 Swap fgr/bgr - so you set fgr, make that bgr, and set fgr to change both	
		;
._OSPCSwapColours 								; chr(15) swap background and foreground
		ldm 	r0,#fgrColour
		ldm 	r1,#bgrColour
		stm 	r1,#fgrColour
		stm 	r0,#bgrColour
		ret

; *****************************************************************************
;
; 	  write character R0 to display in current colour at current position
;
; *****************************************************************************

._OSPrintCharacterAtXY
		push 	r0,r1,r2,link		
		ldm 	r1,#fgrColour 					; Add FGR << 8
		ror 	r1,#8
		add 	r0,r1,#0
		ldm 	r1,#bgrColour 					; Add BGR << 12
		ror 	r1,#4
		add 	r0,r1,#0 						; R0 now is the character bgr/fgr/cpde
		jsr 	#_OSSetCharDrawPos 				; set the blitter position
		jsr 	#OSIDrawSolidCharacter			; draw the character

		jsr 	#_OSCurrentTextR1				; get address of current char in text buffer
		stm 	r0,r1,#0 						; write into buffer.
		pop 	r0,r1,r2,link
		ret

; *****************************************************************************
;
;			Put the text buffer address of current character in R1
;
; *****************************************************************************

._OSCurrentTextR1
		push 	r2
		ldm 	r1,#xTextPos 					; calculate address in buffer
		ldm 	r2,#yTextPos 
		mult 	r2,#charWidth 					; calculate x + y * width
		add 	r1,r2,#0
		ldm 	r2,#textMemory 					; add text memory array base to it.
		add 	r1,r2,#0
		pop 	r2
		ret

; *****************************************************************************
;
;				Set the graphic position to the text coordinates
;
; *****************************************************************************

._OSSetCharDrawPos
		ldm 	r1,#xTextPos 					; write to the blitter pos * charPixel size
		mult 	r1,#pixelCharWidth 				; for x and y text positions
		stm 	r1,#xGraphic
		ldm 	r1,#yTextPos
		mult 	r1,#pixelCharHeight
		stm 	r1,#yGraphic
		ret

; *****************************************************************************
;
;								Scroll screen up.
;
; *****************************************************************************

._OSPCScroll
		;
		;		Scroll the screen up
		;
		ldm 	r0,#textMemory 					; first physically scroll text memory
		mov 	r1,r0,#0 						; R0 = target, R1 = source
		add 	r1,#charWidth
		mov 	r2,#charWidth*(charHeight-1)	; copy whole screen bar one line
._OSPCCopy1
		ldm 	r3,r1,#0 						; copy source to target
		stm		r3,r0,#0
		inc 	r0
		inc 	r1
		dec 	r2
		skz 	r2
		jmp 	#_OSPCCopy1
		;
		;		Clear the bottom line
		;
		mov 	r2,#charWidth 					; and blank the last line, address is in R0
		ldm 	r1,#bgrColour 					; background colour in R1 as <bgr>0.00
		ror 	r1,#4
._OSPCCopy2
		stm 	r1,r0,#0 						; write out one character width lot of blanks
		inc 	r0
		dec 	r2
		skz 	r2
		jmp 	#_OSPCCopy2
		;
		;		Copy the memory to the physical display.
		;
		clr 	r1 								; r1 = current line y graphics position
		ldm 	r2,#textMemory 					; r2 = text memory source
		;
		;		Do line R1 (graphics coord) from the data at R2
		;
._OSPCNextLine
		mov 	r3,#charWidth 					; r3 = number of characters per line.
		clr 	r4 								; r4 = current line x graphics position
		;
		; 		R3 is the counter, R4 the x position (graphics coord)
		;
._OSPCNextCharacter
		stm 	r4,#xGraphic 					; update graphic position
		stm 	r1,#yGraphic 
		ldm 	r0,r2,#0 						; read character to output to the display
		inc 	r2 								; bump that pointer
		jsr 	#OSIDrawSolidCharacter 			; display it
		add 	r4,#pixelCharWidth 				; advance the pixels required per character
		dec 	r3 								; do the whole line
		skz 	r3
		jmp 	#_OSPCNextCharacter
		;
		add 	r1,#pixelCharHeight 			; one line down
		mov 	r0,r1,#0 						; check EOS, has vert position reached bottom
		xor 	r0,#charHeight*pixelCharHeight
		skz 	r0
		jmp 	#_OSPCNextLine
		mov 	r0,#charHeight-1 				; set the vertical cursor pos (text) to
		stm 	r0,#yTextPos 				 	; the bottom visible line.
		jmp 	#_OSPCExit

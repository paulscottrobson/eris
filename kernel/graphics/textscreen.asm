; *****************************************************************************
; *****************************************************************************
;
;		Name:		textscreen.asm
;		Purpose:	Text Screen character
;		Created:	8th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;		Write character R0 (bits 0-7 only) for control characters see 
;		documentation
;
; *****************************************************************************

.OSXPrintCharacter
		push 	r0,r1,r2,r3,r4,link
		;
		and 	r0,#$FF 						; mask out bits 0-7
		mov 	r3,r0,#0 						; check if it is a control 0-31
		sub 	r3,#32
		skp		r3 		
		jmp 	#_OSPCControl 					
		;
		;		Standard character 32-127
		;		
		jsr 	#_OSPrintCharacterAtXY 			; write character to display.
		ldm 	r0,#xTextPos 					; move right.
		inc 	r0
		stm 	r0,#xTextPos
		;
._OSPCCheckNewLine		
		ldm 	r0,#xTextPos
		xor 	r0,#charWidth 					; reached RHS.
		skz 	r0
		jmp 	#_OSPCExit
		;
		;		Free return - go to the start of the next line.
		;
._OSPCFreeReturn
		stm 	r14,#xTextPos 					; back to left
		ldm 	r0,#yTextPos 					; down 1 line
		inc 	r0
		stm 	r0,#yTextPos
		;
		;		Check if scrolling required.
		;
._OSPCCheckScroll		
		ldm 	r3,#yTextPos
		xor 	r3,#CharHeight
		sknz 	r3
		jsr 	#_OSPCScroll 					; scroll screen up.
		;
		;		Save position/colour and exit
		;
._OSPCExit		
		pop 	r0,r1,r2,r3,r4,link 			; and exit.
		ret
		;
		;		Handle control characters, first check for set fgr colour, 16-31
		;
._OSPCControl
		add 	r3,#16 							; now 0-15 if set fgr colour
		skp 	r3 	
		jmp 	#_OSPCNotColour
		stm 	r3,#fgrColour 					
		jmp 	#_OSPCExit
		;
		; 		Now its 0-15 which needs a jump table.
		;
._OSPCNotColour
		add 	r0,#_OSPCVectors 				; point R0 into vector table
		ldm 	r0,r0,#0 						; read address
		brl 	link,r0,#0 						; call there - can exit with jump out or ret
		jmp 	#_OSPCExit

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
;							Code for control characters
;
; *****************************************************************************

._OSPCHome 	
		stm 	r14,#xTextPos					; home cursor
		stm 	r14,#yTextPos
		ret

._OSPCClear 									; chr(12) clear screen home cursor
		jsr 	#OSIClearScreen 				; physically clear screen to background colour
		jsr 	#_OSPCHome 						; home cursor
		ldm 	r1,#textMemory 					; erase screen memory.
		mov 	r3,#charWidth*charHeight 		; this many words to write
		ldm 	r0,#bgrColour 					; make bgr <0> <00> e.g. a zero background
		ror 	r0,#4
._OSPCErase
		stm 	r0,r1,#0 						; write to map
		inc 	r1 								; bump pointer
		dec		r3 								; do it for whole screen times.
		skz		r3
		jmp 	#_OSPCErase
		clr 	r1 								; home cursor
		jmp 	#_OSPCExit 						; exit

._OSPCReturn
		clr 	r0								; print null/space until new line
		jsr 	#_OSPrintCharacterAtXY
		ldm 	r0,#xTextPos
		inc 	r0
		stm 	r0,#xTextPos
		xor 	r0,#charWidth
		skz 	r0
		jmp 	#_OSPCReturn
		jmp 	#_OSPCFreeReturn 				; check if we need to scroll.

._OSPCTab
		ldm 	r0,#xTextPos
		add 	r0,#tabStop 					; forward 
		and 	r0,#$FFFF-(tabStop-1)			; fix it to a tab stop
		stm 	r0,#xTextPos
		jmp 	#_OSPCCheckNewLine				; check off rhs and return.

._OSPCMoveUp 									; chr(1-4) move cursor.
		mov 	r0,#-1
		sknz 	r0
._OSPCMoveDown
		mov 	r0,#1
		mov 	r2,#charHeight
		mov 	r3,#yTextPos
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

._OSPCMoveLeft
		mov 	r0,#-1
		sknz 	r0
._OSPCMoveRight
		mov 	r0,#1
		mov 	r2,#charWidth
		mov 	r3,#xTextPos
		jmp 	#_OSPCAdjust

._OSPCBackSpace 								; chr(8) backspace
		ldm 	r0,#xTextPos 					; exit if x = 0
		sknz 	r0
		ret
		dec 	r0
		stm 	r0,#xTextPos 					; go back one.
		mov 	r0,#32
		jsr 	#_OSPrintCharacterAtXY 			; and erase it.
		jmp 	#_OSPCExit

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
		push 	r0,link		
		ldm 	r1,#fgrColour 					; Add FGR << 8
		ror 	r1,#8
		add 	r0,r1,#0
		ldm 	r1,#bgrColour 					; Add BGR << 12
		ror 	r1,#4
		add 	r0,r1,#0 						; R0 now is the character
		jsr 	#_OSSetCharDrawPos
		jsr 	#OSDrawSolidCharacter			; draw it.
		;
		ldm 	r1,#xTextPos 					; calculate address in buffer
		ldm 	r2,#yTextPos
		mult 	r2,#charWidth
		add 	r1,r2,#0
		ldm 	r2,#textMemory
		add 	r1,r2,#0
		stm 	r0,r1,#0 						; write into buffer.
		pop 	r0,link
		ret

; *****************************************************************************
;
;				Set the graphic position to the text coordinates
;
; *****************************************************************************

._OSSetCharDrawPos
		ldm 	r1,#xTextPos
		ror 	r1,#13
		stm 	r1,#xGraphic
		ldm 	r1,#yTextPos
		ror 	r1,#13
		stm 	r1,#yGraphic
		ret

; *****************************************************************************
;
;								Scroll screen up.
;
; *****************************************************************************

._OSPCScroll
		break
		; #TODO
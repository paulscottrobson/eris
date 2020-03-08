; *****************************************************************************
; *****************************************************************************
;
;		Name:		textscreen.asm
;		Purpose:	Text Screen character
;		Created:	28th February 2020
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
		ldm 	r1,#textPosition 				; R1 holds the on screen position
		ldm 	r2,#gfxColour 					; R2 is the background/foreground colour
		;
		and 	r0,#$FF 						; mask out bits 0-7
		mov 	r3,r0,#0 						; check if it is a control 0-31
		sub 	r3,#32
		skp		r3 		
		jmp 	#_OSPCControl 					
		;
		;		Standard character 32-127
		;
		jsr 	#_OSPrintCharacterAdvance 		; write character to display
		;
		;		Check if scrolling required.
		;
._OSPCCheckScroll		
		mov 	r3,r1,#0 						; check gone off screen.
		xor 	r3,#CharWidth*CharHeight
		sknz 	r3
		jsr 	#_OSPCScroll 					; scroll screen up.
		;
		;		Save position/colour and exit
		;
._OSPCExit		
		stm 	r1,#textPosition 				; write position/colour back out
		stm 	r2,#gfxColour
		pop 	r0,r1,r2,r3,r4,link 			; and exit.
		ret
		;
		;		Handle control characters, first check for set colour, 16-31
		;
._OSPCControl
		add 	r3,#16 							; now 0-15 if colour
		skp 	r3 	
		jmp 	#_OSPCNotColour
		and 	r2,#$00F0 						; mask out foreground
		add 	r2,r3,#0 						; add new colour in
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
		clr 	r1 								; chr(11) home cursor
		ret

._OSPCClear 									; chr(12) clear screen home cursor
		jsr 	#OSIClearScreen 				; physically clear screen to background colour
		ldm 	r1,#textMemory 					; erase screen memory.
		mov 	r3,#charWidth*charHeight 		; this many words to write
		mov 	r0,r2,#0 						; current colour
		ror 	r0,#8 							; make back/fore/$00
._OSPCErase
		stm 	r0,r1,#0 						; write to map
		inc 	r1 								; bump pointer
		dec		r3 								; do it for whole screen times.
		skz		r3
		jmp 	#_OSPCErase
		clr 	r1 								; home cursor
		jmp 	#_OSPCExit 						; exit

._OSPCReturn
		clr 	r0 								; chr(13) carriage return so write nulls
		jsr 	#_OSPrintCharacterAdvance 		
		mov 	r0,r1,#0 						; till start of line
		and 	r0,#charWidth-1 				; *** DEP ***
		skz 	r0
		jmp 	#_OSPCReturn
		jmp 	#_OSPCCheckScroll 				; check scroll and exit.


._OSPCFreeReturn
		add 	r1,#charWidth
		and 	r1,#$FFFF-(charWidth-1)
		jmp 	#_OSPCCheckScroll 				; check scroll and exit.

._OSPCTab
		add 	r1,#tabStop 					; forward 
		and 	r1,#$FFFF-(tabStop-1)			; fix it
		jmp 	#_OSPCCheckScroll 				; check scroll and exit.

._OSPCMoveUp 									; chr(1-4) move cursor.
		sub 	r1,#charWidth*2
._OSPCMoveDown
		add 	r1,#charWidth+1
._OSPCMoveLeft
		sub 	r1,#2
._OSPCMoveRight
		inc 	r1
		skp 	r1 								; wrap round.
		add 	r1,#charWidth*charHeight
		mov 	r0,r1,#0 	
		sub 	r0,#charWidth*charHeight
		sklt
		mov 	r1,r0,#0 
		ret

._OSPCBackSpace 								; chr(8) backspace
		sknz 	r1 								; can't be first
		ret
		dec 	r1
		mov 	r0,#32 							; print space
		jsr 	#_OSPrintCharacterAdvance 		
		dec 	r1 								; backspace again
		jmp 	#_OSPCExit  					; and exit as we have busted link

._OSPCSwapColours 								; chr(15) swap background and foreground
		mov 	r0,r2,#0
		ror 	r2,#4
		and 	r0,#15
		and 	r2,#15
		ror 	r0,#12
		add 	r2,r0,#0
		ret

; *****************************************************************************
;
; 	  write character R0 to display in current colour, text area and advance
;
; *****************************************************************************

._OSPrintCharacterAdvance
		push 	r0,link		
		ror 	r2,#8							; colour the character
		add 	r0,r2,#0
		ror 	r2,#8
		mov 	r4,r1,#0 						; save index display position
		jsr 	#OSICharToPixel 				; convert R1 char -> pixel
		jsr 	#OSIDrawCharacter 				; output to the display
		mov 	r1,r4,#0						; restore index display position.
		ldm 	r3,#textMemory 					; write to display image
		add 	r3,r1,#0 					
		stm 	r0,r3,#0 			
		inc 	r1 								; bump text position.
		pop 	r0,link
		ret

; *****************************************************************************
;
;		Convert character offset in R1 to a blitter position in r1
;
; *****************************************************************************

.OSICharToPixel
		push 	r3
		mov 	r3,r1,#0 						; X position in R3
		and 	r3,#$1F 						; *** DEP *** get x position
		mult 	r3,#charPixelWidth
		and 	r1,#$FFE0 						; Y is column * 32
		ror 	r1,#10 							; / 4 and shift into MSB *** DEP ***
		add 	r1,r3,#0
		pop 	r3
		ret

; *****************************************************************************
;
;								Scroll screen up.
;
; *****************************************************************************

._OSPCScroll
		push 	link
		ldm 	r3,#textMemory 					; r3 points to text memory
		mov 	r4,r3,#0 						; r4 points to next row down
		add 	r4,#charWidth 					
		mov 	r1,#charWidth*(charHeight-1)	; r1 is count to move		
._OSPCCopy1 									; scroll text up in text buffer		
		ldm 	r0,r4,#0
		stm 	r0,r3,#0 
		inc 	r3
		inc 	r4
		dec 	r1
		skz 	r1
		jmp 	#_OSPCCopy1
		mov 	r1,#charWidth 					; now erase the bottom line to character $00
._OSPCCopy2
		ror 	r2,#8		 					; rotate colour by 8 gives b/f/0
		stm 	r2,r3,#0
		ror 	r2,#8
		inc 	r3
		dec 	r1
		skz 	r1
		jmp 	#_OSPCCopy2
		mov 	r0,#charHeight-1 				; now redraw the whole screen.
._OSPCRefresh1
		jsr 	#OSILineRefresh
		dec 	r0
		skm 	r0
		jmp 	#_OSPCRefresh1
		mov 	r1,#charWidth*(charHeight-1)	; cursor at start of bottom line.
		pop 	link
		ret

; *****************************************************************************
;
;								Internal, refresh line R0
;
; *****************************************************************************

.OSILineRefresh
		push 	r0,r1,r2,r3,link
		mov 	r1,r0,#0 						; line # in R1
		ror 	r1,#5 							; multiply by 8x256, now start of line position.
		ror 	r0,#11 							; x by 32 *** dependent on char Width ***
		ldm 	r2,#textMemory 					; add text memory, text pointer in R2.
		add 	r2,r0,#0
		mov 	r3,#charWidth 					; chars to copy
._OSILRLoop
		ldm 	r0,r2,#0 						; colour/character to output
		jsr 	#OSIDrawCharacter 				; do it
		inc 	r2 								; advance
		add 	r1,#charPixelWidth
		dec 	r3
		skz 	r3
		jmp 	#_OSILRLoop
		pop 	r0,r1,r2,r3,link
		ret


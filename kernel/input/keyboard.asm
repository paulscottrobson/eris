; *****************************************************************************
; *****************************************************************************
;
;		Name:		keyboard.asm
;		Purpose:	Keyboard Input code
;		Created:	8th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;							Scan keyboard into R0
;
; *****************************************************************************

.OSXGetKeyboard
		push 	r1,r2,r3,r4,r5,link
		jsr		#OSManager 						; call keyboard manager routine.
		mov 	r1,#KeyboardMapping+4*8 		; R1 points to keyboard mapping table.
		mov 	r2,#currentRowStatus+4 			; R2 points to the current row, starts at $10
		mov 	r3,#$10 						; R3 is the current row selected. Shift is always up to date
		clr 	r4 								; R4 is the sum of all key inputs, check for any key.
		;
		;		Main scanning loop.
		;
._GKScan
		stm 	r3,#keyboardPort 				; select row.
		mov 	r0,#200 						; short delay for debounce
._GKDebounce:
		dec 	r0
		skz 	r0
		jmp 	#_GKDebounce
		;
		ldm 	r5,#keyboardPort 				; read keyboard port status
		add 	r4,r5,#0 						; add to sum of all key inputs.
		;
		ldm 	r0,r2,#0 						; read current row status.
		stm 	r5,r2,#0 						; update current row status.
		xor 	r0,#$FFFF 						; look for keys pressed before that weren't now.		
		and 	r0,r5,#0 						; e.g. status & (~previous)	
		skz 	r0 								; when zero, go process new key depression.
		jmp 	#_GKKeyPressed 
		;
		sub		r1,#8 							; next 16 bytes of mapping table
		dec 	r2 								; previous row status
		ror 	r3,#1 							; rotate key right
		skm 	r3 								; goes -v when $0001 rotated.
		jmp 	#_GKScan 
		;
		;		No key currently pressed.
		;
._GKNoKeyPressed		
		clr 	r0 								; return zero
		sknz 	r4 								; any key pressed at all ?
		stm 	r14,#currentKey 				; if not, clear current key.
		sknz	r4
		jmp 	#_GKExitWithR0 					; if not, then can't repeat.
		ldm 	r1,#hwTimer 					; timer >= key repeat time
		ldm 	r2,#keyRepeatTime
		sub 	r2,r1,#0
		skm 	r2 								; if not, then exit
		jmp 	#_GKExitWithR0
		add 	r1,#repeatSpeed 				; reset timer for repeat speed
		stm 	r1,#keyRepeatTime
		ldm 	r0,#currentKey 					; repeat current key.
._GKExitWithR0
		pop 	r1,r2,r3,r4,r5,link
		ret
;
;		R0 contains the new key pressed bit. R1 points to the mapping table.
;
._GKKeyPressed:
		mov 	r2,#-1 							; R2 is the bit count, which key in the row was
._GKFindBitNumber 								; pressed.
		inc 	r2
		ror 	r0,#1
		skm  	r0
		jmp 	#_GKFindBitNumber
		;
		ror 	r2,#1 							; rotate bit count right as two per bit.
		mov		r0,r2,#0 						; mask out the actual count to add.
		and 	r0,#15
		add 	r0,r1,#0 						; get the correct word out of the mapping table
		ldm 	r0,r0,#0 						; from the character table.
		skp 	r2 								; if the upper half swap it.
		ror 	r0,#8
		and 	r0,#$FF 						; and this is the character code.
		;
		sknz 	r0 								; if no key pressed, exit via that code.
		jmp 	#_GKNoKeyPressed
		;
		ldm 	r1,#hwTimer 					; reset repeat timer
		add 	r1,#repeatDelay 		
		stm 	r1,#keyRepeatTime
		;
		ldm 	r1,#currentRowStatus+4			; get the row with ctrl and shift on it.
		ror 	r1,#5 							; check control
		skp 	r1
		and 	r0,#$1F 						
		ror 	r1,#1 							; check shift
		skp 	r1
		jsr 	#_GKShiftExecute
		;
		stm 	r0,#currentKey 					; save as currently pressed key value.
		jmp 	#_GKExitWithR0 					; and exit with the result.	
	
; *****************************************************************************
;
;							Shift the character code in R0
;
; *****************************************************************************

._GKShiftExecute:
		mov 	r1,r0,#0						; check if a..z 
		sub 	r1,#97
		skge	
		jmp 	#_GKNotAlpha
		sub 	r1,#26
		sklt
		jmp 	#_GKNotAlpha
		sub 	r0,#32 							; make U/C
		ret
;
;		Check the conversion LUT.
;
._GKNotAlpha		
		mov 	r2,#ShiftTable 					; before MSB, after LSB.
._GKShiftLoop:
		ldm 	r1,r2,#0 						; get key
		ror 	r1,#8 			
		xor 	r1,r0,#0 						; same as the ASCII code ?
		and 	r1,#$00FF 						; only interested in match LSB
		sknz 	r1
		jmp 	#_GKShiftFound 					; yes, get the key.
		inc 	r2 								; next
		ldm 	r1,r2,#0 
		skz 	r1
		jmp 	#_GKShiftLoop 					; until end of table
		ret
		;
._GKShiftFound:						
		ldm 	r0,r2,#0 						; get key which is the shifted value.
		and 	r0,#$00FF						; mask out
		ret


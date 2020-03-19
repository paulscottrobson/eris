; *****************************************************************************
; *****************************************************************************
;
;		Name:		keyboard.asm
;		Purpose:	Keyboard Input code
;		Created:	8th March 2020
;		Reviewed: 	16th March 2020
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
		mov 	r1,#KeyboardMapping+5*8 		; R1 points to keyboard mapping table.
		mov 	r2,#currentRowStatus+5 			; R2 points to the current row status, starts at $20
		mov 	r3,#$20 						; R3 is the current row selectw word. Shift is always up to date
		clr 	r4 								; R4 is the sum of all key inputs, check for any key.
		;
		;		Main scanning loop.
		;
._GKScan
		;
		;		Scan this row
		;
		stm 	r3,#keyboardPort 				; write current row to keyboard port
		mov 	r0,#$0F 						; short delay for debounce
._GKDebounce:
		dec 	r0
		skz 	r0
		jmp 	#_GKDebounce
		;
		ldm 	r5,#keyboardPort 				; read keyboard port status
		and 	r5,#$3FFF 						; clear any common keys (bits 14-15 may be used for break)
		add 	r4,r5,#0 						; add to sum of all key inputs.
		;
		ldm 	r0,r2,#0 						; read current row status.
		stm 	r5,r2,#0 						; update current row status with new value.
		xor 	r0,#$FFFF 						; look for keys pressed before that weren't now.		
		and 	r0,r5,#0 						; e.g. status & (~previous)	
		skz 	r0 								; when zero, go process new key depression.
		jmp 	#_GKKeyPressed 
		;
		;		Go to the next row
		;
		sub		r1,#8 							; previous 16 bytes of mapping table
		dec 	r2 								; previous row status
		ror 	r3,#1 							; rotate column select word right
		skm 	r3 								; goes -ve when $0001 rotated.
		jmp 	#_GKScan 
		;
		;		No key currently pressed.
		;
._GKNoKeyPressed		
		clr 	r0 								; return zero
		sknz 	r4 								; is any key pressed at all ?
		stm 	r14,#currentKey 				; if not, clear current key.
		sknz	r4
		jmp 	#_GKExitWithR0 					; if not, then can't repeat.
		ldm 	r1,#hwTimer 					; timer >= key repeat time
		ldm 	r2,#keyRepeatTime
		sub 	r2,r1,#0
		skm 	r2 								; if not, then exit
		jmp 	#_GKExitWithR0
		add 	r1,#repeatSpeed 				; reset timer for repeat *speed*
		stm 	r1,#keyRepeatTime 				; so it repeats faster than first delay
		ldm 	r0,#currentKey 					; repeat current key.
._GKExitWithR0
		pop 	r1,r2,r3,r4,r5,link
		ret
;
;		R0 contains the new key pressed bits. R1 points to the mapping table.
;
._GKKeyPressed:
		;
		;		Figure out pressed key and convert to ASCII
		;
		mov 	r2,#-1 							; R2 is the bit count, which key in the row was
._GKFindBitNumber 								; pressed, pre decremented
		inc 	r2 								; bump bit count
		ror 	r0,#1 							; that bit number in the MSB
		skm  	r0 								; until we identify the new key
		jmp 	#_GKFindBitNumber
		;
		ror 	r2,#1 							; rotate bit count right as two elements per bit.
		mov		r0,r2,#0 						; mask out the actual count to add.
		and 	r0,#15
		add 	r0,r1,#0 						; get the correct word out of the mapping table
		ldm 	r0,r0,#0 						; from the character table.
		skp 	r2 								; if the upper half swap it.
		ror 	r0,#8
		and 	r0,#$FF 						; mask out the character code for this new depression
		;
		sknz 	r0 								; if no key pressed, exit via that code.
		jmp 	#_GKNoKeyPressed
		;
		ldm 	r1,#hwTimer 					; reset repeat timer to long delay
		add 	r1,#repeatDelay 		
		stm 	r1,#keyRepeatTime
		;
		;		Check Ctrl and Shift modifiers
		;
		ldm 	r1,#currentRowStatus+5			; get the row with ctrl and shift on it.
		ror 	r1,#5 							; check control
		skp 	r1
		jsr 	#_GKControl
		ror 	r1,#1 							; check shift
		skp 	r1
		jsr 	#_GKShiftExecute
		;
		stm 	r0,#currentKey 					; save as currently pressed key value.
		jmp 	#_GKExitWithR0 					; and exit with the result.	

; *****************************************************************************
;
;							Convert Control keys
;
; *****************************************************************************
	
._GKControl
		mov 	r2,r0,#0 						; current -> R2
		and 	r0,#$1F 						; mask out lower 5 bits
		and 	r2,#$00F8 						; check Ctrl 0-7 characters - func keys
		xor 	r2,#$0030
		skz 	r2
		ret
		mov 	r2,r0,#0 						; do not generate ctrl+0 or ctrl+7
		sknz 	r2
		ret
		xor 	r2,#7
		sknz 	r2
		ret
		add 	r0,#$DF 						; map them to 240-245
		ret

; *****************************************************************************
;
;							Shift the character code in R0
;
; *****************************************************************************

._GKShiftExecute:
		mov 	r1,r0,#0						; check if a..z , which we can do easily.
		sub 	r1,#97
		skge	
		jmp 	#_GKNotAlpha
		sub 	r1,#26
		sklt
		jmp 	#_GKNotAlpha
		sub 	r0,#32 							; make upper case as shifted
		ret
;
;		Check the conversion Look up table, as we've shifted something not alphabetic
;		This table is generated from the keyboard map.
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
		;		Found an entry in the shift table
		;
._GKShiftFound:						
		ldm 	r0,r2,#0 						; get key which is the shifted value.
		and 	r0,#$00FF						; mask out the final shifted value
		ret

; *****************************************************************************
; *****************************************************************************
;
;		Name:		getcursor.asm
;		Purpose:	Return one key press with a flashing cursor while waiting.
;		Created:	9th March 2020
;		Reviewed: 	16th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;				Get keypress into R0, displaying an active cursor.
;						Also handles function key expansion
;
; *****************************************************************************

.OSXCursorGet
		;
		;		Check expanding function key. This way => no recursion.
		;
		ldm 	r0,#functionKeyQueue 		; check the function key queue
		skz 	r0
		jmp 	#_OSCGFunctionKey 			; if not empty get the next character from that
		;
		;		No Function key queue
		;
._OSCGKeyboard
		stm	 	r14,#functionKeyQueue 		; clear the queue
		push 	r1,r2,link
		clr 	r2 							; R2 is the last read timer value.
._OSCGLoop
		ldm		r0,#hwTimer 				; read the timer
		ror 	r0,#6						; this puts the flag bit into R0:15 affects flash rate
		skse 	r0,r2,#0 					; has the sign changed since the last time
		jsr 	#_OSCGSetCursorBlock 		; update the cursor
		jsr 	#OSGetKeyboard 				; scan keyboard
		sknz 	r0
		jmp 	#_OSCGLoop 					; loop back if no new key press
		push 	r0
		clr 	r0 							; erase the cursor
		jsr 	#_OSCGSetCursorBlock
		pop 	r0
		mov 	r1,r0,#0 					; check if it is a function key
		and 	r1,#$F8 					; e.g. in the range 240-247
		xor		r1,#$F0
		sknz 	r1
		jsr 	#_OSCGExpandFunctionKey 	; if so go expand that function key
		pop 	r1,r2,link
		ret
		;
		;		Write cursor/character according to R0
		;
._OSCGSetCursorBlock
		push 	link		
		mov 	r2,r0,#0 					; update state e.g. the last bit 15 state
		jsr 	#_OSCurrentTextR1			; get address of cursor
		ldm 	r0,r1,#0					; get char there
		skm 	r2
		jmp 	#_OSSCGSCBShow 				; if the state is -ve then draw the cursor in white
		and 	r0,#$F000 					; when R2.15 set, then use the background
		add 	r0,#$077E 					; with a white cursor.
._OSSCGSCBShow		
		jsr 	#_OSSetCharDrawPos 			; set blitter position
		jsr 	#OSIDrawSolidCharacter 		; draw cursor
		pop 	link
		ret
		;
		;		Handle function keys, R0 already has the queue address
		;
._OSCGFunctionKey
		push 	r1,r2
		ldm 	r1,r0,#0 					; read the key in the queue
		ldm 	r2,#functionKeyByte 		; indicates which half, 0 = low , 1 = high
		skz 	r2 							; rotate depending on which half
		ror 	r1,#8		
		skz 	r2 							; if upper byte bump the pointer
		inc 	r0
		xor 	r2,#1 						; toggle which half and write back
		stm 	r2,#functionKeyByte
		stm 	r0,#functionKeyQueue
		;
		and 	r1,#$FF 					; get character out
		mov 	r0,r1,#0 					; put in R0
		pop 	r1,r2
		sknz 	r0 							; if zero get the normal way
		jmp 	#_OSCGKeyboard 				; as we have reached the end of the expansion
		ret
		;
		;		Expand function key, and call routine recursively to get character.
		;		
._OSCGExpandFunctionKey		
		push 	link
		and 	r0,#7 						; key number -> definition address
		mult 	r0,#functionKeySize
		add 	r0,#functionKeyDefinitions	
		stm 	r0,#functionKeyQueue 		; put it in the queue address
		stm 	r14,#functionKeyByte 		; start with low byte so zero that flag
		jsr 	#OSXCursorGet 				; call cursor get to get the next key
._OSCGExit1

		pop 	link
		ret
		
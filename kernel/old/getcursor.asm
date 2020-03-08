; *****************************************************************************
; *****************************************************************************
;
;		Name:		getcursor.asm
;		Purpose:	Return one key press with a flashing cursor while waiting.
;		Created:	29th February 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;				Get keypress into R0, displaying an active cursor.
;
; *****************************************************************************

.OSXCursorGet
		push 	r1,r2,link
		clr 	r2 							; R2 is the last read timer value.
._OSCGLoop
		ldm		r0,#hwTimer 				; read the timer
		ror 	r0,#6 						; this puts the flag bit into R0:15
		skse 	r0,r2,#0 					; has the sign changed ?
		jsr 	#_OSCGSetCursorBlock
		jsr 	#OSGetKeyboard
		sknz 	r0
		jmp 	#_OSCGLoop
		clr 	r2 							; erase the cursor
		jsr 	#_OSCGSetCursorBlock
		pop 	r1,r2,link
		ret

._OSCGSetCursorBlock
		push 	link
		mov 	r2,r0,#0 					; update the last read value.
		ldm 	r1,#textPosition 			; get position in R1 and make it a pixel position
		jsr 	#OSICharToPixel
		jsr 	#OSWaitBlitter 				; wait for blitter to free up.
		stm 	r1,#blitterPos 				; set position.
		mov 	r1,#_OSCGCursor 	 		; cursor graphic
		stm 	r1,#blitterData
		mov 	r1,#$881A 					; write orange cursor to sprite foreground
		skm 	r2
		add 	r1,#5 						; if blank, set it to $881F which is transparent.
		stm 	r1,#blitterCmd
		pop 	link
		ret

._OSCGCursor
		word 	$A800		
		word 	$5400
		word 	$A800		
		word 	$5400
		word 	$A800		
		word 	$5400
		word 	$A800		
		word 	$5400

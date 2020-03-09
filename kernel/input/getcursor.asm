; *****************************************************************************
; *****************************************************************************
;
;		Name:		getcursor.asm
;		Purpose:	Return one key press with a flashing cursor while waiting.
;		Created:	9th March 2020
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
		push 	r0
		clr 	r0 							; erase the cursor
		jsr 	#_OSCGSetCursorBlock
		pop 	r0
		pop 	r1,r2,link
		ret

._OSCGSetCursorBlock
		push 	link		
		mov 	r2,r0,#0 					; update state
		jsr 	#_OSCurrentTextR1			; get address
		ldm 	r0,r1,#0					; get char there
		skm 	r2
		jmp 	#_OSSCGSCBShow
		and 	r0,#$F000 					; when R2.15 set, then use the background
		add 	r0,#$077E 					; with a white cursor.
._OSSCGSCBShow		
		jsr 	#_OSSetCharDrawPos
		jsr 	#OSXDrawSolidCharacter
		pop 	link
		ret

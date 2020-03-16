; *****************************************************************************
; *****************************************************************************
;
;		Name:		inputlimit.asm
;		Purpose:	Short Line Input code
;		Created:	12th March 2020
;		Reviewed: 	16th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;			Input to the string at R0 , maximum length R1 , in 
;			compressed format. Only control keys allowed are BS/RET
;
; *****************************************************************************

.OSXInputLimit
		push 	r0,r1,r2,r3,link
		mov 	r2,r0,#0 					; put the target address in R2
		stm 	r14,r2,#0 					; erase the target string.
._OSLILoop
		jsr 	#OSCursorGet 				; get next character -> R3
		mov 	r3,r0,#0
		xor 	r0,#13 						; exit if CRLF
		sknz 	r0
		jmp 	#_OSLIExit
		xor 	r0,#13^8 					; if BS do backspace code.
		sknz 	r0
		jmp 	#_OSLIBackspace
		and  	r0,#$00E0 					; check >= 32 e.g. not control, this is text only
		sknz 	r0
		jmp 	#_OSLILoop	
		;
		ldm 	r0,r2,#0 					; get current length
		xor 	r0,r1,#0 					; at maximum already ?
		sknz 	r0
		jmp 	#_OSLILoop 					; if so reject
		;
		mov 	r0,r3,#0 					; print the character
		jsr 	#OSPrintCharacter 
		jsr 	#_OSLIWriteCurrent  		; write the character to the current slot.
		ldm 	r0,r2,#0  					; next character
		inc 	r0
		stm 	r0,r2,#0
		jmp 	#_OSLILoop
		;
		;		Handle backspace
		;
._OSLIBackspace
		ldm 	r0,r2,#0 					; get current length
		sknz 	r0 							; cannot backspace at start so go back to the top
		jmp 	#_OSLILoop 		
		mov 	r0,#8 						; print a backspace
		jsr 	#OSPrintCharacter
		ldm 	r0,r2,#0  					; previous character
		dec 	r0
		stm 	r0,r2,#0
		clr 	r0 							; erase the character there to $00 again
		jsr 	#_OSLIWriteCurrent
		jmp 	#_OSLILoop
		;
		;		Handle CR
		;
._OSLIExit
		mov 	r0,#13 						; just prints CR
		jsr 	#OSPrintCharacter
		pop 	r0,r1,r2,r3,link
		ret
;
;		Write byte R0 to current slot in string at R2 ; slot is indicated by length at (R2)
;
._OSLIWriteCurrent
		push 	r0,r1,r3
		ldm 	r1,r2,#0 					; count / 2 -> R1
		ror 	r1,#1
		mov		r3,r1,#0 					; R3 has selector bit in R3.15
		and 	r1,#$7FFF 					; R1 is an offset
		add 	r1,r2,#1 					; R1 now offset to the character in question
		skm 	r3 							; if odd, shift 8 left and add to current
		jmp 	#_OSLIWriteExit 			; if even, just write out
		;
		ldm 	r3,r1,#0 					; get current
		and 	r3,#$00FF 					; clear the MSB
		ror 	r0,#8 						; put in MSB
		add 	r0,r3,#0
._OSLIWriteExit		
		stm 	r0,r1,#0 					
		pop 	r0,r1,r3
		ret

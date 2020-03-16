; *****************************************************************************
; *****************************************************************************
;
;		Name:		tointeger.asm
;		Purpose:	Convert string to integer
;		Created:	8th March 2020
;		Reviewed: 	16th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;							Convert String to Integer. 
;
;	On entry R1 contains the base 2-16 and R0 the character fetch routine.
;
;	Calling the character fetch retrieves the next character from the input
;	stream ; it should return $00 if it runs out of data.
;
;	The stream is converted into an integer which is returned in R0. R1 is 
;	non-zero if an error has occurred. In this case the first bad character
; 	has already been 'got', so it is possible to get it back, by (say)
;	decrementing the character pointer and re-reading it.
;
;	R10 and R11 are not used by the routine, and can be used to contain
;	values for the character fetch which are maintained between calls
;	(e.g. a data pointer)
;
; *****************************************************************************

.OSXStrToInt
		push 	r2,r3,r4,r5,r6,link
		mov 	r2,r0,#0 					; put the 'get' routine in R2
		clr 	r3 							; r3 is the result
		clr 	r4 							; r4 is the signed flag.
		mov 	r6,#1 						; error flag, cleared on a successful conversion
		;
		brl 	r13,r2,#0 					; call the get routine
		and 	r0,#$00FF 					; mask character off.
		mov 	r5,r0,#0 					; put in R5.
		xor 	r5,#'-'						; is it - ?
		skz 	r5  					
		jmp 	#_OSSILoop 
		inc 	r4 							; if so, set the signed flag.
		brl 	r13,r2,#0 					; get the next character
		;
		;		Convert loop, already has next character in R0.
		;
._OSSILoop 		
		jsr 	#OSUpperCase 				; make U/C which also clears bits 8-15
		sub 	r0,#'0' 					; base shift - we're checking 0-9 A...
		skge 	 							; exit if < '0'
		jmp 	#_OSSIExit
		mov 	r5,r0,#0 					; put this base value in R5.
		sub 	r0,#10 						; 0-9 check
		skge 								
		jmp 	#_OSSHaveDigit
		sub 	r5,#7 						; check A-F - adjust the base value.
		sub 	r0,#7
		skge  								; this exits if in the bit between 9 and A.
		jmp 	#_OSSIExit 					

._OSSHaveDigit
		mov 	r0,r5,#0 					; check the digit < base
		sub 	r0,r1,#0 			
		sklt
		jmp 	#_OSSIExit
		;
		mult 	r3,r1,#0 					; x current by base and add
		add 	r3,r5,#0
		clr 	r6 							; clear error flag as we have one valid digit
		brl 	r13,r2,#0 					; get next character and go around
		jmp 	#_OSSILoop

._OSSIExit		
		clr 	r5 							; R5 = -result
		sub 	r5,r3,#0
		skz 	r4 							; use this if signed flag set (result in r3)
		mov 	r3,r5,#0
		;
		mov 	r0,r3,#0 					; result in R0
		mov 	r1,r6,#0 					; error flag in R1
		pop 	r2,r3,r4,r5,r6,link
		ret

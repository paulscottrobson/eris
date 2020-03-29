; *****************************************************************************
; *****************************************************************************
;
;		Name:		fkey.asm
;		Purpose:	Function Key code
;		Created:	29h March 2020
;		Reviewed: 	TODO
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;					Define function key R0 to be string R1
;							Returns 0 if defined ok
;
; *****************************************************************************

.OSXDefineFKey
		push 	r1,r2,r3,link
		dec 	r0 							; map keys onto 0-5
		mov 	r2,r0,#0 					; save key number in R2
		sub 	r0,#6 						; check range
		sklt
		jmp 	#_OSDFError		
		mov 	r0,r1,#0 					; get string address
		jsr 	#OSWordLength 				; get the length in words
		mov 	r3,r0,#0 					; save length in words in R3, will be >= 0
		sub 	r0,#functionKeySize 		; will it fit ? must be < because of final $0000
		sklt
		jmp 	#_OSDFError 				; no, it won't
		;
		mult 	r2,#functionKeySize 		; make R2 point to the memory location
		add 	r2,#functionKeyDefinitions	; of the text definition.
._OSDFCopy
		ldm 	r0,r1,#1 					; read the string, skipping length
		stm 	r0,r2,#0 					; into the buffer
		inc 	r1
		inc 	r2
		dec 	r3 							; copy R3 words
		skz 	r3
		jmp 	#_OSDFCopy
		stm 	r14,r2,#0 					; add a final $0000
		clr 	r0
		skz 	r0
._OSDFError		
		mov 	r0,#1
		pop 	r1,r2,r3,link
		ret
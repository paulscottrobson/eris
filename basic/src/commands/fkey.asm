; *****************************************************************************
; *****************************************************************************
;
;		Name:		fkey.asm
;		Purpose:	Function Key Processor
;		Created:	16th March 2020
;		Reviewed: 	17th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;							FKEY <n>,<string>
;
; *****************************************************************************

.Command_FKey		;; [fkey]
		push 	link
		jsr 	#EvaluateInteger 			; key number
		dec 	r0 							; map onto 0-5
		mov 	r2,r0,#0 					; save it		
		sub 	r0,#6 						; check range
		sklt
		jmp 	#BadNumberError
		jsr 	#CheckComma 				; check comma
		jsr 	#EvaluateString 			; look at the RHS
		mov 	r1,r0,#0 					; string address in R1
		;
		jsr 	#OSWordLength 				; get the length in words
		mov 	r3,r0,#0 					; save length in words in R3, will be >= 0
		sub 	r0,#functionKeySize 		; will it fit ? must be < because of final $0000
		sklt
		jmp 	#StrlenError 				; no, it won't
		;
		mult 	r2,#functionKeySize 		; make R2 point to the memory location
		add 	r2,#functionKeyDefinitions	; of the text definition.
._CFCopy
		ldm 	r0,r1,#1 					; read the string, skipping length
		stm 	r0,r2,#0 					; into the buffer
		inc 	r1
		inc 	r2
		dec 	r3 							; copy R3 words
		skz 	r3
		jmp 	#_CFCopy
		stm 	r14,r2,#0 					; add a final $0000
		pop 	link
		ret

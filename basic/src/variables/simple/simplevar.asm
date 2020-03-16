; *****************************************************************************
; *****************************************************************************
;
;		Name:		simplevar.asm
;		Purpose:	Very simple variable implementation, 26 A-Z
;		Created:	3rd March 2020
;		Reviewed: 	TODO
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;				Get variable reference @R11 to stack @R10
;
; *****************************************************************************

.GetVariableReference
		ldm 	r0,r11,#0 					; get keyword which is an identifier.
		sub 	r0,#$6000					; 01xx plus must be last character.
		mov 	r1,#fixedVariables-1		; put fixed variable address in R1 (A = $6001)
		add 	r1,r0,#0
		sub 	r0,#26+1 					; check range 1..26 ($6000 cannot happen)
		sklt 	r0
		jmp 	#SyntaxError 				; bad variable.
		;
		stm 	r1,r10,#esValue1 			; save address
		stm 	r15,r10,#esReference1 		; and it is a reference.
		stm 	r14,r10,#esType1 			; and a reference to an integer
		;
		inc 	r11 						; step over keyword
		ret
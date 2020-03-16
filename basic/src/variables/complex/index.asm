; *****************************************************************************
; *****************************************************************************
;
;		Name:		index.asm
;		Purpose:	Array Indexing
;		Created:	9th March 2020
;		Reviewed: 	TODO
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;				Index the array at R0, with the indices at R11.
;
; *****************************************************************************

.IndexArray
		push 	r1,r2,r3,r4,link
		mov 	r3,r0,#0 					; put the base in R3
		jsr 	#EvaluateInteger 			; get the first index
		;
		ldm 	r2,r3,#2 					; get the first largest index.
		sub 	r2,r0,#0 					; compare vs request index
		skge 								; if largest >= requested ok
		jmp 	#BadIndexError
		;
		ldm 	r1,r11,#0 					; get next token
		xor 	r1,#TOK_COMMA 				; 2nd index ?
		sknz 	r1
		jmp 	#_IADimension2
		;
		ldm 	r2,r3,#3 					; check it's a single element array
		skz 	r2
		jmp 	#MissingCommaError
		;
._IADone		
		add 	r0,r3,#4 					; point to the correct element
		jsr 	#CheckRightBracket 			; check closing parenthesis and exit
		pop 	r1,r2,r3,r4,link
		ret

._IADimension2
		inc 	r11 						; step over comma.
		mov 	r4,r0,#0 					; R4 is index 1. R0 is index 2
		jsr 	#EvaluateInteger 			; get the second index.
		;
		ldm 	r2,r3,#3 					; get the second largest index.
		sknz 	r2 							; must be non zero
		jmp 	#MissingBracketError
		sub 	r2,r0,#0 					; compare vs request index
		skge 								; if largest >= requested ok
		jmp 	#BadIndexError
		;
		ldm 	r2,r3,#2 					; get the max index of the first index
		mult 	r0,r2,#1 					; add 1 and multiply into second index
		add 	r0,r4,#0  					; add to first, e.g. i1 + i2 * dimension(1)
		jmp 	#_IADone 					; and complete


; *****************************************************************************
; *****************************************************************************
;
;		Name:		dim.asm
;		Purpose:	Array Dimension
;		Created:	7th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

.Command_DIM 	;; [dim]
		push 	link
._CDINextArray		
		ldm 	r0,r11,#0 					; check it is an array identifier first
		ror 	r0,#14
		skm 	r0
		jmp 	#SyntaxError 				; if so, syntax error occurs
		;
		jsr 	#FindVariable 				; try to find the variable already (R6 ^ Hash)
		skz		r0 							; skip if not found.
		jmp 	#ArrayExistsError
		;
		mov 	r7,r11,#0 					; save the address of the identifier.
._CDIAdvance		
		ldm 	r1,r11,#0 					; advance the identifier pointer past the identifier
		mov 	r2,r1,#0 					; save for typing in R2
		inc 	r11
		ror 	r1,#14
		skm 	r1
		jmp 	#_CDIAdvance 				; this should be the first of max 2 dimensions
		;
		jsr 	#EvaluateInteger 			; get integer into R5
		mov 	r5,r0,#0
		clr 	r8 							; default second dimension is 0 (e.g. 1 !)
		ldm 	r0,r11,#0 					; is the next character a comma ?
		xor 	r0,#TOK_COMMA 
		skz 	r0
		jmp 	#_CDIHaveDimension 			; if so, there is a second dimension
		inc 	r11 						; skip comma
		jsr 	#EvaluateInteger 			; get integer into R8
		mov 	r8,r0,#0
		sknz 	r8 							; must be non-zero.
		jmp 	#BadNumberError
._CDIHaveDimension
		jsr 	#CheckRightBracket 			; check the right bracket is here
		;
		;		Now have R7 ^ Name, R6 ^ Hash R5 Dim 1 R8 Dim 2
		;		
		mov 	r0,r5,#1					; work out memory requirements. Add 1 to each 
		mov 	r1,r8,#1 					; dimension and multiply.
		mult 	r0,r1,#0					; this is the data size
		mov 	r4,r0,#0 					; put the array block size in R4.
		add 	r0,#4 						; link, name, dim 1, dim 2
		push 	r11  						; save R11
		mov 	r11,r7,#0 					; get identifier address
		jsr 	#CreateVariableRecord 		; create a variable record for it.
		pop 	r11 						; restore position
		;
		mov 	r1,r0,#4 					; R1 = Data area
		ldm 	r2,r0,#2					; R2 = Default value
._CDIFill
		stm 	r2,r1,#0 					; fill the data area with the default value
		inc 	r1
		dec 	r4 							; using the saved size
		skz 	r4
		jmp 	#_CDIFill
		;
		stm 	r5,r0,#2 					; write the dimensions out
		stm 	r8,r0,#3
		;
		ldm 	r0,r11,#0 					; next token comma ?
		inc 	r11 						; bump
		xor 	r0,#TOK_COMMA
		sknz 	r0
		jmp 	#_CDINextArray 				; if so, go round again
		dec 	r11 						; undo the bump
		pop 	link
		ret 								; exit if 


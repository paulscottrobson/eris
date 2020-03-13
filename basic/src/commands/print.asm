; *****************************************************************************
; *****************************************************************************
;
;		Name:		print.asm
;		Purpose:	Print statement
;		Created:	4th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;							Print to display
;
; *****************************************************************************

.Command_Print		;; [print]
.Command_Print2		;; [?]
		push 	link
		;
		;		Print loop
		;
._CPRLoop
		ldm 	r0,r11,#0 					; read next token
		sknz	r0 							; exit if end of line, or colon.
		jmp 	#_CPRExitCR
		xor 	r0,#TOK_COLON 				; check for :
		sknz 	r0
		jmp 	#_CPRExitCR
		;
		inc 	r11 						; bump pointer
		;
		xor 	r0,#TOK_SEMICOLON^TOK_COLON ; check for ;
		sknz 	r0
		jmp		#_CPRSemicolon
		xor 	r0,#TOK_SEMICOLON^TOK_COMMA ; check for ,
		sknz 	r0
		jmp 	#_CPRTab
		xor 	r0,#TOK_COMMA^TOK_QUOTE 	; check for '
		sknz 	r0
		jmp 	#_CPRNewLine
		;
		dec 	r11 						; unpick token get.
		jsr 	#EvaluateExpression 		; evaluate something to print.
		ldm 	r0,r10,#esValue1 			; get value into R0
		ldm 	r2,r10,#esReference1 		; if reference
		skz 	r2
		ldm 	r0,r0,#0 					; dereference it
		ldm 	r2,r10,#esType1 			; get type
		skz 	r2 							; if number
		jmp 	#_CPRPrintStr
		mov 	r2,r0,#0 					; print leading space.
		mov 	r0,#' '
		jsr 	#OSPrintCharacter
		mov 	r0,r2,#0
		mov		r1,#$800A					; signed decimal format
		jsr 	#OSIntToStr 				; convert it
._CPRPrintStr		
		jsr 	#OSPrintString 				; print it
		jmp 	#_CPRLoop
		;
		;		New line
		;		
._CPRNewLine
		mov 	r0,#13
		jsr 	#OSPrintCharacter		
		jmp 	#_CPRLoop
		;
		;		Tab print
		;
._CPRTab
		mov 	r0,#9
		jsr 	#OSPrintCharacter		
		;
		;		Check if it's the end , if so exit without printing CR
		;
._CPRSemicolon
		ldm 	r0,r11,#0 					; read next token
		sknz	r0 							; exit if end of line, or colon, without new line.
		jmp 	#_CPRExit
		xor 	r0,#TOK_COLON 				; check for :
		sknz 	r0
		jmp 	#_CPRExit
		jmp 	#_CPRLoop
		;
		;		Exit printing CR
		;
._CPRExitCR
		mov		r0,#13
		jsr 	#OSPrintCharacter
._CPRExit
		pop 	link
		ret

; *****************************************************************************
; *****************************************************************************
;
;		Name:		run.asm
;		Purpose:	Run program
;		Created:	3rd March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;								Run program
;
; *****************************************************************************

.RunProgram	;; [run]
		ldm 	sp,#initialSP 				; reset the stack
		mov 	r10,#evalStack 				; reset the evaluation stack.
		jsr 	#Command_Clear 				; clear command
		mov 	r0,#$17 					; switch colour to white
		jsr 	#OSPrintCharacter
		ldm 	r11,#programCode 			; come back here to start new line.
		;
		;				New line. On entry R11 points to offset word
		;
._RPNewLine
		stm 	r11,#currentLine 			; save current line number.
		ldm 	r0,r11,#0 					; get offset to next line.
		sknz 	r0 							; if zero, then End
		jmp 	#WarmStart
		add 	r11,#2 						; point to first token.
		;
		;				Next command.
		;
._RPNewCommand		
		jsr		#OSManager 					; call keyboard manager routine.
		stm 	r14,#tempStringAlloc 		; clear the temp string reference
		ldm 	r0,r11,#0 					; get next token.
		mov 	r1,r0,#0 					; save in R1 
		inc 	r11 						; skip over token.
		and 	r0,#$F800 					; check it is 0011 1xx e.g. token with type 11xx
		xor 	r0,#$3800 					
		skz 	r0
		jmp 	#_RPNotCommandToken 		
		;
		and 	r1,#$01FF 					; get token ID
		add 	r1,#TokenVectors 			; R1 now points to the token code address
		ldm 	r0,r1,#0 					; get the call address into R0
		brl 	link,r0,#0 					; call that routine
		jmp 	#_RPNewCommand 				; go round again
		;
		;		Not a command token. Could be an identifier, !, or possibly EOL. R11 points
		;		to word following command token.
		;
._RPNotCommandToken		
		sknz 	r1 							; if R1 is zero, end of line, go to new line
		jmp 	#_RPNewLine 				
		dec 	r11 						; unpick the token get
		;
		ldm 	r0,r11,#0 					; get token back
		xor 	r0,#TOK_PLING 				; ! is a special case
		sknz 	r0
		jmp 	#_RPDoLet
		;
		ldm 	r0,r11,#0 					; get token back
		and 	r1,#$C000 					; is it an identifier e.g. 4000-7FFF
		xor 	r1,#$4000 					
		skz 	r1
		jmp 	#SyntaxError 				; if not, it's constant or string constant, syntax error.
._RPDoLet		
		jsr 	#Command_Let 				; try it as a 'let'
		jmp 	#_RPNewCommand 				; and go round again.
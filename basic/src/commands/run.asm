; *****************************************************************************
; *****************************************************************************
;
;		Name:		run.asm
;		Purpose:	Run program
;		Created:	3rd March 2020
;		Reviewed: 	17th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;						Run program / Run "Filename"
;
; *****************************************************************************

.RunProgram	;; [run]
		ldm 	r0,r11,#0 					; what follows ?
		sknz 	r0
		jmp		#RunProgramNoLoad
		xor 	r0,#TOK_COLON
		skz 	r0
		jsr 	#FileLoader 				; if not EOL or colon try loading.
.RunProgramNoLoad
		jsr 	#Command_Clear 				; clear command, erase variables etc.
		ldm 	r11,#programCode 			; address of first line.
		ldm 	r0,r11,#0 					; get offset to next line.
		sknz 	r0 							; if zero, then no program fo exit.
		jmp 	#WarmStart 		
		;
		;				Come here to run program from R11.
		;
.RunProgramR11	
		ldm 	sp,#initialSP 				; reset the stack
		mov 	r10,#evalStack 				; reset the evaluation stack.
		mov 	r0,#$17 					; switch colour to white
		jsr 	#OSPrintCharacter
		;
		;				New line. On entry R11 points to offset word
		;
._RPNewLine
		stm 	r11,#currentLine 			; save current line number.
		add 	r11,#2 						; point to first token.
		;
		;				Next command.
		;
._RPNewCommand		
		jsr		#OSSystemManager 			; call system manager routine no break
		skz 	r0 							; exit on break
		jmp 	#BreakError 				; error if broken.
		ldm 	r0,#hwTimer 				; check timer event due ?
		ldm 	r1,#eventCheckTime
		sub 	r0,r1,#0
		skm 	r0
		jsr 	#EventCheck 				; go actually check.
		;
		;				New instruction at R11
		;
._RPNoCheck		
		stm 	r14,#tempStringAlloc 		; clear the temp string reference.
		ldm 	r0,r11,#0 					; get next token.
		mov 	r1,r0,#0 					; save in R1 
		inc 	r11 						; skip over token.
		and 	r0,#$F800 					; check it is 0011 1xx e.g. token with type 11xx
		xor 	r0,#$3800 					; which is a command token of some sort
		skz 	r0
		jmp 	#_RPNotCommandToken 		
		;
		and 	r1,#$01FF 					; get token ID lower 9 bits
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
		jmp 	#_RPNextLine 				
		dec 	r11 						; unpick the token get
		;
		ldm 	r0,r11,#0 					; get token back
		xor 	r0,#TOK_PLING 				; ! is a special case, we can do !x = 42
		sknz 	r0
		jmp 	#_RPDoLet
		;
		ldm 	r0,r11,#0 					; get token back
		and 	r0,#$C000 					; is it an identifier e.g. 4000-7FFF
		xor 	r0,#$4000 					; then if so this may be a default LET
		skz 	r0
		jmp 	#_RPCheckAsm 				; if not, check for assembler
._RPDoLet		
		jsr 	#Command_Let 				; try it as a 'let'
		jmp 	#_RPNewCommand 				; and go round again.
		;
		;		Check for assembler token, which is one of the first 16
		;
._RPCheckAsm
		ldm 	r0,r11,#0 					; get token back
		and 	r0,#$21F0 					; this checks for tokens from 0-15
		xor 	r0,#$2000 					
		skz 	r0
		jmp 	#SyntaxError
		jsr 	#AssembleInstruction 		; assemble it
		jmp 	#_RPNewCommand 				; go round again.
		;
		;		Advance to next line. If running from CLI offset will be zero so will not
		;		change lines with the 'add'
		;
._RPNextLine
		ldm 	r11,#currentLine 			; get current line
		ldm 	r0,r11,#0 					; get offset this line
		add 	r11,r0,#0 					; advance pointer
		ldm 	r0,r11,#0 					; get offset next line
		sknz 	r0 							; if zero warm start
		jmp 	#WarmStart		
		jmp 	#_RPNewLine

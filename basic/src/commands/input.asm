; *****************************************************************************
; *****************************************************************************
;
;		Name:		input.asm
;		Purpose:	Input string/integer
;		Created:	12th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

.Command_Input	;; [input]
		push 	link
		;
		mov 	r9,#(TOK_PLING & 0x1E00)-0x400
		jsr 	#Evaluator 					; get the input target
		ldm 	r0,r10,#esReference1 		; it *must* be a reference
		sknz 	r0
		jmp 	#SyntaxError		
		;
		jsr 	#OSGetTextPos 				; get text position
		mov 	r1,#charWidth 				; charWidth - x is max entries
		sub 	r1,r0,#0	
		mov 	r0,#inputBuffer 			; this is where it goes.
		;
		jsr 	#OSInputLimit	 			; read it

		;
		;		If number, convert to number and store
		;		If string, concrete and store
		;
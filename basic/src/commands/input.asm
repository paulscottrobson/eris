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
._CINGet		
		jsr 	#OSGetTextPos 				; get text position
		mov 	r1,#charWidth 				; charWidth - x is max entries
		sub 	r1,r0,#0	
		mov 	r0,#inputBuffer 			; this is where it goes.
		;
		jsr 	#OSInputLimit	 			; read it
		;
		ldm 	r1,r10,#esType1 			; integer or string
		skz 	r1				
		jmp 	#_CINString
		;
		mov 	r1,#10 						; extract in base 10
		jsr 	#CompactStringToInteger		; convert to integer
		skz 	r1 							; error
		jmp 	#_CINBadInput 				; couldn't convert
		;
		ldm 	r1,r10,#esValue1 			; target address
		stm 	r0,r1,#0 					; write out value and exit
		;
		pop 	link
		ret
		;
		;		Couldn't convert
		;
._CINBadInput
		jsr 	#OSPrintInline
		string "??"
		jmp 	#_CINGet
		;
		;		String in R0, write to input.
		;
._CINString
		ldm 	r1,r10,#esValue1 			; where to assign to
		jsr 	#StringAssign 				; use the string assign code.
		pop 	link
		ret


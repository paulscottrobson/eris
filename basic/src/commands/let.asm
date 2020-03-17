; *****************************************************************************
; *****************************************************************************
;
;		Name:		let.asm
;		Purpose:	Assignment statement
;		Created:	4th March 2020
;		Reviewed: 	16th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

.Command_Let 		;; [let]
		push 	r9,link
		;
		;		This below. This extracts the precedence level from ! and subtracts
		;		one from it (left shifted 9). This means that only operations above
		;		this (e.g. ! or term) are collected here. 
		;
		;		This lterm can be a variable , !term or term!term
		;
		mov 	r9,#(TOK_PLING & 0x1E00)-0x400
		jsr 	#Evaluator 					; get the lhs of the equals.
		ldm 	r0,r10,#esReference1 		; it *must* be a reference
		sknz 	r0 							; which is a variable/array or a !expression
		jmp 	#SyntaxError
		;
		mov 	r0,#TOK_EQUAL 				; check it is followed by an '='
		jsr 	#CheckNextToken 			
		;
		ldm 	r0,r10,#esType1 			; get the type of the left hand side
		skz 	r0
		jmp 	#_CLString
		;
		;		Integer assignment handler
		;
		ldm 	r1,r10,#esValue1			; R1 = variable address.
		jsr 	#EvaluateInteger 			; evaluate what goes there into R0
		stm 	r0,r1,#0 					; write it and exit
		pop 	r9,link
		ret
		;
		;		String assignment handler
		;
._CLString
		ldm 	r1,r10,#esValue1			; R1 = string target address (e.g. pointer goes here)
		jsr 	#EvaluateString 			; evaluate what goes there
		jsr 	#StringAssign 				; assign that string to R1 - this concretes it as well.
		pop 	r9,link
		ret

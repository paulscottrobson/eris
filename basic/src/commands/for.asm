	; *****************************************************************************
; *****************************************************************************
;
;		Name:		for.asm
;		Purpose:	For/Next
;		Created:	10th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;				FOR <var> = <expr> TO <expr> [STEP <expr>]
;
; *****************************************************************************
;
;			+5 		Reference to <var>
;			+4 		Terminal Value
;			+3		Step value
;			+1,2 	Loop position
;			+0 		'F' marker
;

.Command_FOR		;; 	[for]
		push 	link
		mov 	r9,#(TOK_PLING & 0x1E00)-0x400
		jsr 	#Evaluator 					; get the lhs, which should be a reference
		ldm 	r0,r10,#esReference1 		; check it is a reference
		sknz 	r0
		jmp	 	#TypeMismatchError
		ldm 	r0,r10,#esType1 			; to an integer
		skz 	r0
		jmp	 	#TypeMismatchError
		;
		ldm 	r0,r10,#esValue1 			; get reference for index
		mov		r1,r0,#0 					; put reference in R1 and on stack
		jsr 	#StackPushR0
		;
		mov 	r0,#TOK_EQUAL 				; check next token is an equals
		jsr 	#CheckNextToken
		;
		jsr 	#EvaluateInteger 			; get the start value
		stm 	r0,r1,#0 					; write into the reference
		;
		mov 	r0,#TOK_TO 					; check TO follows.
		jsr 	#CheckNextToken
		;
		jsr 	#EvaluateInteger 			; get the terminal value and push it
		jsr 	#StackPushR0
		;
		ldm 	r1,r11,#0 					; see if next token is STEP
		xor 	r1,#TOK_STEP
		mov 	r0,#1 						; default STEP value
		skz 	r1 
		jmp 	#_CFHaveStep
		;
		inc 	r11 						; step over STEP
		jsr 	#EvaluateInteger 			; get the STEP value
._CFHaveStep
		jsr 	#StackPushR0 				; push the step value on the stack		
		jsr 	#StackPushPosition 			; push current position/line offset
		jsr 	#StackPushMarker 			; push an 'F' marker
		word 	'F'
		pop 	link
		ret

; *****************************************************************************
;
;									NEXT [<var>]
;
; *****************************************************************************
		
.Command_Next		;; [next]
		push 	link
		jsr 	#StackCheckMarker 			; check TOS is an 'F' marker.
		word 	'F'
		jmp 	#NextError
		;
		ldm 	r2,#returnStackPtr 			; stack base
		;
		ldm 	r0,r11,#0 					; is there an identifier following ?
		and 	r0,#$C000
		xor 	r0,#$4000
		skz 	r0
		jmp 	#_CNDefaultIdentifier
		;
		mov 	r9,#(TOK_PLING & 0x1E00)-0x400
		jsr 	#Evaluator 					; get the variable reference
		ldm 	r3,r10,#esValue1
		ldm 	r1,r2,#stackPosSize+3 		; get the one in the FOR
		xor 	r1,r3,#0
		skz 	r1
		jmp 	#BadIndexError 				; they are different
		;
._CNDefaultIdentifier		
		;
		ldm 	r3,r2,#stackPosSize+3 		; R3 is the reference to the index
		ldm 	r4,r2,#stackPosSize+2 		; R4 is the terminal value
		ldm 	r5,r3,#0 					; R5 is current index
		ldm 	r6,r2,#stackPosSize+1 		; R6 is step
		skp 	r6 							; if R6 < 0 decrement the terminal value
		dec 	r4
		;
		mov		r1,r4,#0 					; R1 = terminal-current
		ldm 	r5,r3,#0
		sub 	r1,r5,#0
		;
		add 	r5,r6,#0 					; add step to index and write it back
		stm 	r5,r3,#0
		;
		sub 	r4,r5,#0 					; R4 = terminal-current
		skse 	r4,r1,#0 					; have the signs of R1/R4 changed
		jmp 	#_CNEndLoop
		;
._CNLoop		
		jsr 	#StackPopPosition 			; no, restore position from stack.
		pop 	link
		ret
		;
._CNEndLoop
		mov 	r0,#4+stackPosSize 			; reclaim the stack space.
		jsr 	#StackPopWords
		pop 	link
		ret


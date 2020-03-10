; *****************************************************************************
; *****************************************************************************
;
;		Name:		evaluate.asm
;		Purpose:	Expression evaluator
;		Created:	3rd March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;			Evaluate expression @ R11, level R10, may return reference
;
; *****************************************************************************

.EvaluateExpression
		push 	r9,link					
		clr 	r9 							; R9 is the current precedence level
		jsr 	#Evaluator 					; call the actual routine
		pop 	r9,link 					; restore the registers
		ret

; *****************************************************************************
;
;			General evaluator. R9 precedence R10 stack R11 code
;
; *****************************************************************************

.Evaluator
		push 	r0,r1,r2,r3,r4,r5,r6,link
		ldm 	r0,r11,#0 					; read the next character
		skm 	r0 							; if it is -ve it is a constant
		jmp 	#_EVNotConstant
		;
		and 	r0,#$7FFF 					; make it in the correct range.
		stm 	r0,r10,#esValue1 			; save value
		stm 	r14,r10,#esType1 			; set type and reference to 0
		stm 	r14,r10,#esReference1 		; e.g. constant integer.
		inc 	r11 						; skip over the constant
		jmp 	#_EVHaveTerm

._EVNotConstant		
		sknz 	r0  						; syntax error as no expression.
		jmp 	#SyntaxError
		add 	r0,r0,#0 					; shift R0 left (quicker than ror :) )
		skp 	r0 							; if this is -ve it is 4000-7FFF which is a variable
		jmp 	#_EVVariable 				; identifier.
		add 	r0,r0,#0 					; and shift it left again.
		skp 	r0 							; if this is -ve it is 2000-3FFF which might be
		jmp 	#_EVUnaryFunction 			; a unary function.
		;
		mov 	r0,r11,#1 					; this is the address of the string, e.g. word following
		stm 	r0,r10,#esValue1 			; save type, value, reference
		stm 	r15,r10,#esType1 			; type is non zero.
		stm 	r14,r10,#esReference1 
		;
		ldm 	r0,r11,#0 					; get length and add to pointer
		and 	r0,#$00FF
		add 	r11,r0,#0 
		;
		;		At this point, we have a single term (value or reference) in the current
		;		stack level.
		;
._EVHaveTerm
		ldm 	r0,r11,#0 					; get the next character to see if it is a binary operator
		and 	r0,#$F000 					; is it 0010 pppx xxxx xxxx e.g. a keyword.
		xor 	r0,#$2000 					
		skz 	r0 							; 
		jmp 	#_EVExit 					; if so, exit
		;
		;		Check the precedence
		;
		ldm 	r0,r11,#0 					; get precedence, we leave it in the rotated format.
		and 	r0,#$1E00 					; which is the type nibble at bits 12..9
		sub 	r0,r9,#0 					; subtract current precedence level, if > do a binary op.
		dec 	r0 							; now if >= do a binary op, fails if equal.
		skp 	r0 
		jmp 	#_EVExit 
		;
		;		Evaluate the Right hand side.
		;
		ldm 	r1,r11,#0 					; get binary operator in R1
		inc 	r11 						; skip over it.
		mov 	r2,r9,#0 					; save old precedence in R2
		;
		mov 	r9,r1,#0 					; put operator precedence in R9
		and 	r9,#$1E00
		add 	r10,#stackElementSize 		; point to next stack slot.
		jsr 	#Evaluator 					; call the routine recursively.
		sub 	r10,#stackElementSize 		; fix the stack back
		mov 	r9,r2,#0 					; restore operator precedence.
		;
		;		call handlers. These can break r0,r1,r2 only.
		;
._EVCallHandler		
		and 	r1,#$01FF 					; get token ID out
		add 	r1,#TokenVectors 			; point into token table
		ldm 	r0,r1,#0 					; read address
		brl 	link,r0,#0 					; call it.
		jmp 	#_EVHaveTerm 				; and go round again.
		;
		;		Exit evaluator.
		;
._EVExit
		pop 	r0,r1,r2,r3,r4,r5,r6,link
		ret
		;
		;		R11 points to an identifier
		;
._EVVariable
		jsr 	#GetVariableReference 		; get a variable reference
		jmp 	#_EVHaveTerm 				; and do whatever with it.
		;
		;		R11 points to a keyword, possibly a unary function, and the special case
		; 		of unary - because of the dual use of '-' and '!'
		;
._EVUnaryFunction
		ldm 	r0,r11,#0	 				; get the keyword back
		xor 	r0,#TOK_MINUS 				; is it -xxxx which is a special case because
		skz 	r0 							; - is a binary and a unary operator.
		jmp 	#_EVCheckPling
		inc 	r11 						; advance over the keyword
		jsr 	#EvaluateTermInteger 		; evaluate term at current level, dereference it.
		clr 	r1 							; calculate the new value
		sub 	r1,r0,#0 				
		stm 	r1,r10,#esValue1 			; update it
		jmp 	#_EVHaveTerm 				; and we now have a term
		;
._EVCheckPling		
		xor 	r0,#TOK_MINUS^TOK_PLING 	; check it's pling
		skz 	r0
		jmp 	#_EVCheckUnary
		;
		inc 	r11 						; advance over the keyword
		jsr 	#EvaluateTermInteger 		; evaluate term at current level, dereference it.
		stm 	r15,r10,#esReference1 		; and make it a reference again.
		jmp 	#_EVHaveTerm
		;
		;		Check for unary function.
		;
._EVCheckUnary	
		ldm 	r0,r11,#0 					; get the keyword back
		and 	r0,#$1E00 					; check if it's a unary function
		xor		r0,#$1000 					; 8 << 9 as unary is code 8
		skz 	r0
		jmp 	#SyntaxError
		;
		ldm 	r1,r11,#0 					; get the keyword back
		inc 	r11 						; skip over it.
		jmp 	#_EVCallHandler				; and call the routine

; *****************************************************************************
;
;		This is the handler for |constshift which precedes the high 
;		values 8000-7FFF
;
; *****************************************************************************

.ConstShiftHandler 	;; [|constshift]
		ldm 	r0,r11,#0 					; it's already got bit 15 set as its tokenised
		stm 	r0,r10,#esValue1 			
		stm 	r14,r10,#esType1 			; and it's an integer constant
		stm 	r14,r10,#esReference1
		inc 	r11 						; skip over it.
		ret

; *****************************************************************************
;
;		Evaluate an integer term @ R11, stack level R10, return value in R0.
;		this is used for - and |constshift
;
; *****************************************************************************

.EvaluateTermInteger
		push 	r1,r9,link
		mov 	r9,#$4000 					; impossibly high precedence => term only.
		jsr 	#Evaluator 					; evaluate the term.
		;
		ldm 	r1,r10,#esValue1 			; get the value or reference.
		ldm 	r9,r10,#esReference1 		; R9 is the reference flag
		skz 	r9  						; dereference it.
		ldm 	r1,r1,#0 
		stm 	r1,r10,#esValue1 			; write the value back
		stm 	r14,r10,#esReference1 		; clear the reference flag.
		;
		ldm 	r9,r10,#esType1 			; check type integer
		skz 	r9
		jmp 	#TypeMismatchError 			; wrong type
		ldm 	r0,r10,#esValue1 			; get the value/address into R0
		pop 	r1,r9,link
		ret

; *****************************************************************************
;
;				  Evaluate string at R11, stack in R10 => R0
;
; *****************************************************************************

.EvaluateString
		push 	link
		jsr 	#EvaluateExpression 		; evaluate 
		ldm 	r0,r10,#esType1 			; check type.
		skz		r0 							; check it is integer
		jmp 	#EvaluateCommon 			; if it isn't, do the common deref code
		jmp 	#TypeMismatchError 			; integer and we wanted a string

; *****************************************************************************
;
;				  Evaluate integer at R11, stack in R10 => R0
;
; *****************************************************************************

.EvaluateInteger
		push 	link
		jsr 	#EvaluateExpression 		; evaluate 
		ldm 	r0,r10,#esType1 			; check type.
		skz		r0 							; check it is integer
		jmp 	#TypeMismatchError 			; no, it wasn't.
		;
.EvaluateCommon
		ldm 	r0,r10,#esReference1		; is it a reference.
		skz 	r0 							
		jmp 	#_ECReference 				; no, it's a reference.
		ldm 	r0,r10,#esValue1 			; value in R0
		pop 	link 						; and exit.
		ret
._ECReference
		ldm 	r0,r10,#esValue1 			; dereference the result
		ldm 	r0,r0,#0
		stm 	r0,r10,#esValue1
		stm 	r14,r10,#esReference1
		pop 	link
		ret

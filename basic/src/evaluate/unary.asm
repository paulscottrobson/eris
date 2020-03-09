; *****************************************************************************
; *****************************************************************************
;
;		Name:		unary.asm
;		Purpose:	Basic unary functions
;		Created:	4th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;						Dummy for & and % which affect listing
;
; *****************************************************************************

.Unary_Hex		;; [&]
.Unary_Bin		;; [%]
		jmp 	#EvaluateInteger 			; get integer into R0.

; *****************************************************************************
;
;							( is a unary function :)
;
; *****************************************************************************

.Unary_Parenthesis 	;; [(]
		push 	link
		jsr 	#EvaluateExpression 		; do the body, ending with )
		jsr 	#CheckRightBracket 			; check there's a right bracket
		pop 	link
		ret

; *****************************************************************************
;
;							Absolute value
;
; *****************************************************************************

.Unary_Abs		;; [abs(]
		push 	link
		jsr 	#EvaluateInteger 			; get integer into R0.
		clr 	r1 							; calculate -R0
		sub 	r1,r0,#0
		skp 	r0 							; if R0 < 0
		mov 	r0,r1,#0 					; use -R0
		stm 	r0,r10,#esValue1 			; update value
		jsr 	#CheckRightBracket 			; check there's a right bracket
		pop 	link
		ret

; *****************************************************************************
;
;								Sign
;
; *****************************************************************************

.Unary_Sgn		;; [sgn(]
.Unary_Sgn2		;; [sign(]
		push 	link
		jsr 	#EvaluateInteger 			; get integer into R0.
		mov 	r1,#1 						; start with 1
		skp 	r0 							; if < 0 then -1
		mov		r1,#-1
		sknz	r0 							; if 0 then 0
		clr 	r1
		stm 	r1,r10,#esValue1 			; update value
		jsr 	#CheckRightBracket 			; check there's a right bracket
		pop 	link
		ret


; *****************************************************************************
;
;								Len
;
; *****************************************************************************

.Unary_Len		;; [len(]
.Unary_Len2		;; [length(]
		push 	link
		jsr 	#EvaluateString 			; get string into R0.
		ldm 	r0,r0,#0 					; read the length byte
		stm 	r0,r10,#esValue1 			; update value
		stm 	r14,r10,#esType1 			; convert to integer
		jsr 	#CheckRightBracket 			; check there's a right bracket
		pop 	link
		ret

; *****************************************************************************
;
;								Asc
;
; *****************************************************************************

.Unary_Asc		;; [asc(]
		push 	link
		jsr 	#EvaluateString 			; get string into R0.
		ldm 	r0,r0,#0 					; read first double character
		and 	r0,#$00FF 					; extract low character
		stm 	r0,r10,#esValue1 			; update value
		stm 	r14,r10,#esType1 			; convert to integer
		jsr 	#CheckRightBracket 			; check there's a right bracket
		pop 	link
		ret

; *****************************************************************************
;
;								Peek
;
; *****************************************************************************

.Unary_Peek		;; [peek(]
		push 	link
		jsr 	#EvaluateInteger 			; get integer into R0.
		ldm 	r0,r0,#0 					; read byte there
		stm 	r0,r10,#esValue1 			; update value
		jsr 	#CheckRightBracket 			; check there's a right bracket
		pop 	link
		ret

; *****************************************************************************
;
;								Inkey
;
; *****************************************************************************

.Unary_Inkey		;; [inkey(]
		push 	link
		jsr 	#CheckRightBracket 			; check there's a right bracket
		pop 	link
		;
.UnaryInkeyNoCheck		
		push 	link
		jsr 	#OSGetKeyboard 				; wait for key press.
		stm 	r0,r10,#esValue1 			; update value
		stm 	r14,r10,#esType1 			; make integer constant
		stm 	r14,r10,#esReference1			
		pop 	link
		ret

; *****************************************************************************
;
;								Get
;
; *****************************************************************************

.Unary_Get		;; [get(]
		push 	link
		jsr 	#CheckRightBracket 			; check there's a right bracket
._UGWait
		jsr 	#UnaryInkeyNoCheck 			; inkey but wait for key press.
		ldm 	r0,r10,#esValue1 		
		sknz	r0
		jmp 	#_UGWait		
		pop 	link
		ret

; *****************************************************************************
;
;					Random - two forms rnd() and rnd(low,high)
;
; *****************************************************************************

.Unary_Rnd		;; [rnd(]
.Unary_Rnd2		;; [random(]
		push 	link
		jsr 	#OSRandom16 				; get random #
		ldm 	r1,r11,#0 					; is the next token ) ?
		xor 	r1,#TOK_RPAREN
		sknz 	r1
		jmp 	#Unary_RndExit

		mov		r2,r0,#0 					; random number in R2
		jsr 	#EvaluateInteger 			; get start value in R3
		mov 	r3,r0,#0
		jsr 	#CheckComma
		jsr 	#EvaluateInteger 			; get end value
		mov 	r1,r0,#1 					; r1 = end-start+1 e.g. the range.
		sub 	r1,r3,#0
		mov 	r0,r2,#0 					; r0 = random #
		jsr 	#OSUDivide16 				; unsigned division
		mov 	r0,r1,#0 					; modulus
		add 	r0,r3,#0 					; add start value

.Unary_RndExit
		stm 	r0,r10,#esValue1 			; update value
		stm 	r14,r10,#esType1 			; make integer constant
		stm 	r14,r10,#esReference1			
		jsr 	#CheckRightBracket 			; check there's a right bracket
		pop 	link
		ret

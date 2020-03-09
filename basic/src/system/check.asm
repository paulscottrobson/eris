; *****************************************************************************
; *****************************************************************************
;
;		Name:		check.asm
;		Purpose:	Syntax Checkers
;		Created:	4th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;					Check if next character is R0 (general)
;
; *****************************************************************************

.CheckNextToken
		push 	r1
		ldm 	r1,r11,#0  					; get next
		inc 	r11
		xor 	r0,r1,#0 					; zero if matches
		skz 	r0
		jmp 	#SyntaxError
		pop 	r1
		ret

; *****************************************************************************
;
;							Check if next character is )
;
; *****************************************************************************

.CheckRightBracket
		push 	r0
		ldm 	r0,r11,#0
		inc 	r11
		xor 	r0,#TOK_RPAREN
		skz 	r0
		jmp 	#MissingBracketError
		pop 	r0
		ret
		
; *****************************************************************************
;
;							Check if next character is ,
;
; *****************************************************************************

.CheckComma
		push 	r0
		ldm 	r0,r11,#0
		inc 	r11
		xor 	r0,#TOK_COMMA
		skz 	r0
		jmp 	#MissingCommaError
		pop 	r0
		ret


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

; *****************************************************************************
;
;							   Type character in R0
;
;			Returns 0 : punctuation 1 : alphabet or '.' 2: number
;
; *****************************************************************************
		
.GetCharacterType
		push 	r1 							; R1 is the return value
		;
		mov 	r1,r0,#0 					; check if in L/C range
		sub 	r1,#96
		sklt 
		sub 	r0,#32 						; if so shift it.
		;		
		clr 	r1 							; return 0 for < '0'
		sub 	r0,#'0' 					; total subtract is 48
		skge
		jmp 	#_GCTExit
		mov 	r1,#2 						; return 2, number
		sub 	r0,#10 						; total subtract is 58
		skge
		jmp 	#_GCTExit 					; if 0-9 then exit
		;
		clr 	r1 							; check from 58 to 65
		sub 	r0,#7						
		skge
		jmp 	#_GCTExit
		sub 	r0,#26 						; subtracted 26 e.g. alphabet
		mov 	r1,#1 						; return 1 if so.
		skge
		jmp 	#_GCTExit

		mov		r1,#2 						; check for the '.'
		xor 	r0,#'.'-'0'-10-7-26 		
		sknz 	r0
		clr 	r1 							; if it is return '.' 							

._GCTExit
		mov 	r0,r1,#0 					; return type in R1
		pop 	r1
		ret

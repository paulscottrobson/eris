; *****************************************************************************
; *****************************************************************************
;
;		Name:		check.asm
;		Purpose:	Syntax Checkers
;		Created:	4th March 2020
;		Reviewed: 	16th March 2020
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
		xor 	r0,r1,#0 					; zero if matches the token 
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
		ldm 	r0,r11,#0 					; get next
		inc 	r11
		xor 	r0,#TOK_RPAREN 				; zero if ) token
		skz 	r0
		jmp 	#MissingBracketError
		pop 	r0
		ret
		
; *****************************************************************************
;
;							Check if next character is #
;
; *****************************************************************************

.CheckHash
		push 	r0
		ldm 	r0,r11,#0 					; get next
		inc 	r11
		xor 	r0,#TOK_HASH 				; zero if # token
		skz 	r0
		jmp 	#MissingHashError
		pop 	r0
		ret

; *****************************************************************************
;
;							Check if next character is ,
;
; *****************************************************************************

.CheckComma
		push 	r0
		ldm 	r0,r11,#0 					; get next
		inc 	r11
		xor 	r0,#TOK_COMMA 				; zero if , token
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
		push 	r1 							; R1 is the return value, 0-2
		;
		mov 	r1,#1 						; check if it is a '.' first - this counts as an identifier
		xor 	r0,#'.'
		sknz 	r0
		jmp 	#_GCTExit 					; if so return 1
		xor 	r0,#'.' 					; fix it back
		;
		mov 	r1,r0,#0 					; check if in L/C range 96-127 e.g. capitalise
		sub 	r1,#96
		sklt 
		sub 	r0,#32 						; if so shift it.
		;		
		;		Check 0..9
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
		;		Check characters between 9 and A exclusive
		;
		clr 	r1 							; check from 58 to 65
		sub 	r0,#7						
		skge
		jmp 	#_GCTExit
		;
		;		Check for A..Z
		;
		sub 	r0,#26 						; subtracted 26 e.g. alphabet
		mov 	r1,#1 						; return 1 if so.
		skge
		jmp 	#_GCTExit
		mov		r1,#2 						; return 2 for punctuation.

._GCTExit
		mov 	r0,r1,#0 					; return type in R1
		pop 	r1
		ret

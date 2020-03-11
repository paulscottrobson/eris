; *****************************************************************************
; *****************************************************************************
;
;		Name:		list.asm
;		Purpose:	List program.
;		Created:	11th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

.Command_List 		;; [list]
		clr 	r6 							; R6 is the lowest listed line number
		clr 	r7 							; R7 is the current indentation.
		mov 	r8,#10 						; R8 is current display base.
		;
		ldm 	r0,r11,#0 					; read next token.
		sknz 	r0 							; if EOL start from 0
		jmp 	#_CLHaveLine
		xor 	r0,#TOK_COLON 				; if : start from 0
		sknz 	r0
		jmp 	#_CLHaveLine
		jsr 	#EvaluateInteger 			; get start line into R6
		mov 	r6,r0,#0 	
._CLHaveLine
		ldm 	r11,#programCode 			; R11 is the pointer to the current line.
._CLListLoop
		ldm 	r0,r11,#0 					; get the offset, if zero, warm start.
		sknz 	r0
		jmp 	#WarmStart					
		;
		ldm 	r0,r11,#1 					; get line number
		skp 	r0 							; we do not list -ve numbers by default
		jmp 	#_CLListNextLine
		;
		sub 	r0,r6,#0 					; compare against the lowest line
		sklt 								; out of range
		jsr 	#ListOneLine
._CLListNextLine		
		ldm 	r0,r11,#0 					; get offset
		add 	r11,r0,#0 					; add to current line
		jmp 	#_CLListLoop 				; and loop around

; *****************************************************************************
;
;								List line at R11
;
; *****************************************************************************

.ListOneLine
		push 	r6,r11,link
		;
		ldm 	r0,r11,#1 					; get line number
		mov 	r1,#10 						; base
		jsr 	#OSIntToStr 				; convert to string.
		jsr 	#OSPrintString 				; print string.
		ldm 	r0,r0,#0					; get string length
		mov 	r1,r7,#6 					; get indent + 6
		sub 	r1,r0,#0 					; subtract length of string, spacing to code
._LOLSpacing
		mov 	r0,#$20
		jsr 	#OSPrintCharacter
		dec 	r1
		skz 	r1
		jmp 	#_LOLSpacing
		;
		add 	r11,#2 						; point to first token.
		clr 	r8 							; clear last-is-identifier flag
		stm 	r14,#lastListToken			; clear the last token value.
._LOLLoop
		ldm 	r0,r11,#0 					; check end of line
		sknz 	r0
		jmp 	#_LOLExit
		jsr 	#DecodeToken 				; decode one token
		jmp 	#_LOLLoop
._LOLExit				
		mov 	r0,#13 						; print new line
		jsr 	#OSPrintCharacter
		pop 	r6,r11,link
		ret

		
; *****************************************************************************
;
;							Decode one token at [R11]
;
; *****************************************************************************

.DecodeToken
		push 	link
		clr 	r9 							; clear the index in this token value.
		ldm 	r0,r11,#0 					; get this token and save on stack
		push 	r0
		;
		;		Check for constant first. This is either $8000-$FFFF or
		;		the Constant Shift followed by that value.
		;
		mov 	r1,#$8000 					; this is used to flip the constant
		ldm 	r0,r11,#0 					; is it -ve, it's a constant
		skp 	r0
		jmp 	#_DTDigit
		xor 	r0,#TOK_VBARCONSTSHIFT 		; is it the constant shift ?
		skz 	r0
		jmp 	#_DTNotConstant
		clr 	r1 							; we don't flip the constant
		inc 	r11 						; skip over constant shift
._DTDigit
		ldm 	r0,r11,#0 					; get the value and skip it
		inc 	r11
		xor 	r0,r1,#0 					; flip it
		mov 	r1,#10 						; start with base 10
		ldm 	r2,#lastListToken 			; what was the previous list token ?
		xor 	r2,#TOK_PERCENT 			; if % base 2
		sknz 	r2
		mov 	r1,#2
		xor 	r2,#TOK_PERCENT^TOK_AMPERSAND ; if & base 16
		sknz 	r2
		mov 	r1,#16
		jsr 	#OSIntToStr 				; convert to string and print it
		jsr 	#ListPrintString
		jmp 	#_DTExit
		;
		;		Check for quoted string
		;
._DTNotConstant		
		ldm 	r0,r11,#0 					; check if 01xx
		and 	r0,#$FF00
		xor 	r0,#$0100
		skz 	r0
		jmp 	#_DTNotString
		mov 	r0,#'"'
		jsr 	#ListPrintCharacter
		mov 	r0,r11,#1 					; print the string
		jsr 	#ListPrintString
		mov 	r0,#'"'
		jsr 	#ListPrintCharacter
		;
		ldm 	r0,r11,#0 					; get the token, with the size.
		and 	r0,#$00FF 				
		add 	r11,r0,#0 					; skip over the string
		jmp 	#_DTExit 
		;
		;		So it's now either a token, or an identifier.
		;
._DTNotString

		inc 	r11

._DTExit
		pop 	r0 							; get the token and update last token
		stm 	r0,#lastListToken
		pop 	link
		ret


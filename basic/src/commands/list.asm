; *****************************************************************************
; *****************************************************************************
;
;		Name:		list.asm
;		Purpose:	List program.
;		Created:	11th March 2020
;		Reviewed: 	17th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

.Command_List 		;; [list]
		mov 	r0,#12 						; clear the screen-my decision !
		jsr 	#OSPrintCharacter
		;
		;		Find the start
		;
		clr 	r6 							; R6 is the lowest listed line number
		clr 	r7 							; R7 is the current indentation.
		;
		ldm 	r0,r11,#0 					; read next token.
		sknz 	r0 							; if EOL start from 0
		jmp 	#_CLHaveLine
		xor 	r0,#TOK_COLON 				; if : start from 0
		sknz 	r0
		jmp 	#_CLHaveLine
		;
		ldm 	r0,r11,#0 					; get next token again
		and 	r0,#$C000 					; is it an identifier
		xor 	r0,#$4000
		skz 	r0
		jmp 	#_CLDoAsInteger
		;
		mov 	r1,r11,#0 					; we have to convert the identifier so it is a array
._CLMakeArray 								; because that's how it's stored.		
		ldm 	r0,r1,#0 					; set array bit
		add 	r0,#$0800
		stm 	r0,r1,#0
		inc 	r1  						; bump
		ror 	r0,#14 						; until end bit set
		skm 	r0
		jmp 	#_CLMakeArray
		jsr 	#ProcedureSearch 			; find procedure
		ldm 	r6,r2,#1 					; line number in R6
		jmp 	#_CLHaveLine
._CLDoAsInteger
		jsr 	#EvaluateInteger 			; get start line into R6		
		mov 	r6,r0,#0 	
._CLHaveLine
		;
		;		Now scan for lines >= R6
		;
		ldm 	r11,#programCode 			; R11 is the pointer to the current line.
._CLListLoop
		jsr 	#OSGetTextPos 				; get text position
		sub 	r1,#CharHeight-4 			; check off the bottom
		sklt
		jmp 	#WarmStart
		;
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
		push 	r6,r10,r11,link
		;
		mov 	r10,r11,#0 					; save SOL in R10
		mov 	r0,#-indentStep 	 		; do down indents before
		mov 	r1,#13<<9
		jsr 	#ListCheckAdjustIndent
		;
		;		Print line number
		;	
		mov 	r0,#theme_line+$10			; line number theme
		jsr 	#OSPrintCharacter

		ldm 	r0,r11,#1 					; get line number
		mov 	r1,#10 						; base to use
		jsr 	#OSIntToStr 				; convert to string.
		jsr 	#OSPrintString 				; print string.
		ldm 	r0,r0,#0					; get string length
		mov 	r1,#6 						; get indent + 6
		skm 	r7 							; add indent if not -ve
		add 	r1,r7,#0
		sub 	r1,r0,#0 					; subtract length of string, spacing to code
._LOLSpacing
		mov 	r0,#$20 					; pad out so start of lines align with indents
		jsr 	#OSPrintCharacter
		dec 	r1
		skz 	r1
		jmp 	#_LOLSpacing
		;
		add 	r11,#2 						; point to first token.
		clr 	r8 							; clear last-is-identifier flag
		stm 	r14,#lastListToken			; clear the last token value.
		;
		;		List tokens until done.
		;
._LOLLoop
		ldm 	r0,r11,#0 					; check end of line
		sknz 	r0
		jmp 	#_LOLExit
		jsr 	#DecodeToken 				; decode one token
		jmp 	#_LOLLoop
._LOLExit				
		jsr 	#OSPrintInline 				; black background and new line
		string 	"[10][0F][12][0D]"		

		mov 	r0,#indentStep 	 			; do up indents after
		mov 	r1,#15<<9
		jsr 	#ListCheckAdjustIndent

		skp 	r7 							; clear indent if -ve
		clr 	r7  						; most likely started editing in a structure

		pop 	r6,r10,r11,link
		ret

; *****************************************************************************
;
;							Decode one token at [R11]
;
; *****************************************************************************

.DecodeToken
		push 	link
		clr 	r9 							; clear the position index in this token value.
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
		mov 	r0,#theme_const+$10
		jsr 	#OSPrintCharacter
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
		mov 	r0,#theme_string+$10 		; string printing code
		jsr 	#OSPrintCharacter
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
		ldm 	r0,r11,#0 					; get the token
		add 	r0,r0,#0 					; shift bit 14 into bit 15
		skm 	r0 							; identifier if set 01xx xxxx xxxx xxxx
		jmp 	#_DTIsToken 				; token if 001x xxxx xxxx xxxx
		;
		;		It's an identifier
		;
		mov 	r0,#theme_ident+$10
		jsr 	#OSPrintCharacter
		mov 	r0,r11,#0 					; so print identifier here
		jsr 	#ListPrintEncodedIdentifier
		mov 	r11,r0,#0 					; and update when finished.
		jmp 	#_DTExit
		;
		;		It's a token
		;
._DTIsToken
		mov 	r0,#theme_keyword+$10 		; print quote in reverse blue
		jsr 	#OSPrintCharacter
		ldm 	r0,r11,#0
		xor 	r0,#TOK_QUOTE
		skz 	r0
		jmp 	#_DTNoReverse
		jsr 	#OSPrintInline
		string 	"[14][0F]"
._DTNoReverse		
		ldm 	r1,r11,#0 					; get the token
		and 	r1,#$01FF 					; this is the token ID, lower 9 bits
		mov 	r2,#TokeniserWords 			; this is the table address
._DTFindToken
		sknz 	r1 							; go forward till found the token text record
		jmp 	#_DTHaveToken			
		dec 	r1 							; dec count
		ldm 	r0,r2,#0 					; get string length
		and 	r0,#$00FF
		add 	r2,r0,#1 					; advance to next record
		jmp 	#_DTFindToken
		;
._DTHaveToken				
		mov 	r0,r2,#1 					; R0 now contains the token text address
		ldm 	r3,r0,#0 					; get the first token
		skm 	r3 							; +ve print as identifier
		jsr 	#ListPrintEncodedIdentifier
		skp 	r3
		jsr 	#ListPrintPunctuation
		inc 	r11							; advance over token
._DTExit
		pop 	r0 							; get the token and update last token
		stm 	r0,#lastListToken
		pop 	link
		ret

; *****************************************************************************
;
;		Check code line at R10 for command type R1, when found, adjust 
;		indent in R7 by R0
;
;		down indenting is done before list
;		up indent is done after list
;		else .... is out by one.
;
; *****************************************************************************

.ListCheckAdjustIndent
		push 	r0,r1,r2,r10
		inc 	r10
._LCAILoop
		inc 	r10 						; pre inc
._LCAILoopNoInc		
		ldm 	r2,r10,#0 					; check for strings/EOL
		sknz 	r2
		jmp 	#_LCAIExit
		and 	r2,#$FF00
		xor 	r2,#$0100
		sknz 	r2
		jmp 	#_LCAIStringSkip
		;
		ldm 	r2,r10,#0 					; get token back.		
		and 	r2,#$E000 					; is it a token
		xor 	r2,#$2000
		skz 	r2
		jmp 	#_LCAILoop 					; if not go back.
		;
		ldm 	r2,r10,#0 					; get token back
		and 	r2,#15<<9 					; isolate type
		xor 	r2,r1,#0 					; found it ?
		sknz 	r2
		add 	r7,r0,#0 					; add indent adjustment
		jmp 	#_LCAILoop
		;
._LCAIStringSkip:
		ldm 	r2,r10,#0 					; add string data length
		and 	r2,#$00FF
		add 	r10,r2,#0
		jmp 	#_LCAILoopNoInc		

._LCAIExit		
		pop 	r0,r1,r2,r10
		ret



		
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
;				Print character in R0, enforcing syntactic spacing
;
;	Maintains state : R8 is #0 if the last character printed was an identifier
;					  R9 is the index in the current printed element.
;
; *****************************************************************************

.ListPrintCharacter
		and 	r0,#$00FF					; convert to a byte
		sknz 	r0 							; ignore character zero
		ret
		push 	r6,r7,link
		mov 	r6,r0,#0 					; save character in R6
		jsr 	#GetCharacterType 			; type ?		
		mov 	r7,r0,#0 					; flag in R7
		;
		skz 	r9 							; first character of element ?
		jmp 	#_LPCPrint
		sknz 	r7 							; is this character an identifier ?
		jmp 	#_LPCPrint
		sknz 	r8 							; was the last character an identifier ?
		jmp 	#_LPCPrint

		mov 	r0,#' '						; print a seperating space.
		jsr 	#OSPrintCharacter		

._LPCPrint
		mov 	r8,r7,#0 					; update last character flag
		inc 	r9 							; increment index
		mov 	r0,r6,#0 					; get character back and print it.
		jsr 	#OSPrintCharacter		
		pop 	r6,r7,link
		ret

; *****************************************************************************
;
;							Decode one token at [R11]
;
; *****************************************************************************

.DecodeToken
		push 	link
		clr 	r9 							; reset the index in current element flag
		mov 	r0,#'A'
		jsr 	#ListPrintCharacter
		mov 	r0,#'0'
		jsr 	#ListPrintCharacter
		mov 	r0,#'B'
		jsr 	#ListPrintCharacter
		mov 	r0,#'9'
		jsr 	#ListPrintCharacter
		inc 	r11
		pop 	link
		ret


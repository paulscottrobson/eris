; *****************************************************************************
; *****************************************************************************
;
;		Name:		tokeniser.asm
;		Purpose:	Coloured ASCII -> Tokenised code
;		Created:	12th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;		Tokenise coloured ASCII at R0. Return address of buffer in R0
;	 	or 0 if tokenising failed.
;
; *****************************************************************************

.TokeniseString	
		push 	link
		mov 	r9,#tokenBuffer+1 			; tokenised code goes here. Allow 1 so can build line#/offset if reqd
		mov 	r8,r0,#0 					; characters come from here.
		mov 	r7,#$007F 					; R7 is the character mask 					
		;
		;		Main tokenising loop
		;
._TSLoop		
		ldm 	r0,r8,#0 					; look at next character
		and 	r0,r7,#0 					; as a character
		mov 	r3,r0,#0 					; put in R3.
		sknz 	r0
		jmp 	#_TSExit 					; exit if end of list
		xor 	r0,#' '						; if space , skip over
		inc 	r8
		sknz 	r0
		jmp 	#_TSLoop
		dec 	r8 							; R8 now points to current character
		;
		jsr 	#TokeniseElement 			; do one element
		skz 	r0 							; fail if return zero
		jmp 	#_TSFail
		jmp 	#_TSLoop

._TSExit
		mov 	r0,#tokenBuffer 			; return token buffer
		sknz 	r0 							; skip the clear
._TSFail
		clr 	r0							; come here if you fail.
		pop 	link
		ret

; *****************************************************************************
;
;		Tokenise a single element @ R8. First char in R3. Buffer in R9.
;		Returns R0 #0 if error
;
; *****************************************************************************

.TokeniseElement
		push 	link
		;
		;		Check if it is 0..9
		;
		mov 	r0,r3,#0 					; check in the range 0..9
		sub 	r0,#'0'
		skge 
		jmp 	#_TENot09
		sub 	r0,#10
		sklt
		jmp 	#_TENot09
		;
		;		Found a digit 0-9. Try to convert it as an integer, possibly with a constant shift prefix.
		;
		clr 	r2 							; there's no prefix.
		mov 	r1,#10  					; try to get a number
		jmp 	#_TEIntegerConstantNoPrefix		
._TEIntegerConstantWithPrefix
		stm 	r9,#0
		inc 	r9
._TEIntegerConstantNoPrefix		
		break
		jmp 	#_TEExit 					; exit.
		;
		;		Not 0..9. Now check for & and %
		;
._TENot09		
		mov 	r0,r1,#0 					; get first character again.
		inc 	r8 							; advance past it for & % check.
		mov 	r2,#TOK_AMPERSAND 			; first try &xxxx
		mov 	r1,#16
		xor 	r0,#'&'
		sknz	r0
		jmp 	#_TEIntegerConstantWithPrefix
		mov 	r2,#TOK_PERCENT 			; now try %xxxx
		mov 	r1,#2 						
		xor 	r0,#'&'^'%'
		sknz 	r0
		jmp 	#_TEIntegerConstantWithPrefix
		;
		;		We have no identifier it is NOT 0-9 &[0-9A-F]+ or %[01]+ e.g. it is not a 
		;		constant.
		;
		break				

._TEExit
		pop 	link
		ret


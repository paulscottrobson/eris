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
		mov 	r9,#tokenBuffer 			; tokenised code goes here
		mov 	r8,r0,#0 					; characters come from here.
		mov 	r7,#$007F 					; R7 is the character mask 					
		;
		;		Main tokenising loop
		;
._TSLoop		
		ldm 	r0,r8,#0 					; look at next character
		and 	r0,r7,#0 					; as a character
		mov 	r1,r0,#0 					; put in R1.
		sknz 	r0
		jmp 	#_TSExit 					; exit if end of list
		xor 	r0,#' '						; if space , skip over
		inc 	r8
		sknz 	r0
		jmp 	#_TSLoop
		dec 	r8 							; R8 now points to current character
		;
		jsr 	#TokeniseElement 			; do one element
		jmp 	#_TSLoop

._TSExit
		pop 	link
		ret

; *****************************************************************************
;
;		Tokenise a single element @ R8. First char in R1. Buffer in R9.
;
; *****************************************************************************

.TokeniseElement
		break

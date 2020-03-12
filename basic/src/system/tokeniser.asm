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
		push 	r3,r7,r8,r9,link
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
		stm 	r14,r9,#0 					; mark buffer end with a $0000
		mov 	r0,#tokenBuffer 			; return token buffer
		sknz 	r0 							; skip the clear
._TSFail
		clr 	r0							; come here if you fail.
		pop 	r3,r7,r8,r9,link
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
		;		Special cases - "<quoted string>" &<hexadecimal> %<binary>
		;

		;
		;		Identify whether it is punctuation, identifier (A-Z/.) or digit
		;
		break
		mov 	r0,r3,#0 					; get character
		jsr 	#GetCharacterType 			; 0 punctuation 1 alphabet 2 number
		add 	r0,#_TEHandlerTable 		; address to jump to
		ldm 	r0,r0,#0 					; get branch address
		brl 	r15,r0,#0 					; and go there
		;
		;		Come back here depending on whether tokenisation succeeds or not.
		;
._TEExitOkay 								; come here if tokenised ok
		clr 	r0
		skz 	r0
._TEExitFail								; come here if failed.
		mov 	r0,#1 				
		pop 	link
		ret
		;
		;		Which handler do we go off and use
		;
._TEHandlerTable
		word 	SyntaxError 				; 0 (punctuation)
		word 	SyntaxError 				; 1 (identifier)
		word	SyntaxError 				; 2 (number)		


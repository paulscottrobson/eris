; *****************************************************************************
; *****************************************************************************
;
;		Name:		listutils.asm
;		Purpose:	List Utilities 
;		Created:	11th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

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
		mov 	r7,r0,#0 					; save type of this character in R7
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
;				Print String at R0 using the syntactic printer
;
; *****************************************************************************

.ListPrintString
		push 	r1,r2,link
		mov 	r1,r0,#1 					; address 1st char pair in R1
		jsr 	#OSWordLength 				; words to print in R2
		mov 	r2,r0,#0
._LPSLoop		
		sknz 	r2 							; end of string ?
		jmp 	#_LPSExit 					; exit if so.

		ldm 	r0,r1,#0 					; get character pair
		jsr 	#ListPrintCharacter 		; print low byte
		ldm 	r0,r1,#0 					; get character pair
		ror 	r0,#8 						; then the high byte, ignored if zero
		jsr 	#ListPrintCharacter 		; print it.
		inc 	r1 							; do next
		dec 	r2 							; decrement count
		jmp 	#_LPSLoop
._LPSExit
		mov 	r0,r1,#0 					; R0 := end address
		pop 	r1,r2,link
		ret


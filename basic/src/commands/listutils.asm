; *****************************************************************************
; *****************************************************************************
;
;		Name:		listutils.asm
;		Purpose:	List Utilities 
;		Created:	11th March 2020
;		Reviewed: 	17th March 2020sss
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
		and 	r0,#$007F					; convert to a byte
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

; *****************************************************************************
;
;	  Print the identifier sequence at R0, returns R0 after last identifier
;
; *****************************************************************************

.ListPrintEncodedIdentifier
		push 	r1,link
._LPEILoop
		ldm 	r1,r0,#0 					; read the next identifier element
		jsr 	#_LPEIPrintIdentifier 		; print it		
		ldm 	r1,r0,#0 					; get it back and bump pointer
		inc 	r0
		ror 	r1,#14 						; shift the 'last' flag into the sign bit
		skm 	r1 							; exit if set
		jmp 	#_LPEILoop
		;
		push 	r0 							; handle $ bit
		add 	r1,r1,#0 					
		mov 	r0,#'$'
		skp 	r1
		jsr 	#ListPrintCharacter
		add 	r1,r1,#0 					; handle ( bit
		mov 	r0,#'('
		skp 	r1
		jsr 	#ListPrintCharacter
		pop 	r0
		;
		pop 	r1,link
		ret
;
;		List print the identifier in R1
;
._LPEIPrintIdentifier
		push 	r0,link
		and 	r1,#$07FF 					; strip out identifier character bits.
		clr 	r0 							; going to divide R1 by 40, remainder in R0.
._LPEIDivide
		sub 	r1,#40 						
		inc 	r0		
		skm 	r1
		jmp 	#_LPEIDivide
		dec 	r0 							; unfix the last subtraction.
		add 	r1,#40
		skz 	r1
		jsr 	#_LPEIPrintR1 				; print R1 as character if non-zero (remainder)
		mov 	r1,r0,#0 					; repeat for the divisior		
		skz 	r1
		jsr 	#_LPEIPrintR1 				
		pop 	r0,link
		ret		
;
;		R1 is a value from 1-39 representing an identifier, decode and print it.
;
._LPEIPrintR1		
		push	r0,link
		mov 	r0,r1,#0 					; R1 = R0+96, e.g. make A-Z first
		add 	r0,#96
		sub 	r1,#27 						; 1-26 is A-Z
		skge
		jmp 	#_LPEIPrint
		add 	r0,#48-26-97 				; shift for 0-9
		sub 	r1,#10
		sklt
		mov 	r0,#'.'						; finally .
._LPEIPrint
		jsr 	#ListPrintCharacter 		; output R0
		pop 	r0,link
		ret

; *****************************************************************************
;
;					Print the token at R0 as punctuation
;
; *****************************************************************************

.ListPrintPunctuation
		push 	r0,r1,link
		mov 	r1,r0,#0 					; address in R1
		mov 	r0,#theme_punc+$10
		jsr 	#OSPrintCharacter
		ldm 	r0,r1,#0 					; read character
		jsr 	#ListPrintCharacter 		; print LSB
		ldm 	r0,r1,#0 					; read character
		ror 	r0,#8
		jsr 	#ListPrintCharacter 		; print MSB
		pop 	r0,r1,link
		ret


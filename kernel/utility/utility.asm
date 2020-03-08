; *****************************************************************************
; *****************************************************************************
;
;		Name:		utility.asm
;		Purpose:	Assorted functions
;		Created:	1st March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;							Convert R0 to upper case.
;
; *****************************************************************************

.OSXUpperCase
		push 	r1
		mov		r1,r0,#0 					; copy character
		and 	r1,#$00FF 					; get the character code
		sub 	r1,#'a'						; check in range a-z
		skge
		jmp 	#_OSUCExit
		sub 	r1,#26
		skge
		sub 	r0,#32 						; convert it.
._OSUCExit
		pop 	r1
		ret

; *****************************************************************************
;
;							Convert R0 to lower case.
;
; *****************************************************************************

.OSXLowerCase
		push 	r1
		mov		r1,r0,#0 					; copy character
		and 	r1,#$00FF 					; get the character code
		sub 	r1,#65						; check in range A-Z
		skge
		jmp 	#_OSLCExit
		sub 	r1,#26
		skge
		add 	r0,#32 						; convert it.
._OSLCExit
		pop 	r1
		ret

; *****************************************************************************
;
;					Get word length of string in R0 
;			(e.g. no of words string occupies excluding length word)
;
; *****************************************************************************

.OSXWordLength
		ldm 	r0,r0,#0 					; get length in characters
		inc 	r0 							; calculate int((len+1)/2)
		ror 	r0,#1
		and 	r0,#$7FFF
		ret
		

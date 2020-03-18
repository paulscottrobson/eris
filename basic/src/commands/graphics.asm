; *****************************************************************************
; *****************************************************************************
;
;		Name:		graphics.asm
;		Purpose:	Simple Graphics keywords
;		Created:	18th March 2020
;		Reviewed: 	TODO
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;								SCREEN Mode setting
;
; *****************************************************************************

.Command_Screen 	;; 	[screen]
		push 	link
		jsr 	#EvaluateInteger 			; background planes
		mov 	r1,r0,#0
		and 	r0,#$FFF8
		skz 	r0
		jmp 	#BadNumberError
		;
		jsr 	#CheckComma
		;
		jsr 	#EvaluateInteger 			; sprite planes
		mov 	r2,r0,#0
		and 	r0,#$FFF8
		skz 	r0
		jmp 	#BadNumberError
		;
		ror 	r2,#8 						; sprite plane count in upper byte
		mov 	r0,r1,#0
		add 	r0,r2,#0 					; background in lower byte
		jsr 	#OSSetPlanes 				; set plane sizes
		pop 	link
		ret

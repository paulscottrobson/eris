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
;								CLS INK and PAPER
;
; *****************************************************************************

.Command_Cls		;; [cls]
		mov 	r0,#12
		jmp 	#OSPrintCharacter

.Command_Ink 		;; [ink]
		push	link
		jsr 	#EvaluateInteger 			; get colour, must be 0-15
		mov 	r1,r0,#0
		and 	r1,#$FFF0
		skz 	r1
		jmp 	#BadNumberError
		add 	r0,#$10 					; make control
		jsr 	#OSPrintCharacter
		pop 	link
		ret

.Command_Paper		;; [paper]
		push 	link
		mov 	r0,#15 						; swap fgr/bgr
		jsr 	#OSPrintCharacter
		jsr 	#Command_Ink 				; set the ink colour
		mov 	r0,#15 						; swap fgr/bgr
		jsr 	#OSPrintCharacter
		pop 	link
		ret

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

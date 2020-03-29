; *****************************************************************************
; *****************************************************************************
;
;		Name:		fkey.asm
;		Purpose:	Function Key Processor
;		Created:	16th March 2020
;		Reviewed: 	17th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;							FKEY <n>,<string>
;
; *****************************************************************************

.Command_FKey		;; [fkey]
		push 	link
		jsr 	#EvaluateInteger 			; key number
		mov 	r2,r0,#0 					; save it		
		jsr 	#CheckComma 				; check comma
		jsr 	#EvaluateString 			; look at the RHS
		mov 	r1,r0,#0 					; string address in R1
		mov 	r0,r2,#0 					; function key # in R0
		jsr 	#OSDefineFKey
		skz 	r0
		jmp 	#BadNumberError
		;
		pop 	link
		ret

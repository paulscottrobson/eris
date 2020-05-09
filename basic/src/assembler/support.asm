; *****************************************************************************
; *****************************************************************************
;
;		Name:		support.asm
;		Purpose:	Support routines for assembler
;		Created:	22nd March 2020
;		Reviewed: 	TODO
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;							 .<identifier> sets label
;
; *****************************************************************************

.Command_Label 		;; [.]
		push 	link
		stm 	r14,#reportUnknownVariable 	; permit definitions
		jsr 	#EvaluateExpression 		; get a reference.
		stm 	r15,#reportUnknownVariable 	; turn permission off
		ldm 	r0,r10,#esReference1 		; check reference
		sknz 	r0
		jmp		#BadLabelError
		ldm 	r0,r10,#esType1 			; to integer
		skz 	r0
		jmp 	#TypeMismatchError
		;
		ldm 	r0,r10,#esValue1 			; reference target
		ldm 	r1,#asmPointer 				; set it to current pointer
		stm 	r1,r0,#0
		pop 	link
		ret
; *****************************************************************************
; *****************************************************************************
;
;		Name:		repeat.asm
;		Purpose:	Repeat/Until
;		Created:	10th March 2020
;		Reviewed: 	16th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;								REPEAT 
;
; *****************************************************************************

.Command_Repeat		;; [repeat]
		push 	link
		jsr 	#StackPushPosition 			; push current position/line offset
		jsr 	#StackPushMarker 			; push an 'R' marker
		word 	'R'
		pop 	link
		ret

; *****************************************************************************
;
;								UNTIL <expr>
;
; *****************************************************************************

.Command_Until		;; [until]
		push 	link
		jsr 	#StackCheckMarker 			; check TOS is an 'R' marker.
		word 	'R'
		jmp 	#UntilError
		jsr 	#EvaluateInteger			; do the test, e.g. until what.
		skz 	r0 							
		jmp 	#_CRPassed 					; if <> 0 then remove from stack and continue
		;
		jsr 	#StackPopPosition 			; restore position from stack, e.g. go back
		pop 	link
		ret

._CRPassed
		mov 	r0,#1+stackPosSize 			; and reclaim that many words off the stack
		jsr 	#StackPopWords
		pop 	link
		ret

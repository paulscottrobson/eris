; *****************************************************************************
; *****************************************************************************
;
;		Name:		repeat.asm
;		Purpose:	Repeat/Until
;		Created:	10th March 2020
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
		jsr 	#EvaluateInteger			; do the test
		skz 	r0 							
		jmp 	#_CRPassed
		;
		jsr 	#StackPopPosition 			; restore position from stack.
		pop 	link
		ret

._CRPassed
		mov 	r0,#1+stackPosSize 			; and reclaim that many words off the stack
		jsr 	#StackPopWords
		pop 	link
		ret


; *****************************************************************************
; *****************************************************************************
;
;		Name:		while.asm
;		Purpose:	While/Wend
;		Created:	10th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;									WHILE <expr>
;
; *****************************************************************************

.Command_While		;; [while]
		push 	link
		dec 	r11 						; we want to come back to the WHILE
		jsr 	#StackPushPosition 			; push current position/line offset
		jsr 	#StackPushMarker 			; push an 'W' marker
		word 	'W'
		inc 	r11
		jsr 	#EvaluateInteger 			; evaluate while what
		skz 	r0 							; if evaluation is zero then exit loop
		jmp 	#_CWExit
		;
		mov 	r0,#1+stackPosSize 			; and reclaim that many words off the stack
		jsr 	#StackPopWords 				; (undo the position saving)
		;
		mov 	r0,#TOK_WEND 				; skip forward to after WEND.
		mov 	r1,r0,#0
		jsr 	#SkipStructure
._CWExit		
		pop 	link
		ret

; *****************************************************************************
;
;									WEND
;
; *****************************************************************************

.Command_Wend		;; [wend]
		push 	link
		jsr 	#StackCheckMarker 			; check TOS is an 'R' marker.
		word 	'W'
		jmp 	#WendError
		jsr 	#StackPopPosition 			; restore position from stack.
		mov 	r0,#1+stackPosSize 			; and reclaim that many words off the stack
		jsr 	#StackPopWords
		pop 	link
		ret

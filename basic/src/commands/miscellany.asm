; *****************************************************************************
; *****************************************************************************
;
;		Name:		miscellany.asm
;		Purpose:	Miscellaneous Commands
;		Created:	3rd March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;								Assert Handler
;
; *****************************************************************************

.CommandAssert 		;; [assert]
		mov 	r1,link,#0
		jsr 	#EvaluateInteger 			; assert what ?
		sknz 	r0
		jmp 	#AssertError 				; failed.
		mov 	link,r1,#0
		ret

; *****************************************************************************
;
;							Poke a memory location
;
; *****************************************************************************

.CommandPoke 		;; [poke]
		push 	link
		jsr 	#EvaluateInteger 			; address -> R1
		mov 	r1,r0,#0 
		jsr 	#CheckComma
		jsr 	#EvaluateInteger 			; data -> R0
		stm 	r0,r1,#0 					; do the POKE
		pop 	link
		ret

; *****************************************************************************
;
;							Call a M/C Routine
;
; *****************************************************************************

.CommandSys 		;; [sys]
		push 	link
		break
		jsr 	#EvaluateInteger 			; address -> R1
		mov 	r1,r0,#0 
		mov 	r0,#fixedVariables 			; pass variables in R0
		brl 	link,r1,#0 					; call the routine
		pop 	link
		ret

; *****************************************************************************
;
;					Code for ' and REM comment handlers
;
; *****************************************************************************

.CommentCommand1 	;; [']
.CommentCommand2 	;; [rem]
		ldm 	r0,r11,#0 					; is there a string there e.g. 01xx ?
		mov 	r1,r0,#0 					; length in R1
		and 	r1,#$00FF
		and 	r0,#$FF00 					; msb of token in R0 					
		xor 	r0,#$0100 					; if it is $0100 then 
		sknz 	r0
		add 	r11,r1,#0 					; add the length to R11
		ret

; *****************************************************************************
;
;					  Code for colon, which does nothing
;
; *****************************************************************************

.ColonHandler 	;; [:]
		ret

; *****************************************************************************
;
;			Code for non-executable, stops the build squawking
;
; *****************************************************************************

.Dummy1 		;; [)]
.Dummy2 		;; [,]
.Dummy3 		;; [;]
.Dummy4 		;; [to]
.Dummy5 		;; [step]
.Dummy6 		;; [then]

;
;	Note then is a command because if...then is a structure, but it doesn't
;	execute in its own right.
;
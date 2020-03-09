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

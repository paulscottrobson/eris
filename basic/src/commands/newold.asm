; *****************************************************************************
; *****************************************************************************
;
;		Name:		newold.asm
;		Purpose:	New and Old
;		Created:	11th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;									New program
;
; *****************************************************************************

.Command_New 	;; [new]		
		ldm 	r0,#programCode				; overwrite the first program word, erasing program
		stm 	r14,r0,#0
		jmp 	#WarmStart 					; do a warm start

; *****************************************************************************
;
;							Recover NEWed program
;
; *****************************************************************************

.Command_Old 	;; [old]
		ldm 	r0,#programCode 			; start of program in R0/R2
		mov 	r2,r0,#0
		inc		r0
._CONext
		inc 	r0 							; next token
._CONext2
		ldm 	r1,r0,#0 					
		sknz 	r1 							; reached zero ?
		jmp 	#_COFoundEnd
		and 	r1,#$FF00					; is it a string
		xor 	r1,#$0100 
		skz 	r1
		jmp 	#_CONext
		ldm 	r1,r0,#0 					; get length
		and 	r1,#$00FF
		add 	r0,r1,#0 					; add it on.
		jmp 	#_CONext2
;
._COFoundEnd
		sub 	r0,r2,#0 					; calculate length
		inc 	r0 							; add 1 to go to start of next line
		stm 	r0,r2,#0 					; overwrite first offset
		jsr 	#Command_Clear				; clear variables
		jmp 	#WarmStart 					; do a warm start

; *****************************************************************************
; *****************************************************************************
;
;		Name:		transfer.asm
;		Purpose:	Goto, Gosub and Return
;		Created:	4th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;									GOTO code. 
;
; *****************************************************************************

.Command_GOTO		;; [goto]
		push 	link
		jsr 	#EvaluateInteger 			; get integer into R0 (line number)
		;
._CGMain		
		ldm 	r11,#programCode 			; start R11 at program code base.
._CGSearch
		ldm 	r1,r11,#0 					; get offset into R1
		sknz 	r1 							; end of program ?
		jmp 	#LineError
		ldm 	r4,r11,#1					; line number into R4
		xor 	r4,r0,#0 					; same as current line
		sknz 	r4 							
		jmp 	#_CGFound 					; if so, found the line number.
		add 	r11,r1,#0 					; next line
		jmp 	#_CGSearch
		;
._CGFound
		stm 	r11,#currentLine 			; save current line address
		add 	r11,#2 						; first token on line 
		pop 	link
		ret

; *****************************************************************************
;
;								GOSUB code
;
; *****************************************************************************

.Command_GOSUB ;; [gosub]
		push 	link 						
		jsr 	#EvaluateInteger 			; get integer into R0 (line number)
		push 	r0
		jsr 	#StackPushPosition 			; push current position/line offset
		jsr 	#StackPushMarker 			; push an 'S' marker
		word 	'S'
		pop 	r0 
		jmp 	#_CGMain					; go do the GOTO code.

; *****************************************************************************
;
;								RETURN code
;
; *****************************************************************************

.Command_RETURN ;; [return]
		push 	link
		jsr 	#StackCheckMarker 			; check TOS is an 'S' marker.
		word 	'S'
		jmp 	#ReturnError
		jsr 	#StackPopPosition 			; restore position from stack.
		mov 	r0,#1+stackPosSize 			; and reclaim that many words off the stack
		jsr 	#StackPopWords
		pop 	link
		ret

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
;			GOTO code. This is also used by GOSUB, so on exit R2 and R3
; 			are the line number and line position respectively.
;
; *****************************************************************************

.Command_GOTO		;; [goto]
		push 	link
		jsr 	#EvaluateInteger 			; get integer into R0.
		mov 	r2,r11,#0 					; save return address and return line into R2/R3
		ldm 	r3,#currentLine
		;
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


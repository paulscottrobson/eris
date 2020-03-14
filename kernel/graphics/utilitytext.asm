; *****************************************************************************
; *****************************************************************************
;
;		Name:		utilitytext.asm
;		Purpose:	Text Utility Functions
;		Created:	8th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;							   Get text pos to X,Y
;
; *****************************************************************************

.OSXGetTextPos
		ldm 	r0,#xTextPos
		ldm 	r1,#yTextPos
		ret
		
; *****************************************************************************
;
;								Print string at R0
;
; *****************************************************************************

.OSXPrintString
		push 	r0,link
		jsr 	#_OSXPInlinePrinter
		pop 	r0,link
		ret

; *****************************************************************************
;
;							Print following string
;
; *****************************************************************************

.OSXPrintInline
		push 	r0 							; R0 is a temporary value
		mov 	r0,link,#0 	 				; string address -> R0
		jsr 	#_OSXPInlinePrinter 		; call the inline printer routine.
		mov 	link,r0,#0 					; return address in link register
		pop 	r0 							; restore R0
		ret 								; and return

; *****************************************************************************
;
;   Print lenprefix string at R0, exits with R0 pointing to the word after
;
; *****************************************************************************

._OSXPInlinePrinter
		push 	r1,r2,link
		mov 	r1,r0,#1 					; address+1 in R1
		jsr 	#OSWordLength 				; words to print in R2
		mov 	r2,r0,#0
._OSXPIPLoop		
		sknz 	r2 							; end of string ?
		jmp 	#_OSXPIPExit 				; exit if so.

		ldm 	r0,r1,#0 					; get character pair
		jsr 	#OSPrintCharacter 			; print low byte
		ror 	r0,#8 						; then the high byte, ignored if zero
		jsr 	#OSPrintCharacter 			; print it.
		inc 	r1 							; do next
		dec 	r2 							; decrement count
		jmp 	#_OSXPIPLoop
._OSXPIPExit
		mov 	r0,r1,#0 					; R0 := end address
		pop 	r1,r2,link
		ret
		
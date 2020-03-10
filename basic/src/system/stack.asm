; *****************************************************************************
; *****************************************************************************
;
;		Name:		stack.asm
;		Purpose:	BASIC Stack routines
;		Created:	10th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;			Push the current position in R11, and the current line 
;			pointer on the return stack.
;
; *****************************************************************************

.StackPushPosition 	
		ldm 	r0,#returnStackPtr			; get rsp, make space
		sub 	r0,#2
		stm 	r0,#returnStackPtr
		stm 	r11,r0,#0 					; save code ptr
		ldm 	r1,#currentLine 			; save current line
		stm 	r1,r0,#1
		ret	

; *****************************************************************************
;
;			Restore current position and line from the 2nd and 3rd
;			words on the return stack (top of stack is the marker)
;			* does not pop *
;
; *****************************************************************************

.StackPopPosition
		ldm 	r0,#returnStackPtr 			; get current
		ldm 	r11,r0,#1 					; reload position skipping marker
		ldm 	r0,r0,#2
		stm 	r0,#currentLine
		ret	

; *****************************************************************************
;
;			Push the word following this call onto the stack, this 
;			will be a marker to keep the structures aligned
;
; *****************************************************************************

.StackPushMarker
		ldm 	r0,#returnStackPtr 			; make space for marker
		dec 	r0
		stm 	r0,#returnStackPtr

		ldm 	r1,link,#0 					; get return word
		stm 	r1,r0,#0 					; write it
		inc 	link						; skip return word
		ret

; *****************************************************************************
;
;			Check that the stack top value is the word following the
;			call. If not, return +1, else return +3 
;
; *****************************************************************************

.StackCheckMarker
		ldm 	r0,#returnStackPtr 			; tos address
		ldm 	r0,r0,#0 					; tos data
		ldm		r1,link,#0 					; get word after call
		inc 	link 						; skip it.
		xor 	r0,r1,#0 					; if they are the same
		sknz 	r0 							
		add 	link,#2 					; skip the jump
		ret

; *****************************************************************************
;
;						Remove R0 words off the stack
;
; *****************************************************************************

.StackPopWords
		ldm 	r1,#returnStackPtr
		add 	r0,r1,#0
		stm 	r0,#returnStackPtr
		ret


; *****************************************************************************
; *****************************************************************************
;
;		Name:		clear.asm
;		Purpose:	Clear memory prior to RUN
;		Created:	4th March 2020
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
		stm		r14,r0,#0					; *** fall through ***

; *****************************************************************************
;
;								Clear variables
;
; *****************************************************************************

.Command_Clear	;; [clear]
		push 	link
		mov 	r0,sp,#0 					; R0 = current sp value
		sub 	r0,#512 					; allocate space for CPU stack
		stm 	r0,#endMemory 				; record highest point of BASIC RAM
		stm	 	r0,#memAllocTop 			; reset allocation pointer
		;
		jsr 	#VarEraseHashTables			; erase hash tables
		;
		ldm 	r0,#programCode 			; look for program end.
._CCFindEnd
		ldm 	r1,r0,#0 					; get offset
		add 	r0,r1,#0 					; add it
		skz 	r1 							; skip if it wasn't zero.
		jmp 	#_CCFindEnd
		;
		inc 	r0 							; word after the last zero offset
		stm 	r0,#memAllocBottom 			; allocate to low memory.
		pop 	link
		ret




; *****************************************************************************
; *****************************************************************************
;
;		Name:		clear.asm
;		Purpose:	Clear memory prior to RUN
;		Created:	4th March 2020
;		Reviewed: 	TODO
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

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
		;
		jsr 	#FindProgramEnd				; find end of program
		inc 	r0 							; word after the last zero offset
		stm 	r0,#memAllocBottom 			; allocate to low memory.
		;
		jsr 	#StackReset 				; reset the basic stack
		jsr 	#ScanForProcedures 			; scan for procedures
		;
		pop 	link
		ret




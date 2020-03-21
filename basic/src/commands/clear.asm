; *****************************************************************************
; *****************************************************************************
;
;		Name:		clear.asm
;		Purpose:	Clear memory prior to RUN
;		Created:	4th March 2020
;		Reviewed: 	16th March 2020
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
		sub 	r0,#cpuStackSize			; allocate space for CPU stack
		stm 	r0,#endMemory 				; record highest point of BASIC RAM
		stm	 	r0,#memAllocTop 			; reset allocation pointer for temporary strings
		;
		jsr 	#VarEraseHashTables			; erase hash tables, clears all variables except A-Z
		;
		jsr 	#FindProgramEnd				; find end of program
		inc 	r0 							; word after the last zero offset, marking program end.
		stm 	r0,#memAllocBottom 			; set as memory to be allocated up
		;
		jsr 	#StackReset 				; reset the basic stack
		jsr 	#LocalReset					; reset the locals stack
		jsr 	#ScanForProcedures 			; scan for procedures so CALL can find them fast.
		;
		pop 	link
		ret




; *****************************************************************************
; *****************************************************************************
;
;		Name:		varutils.asm
;		Purpose:	Variable Utilities
;		Created:	3rd March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;						Erase variable hash tables
;
; *****************************************************************************

.VarEraseHashTables
		mov 	r0,#variableHashTable
		mov 	r1,#hashTableSize*4
._VEHTLoop
		stm 	r14,r0,#0
		inc 	r0	
		dec 	r1
		skz 	r1
		jmp 	#_VEHTLoop
		ret

; *****************************************************************************
;
;	Used when a variable is created from the command line - it creates a copy
;	in variable memory rather than using the one in program memory.
;
; *****************************************************************************

.DuplicateReference
		push 	r0,r1,r2
		ldm 	r0,#memAllocBottom 			; R0 is where it goes
		mov 	r1,r0,#0 					; save start in R1
._DRCopy
		ldm 	r2,r11,#0 					; copy identifier
		stm 	r2,r0,#0
		inc 	r0
		inc 	r11
		ror 	r2,#14
		skm 	r2
		jmp 	#_DRCopy
		stm 	r0,#memAllocBottom
		;
		mov 	r11,r1,#0 					; save copy of the start
		pop 	r0,r1,r2
		ret

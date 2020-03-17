; *****************************************************************************
; *****************************************************************************
;
;		Name:		varutils.asm
;		Purpose:	Variable Utilities
;		Created:	3rd March 2020
;		Reviewed: 	17th March 2020
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
		mov 	r0,#variableHashTable 		; start of block
		mov 	r1,#hashTableSize*4			; there are 4 hash tables array/single int/str
._VEHTLoop
		stm 	r14,r0,#0 					; fill them all with Null (0)
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
		ldm 	r2,r11,#0 					; copy identifier word by word
		stm 	r2,r0,#0
		inc 	r0
		inc 	r11
		ror 	r2,#14 						; did the word copied have the end bit set
		skm 	r2
		jmp 	#_DRCopy 					; no keep copying
		stm 	r0,#memAllocBottom 			; update memory pointer
		;
		mov 	r11,r1,#0 					; save copy of the start
		pop 	r0,r1,r2 					; putting it in R11 "pretends" its in code
		ret

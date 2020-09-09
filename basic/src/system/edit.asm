; *****************************************************************************
; *****************************************************************************
;
;		Name:		edit.asm
;		Purpose:	Edit Program
;		Created:	13th March 2020
;		Reviewed: 	17th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;		 Edit program. R0 points to the token buffer, R1 has the length.
;
; *****************************************************************************

.EditProgram
		dec 	r1 						; one fewer character, as we're converting to a code line
		inc 	r0 						; the offset goes here, the first token becomes the line number
		stm 	r1,r0,#0
		ldm 	r1,r0,#1 				; clear bit 15 of line number
		and 	r1,#$7FFF
		stm 	r1,r0,#1 				
		;
		;		Now search for either the end, or the first line number >= the current
		;
		ldm 	r2,#programCode
._EPFind
		ldm 	r3,r2,#0 				; get offset
		sknz 	r3
		jmp 	#_EPCInsert 			; if reached the end we do not need to delete.
		;
		ldm 	r4,r2,#1 				; get line #
		sub 	r4,r1,#0 				; subtract target line #
		sknz 	r4 						; if = then delete
		jmp 	#_EPCDelete
		sklt  							; if > then insert at this point
		jmp 	#_EPCInsert
		add 	r2,r3,#0				; add offset and go round again
		jmp 	#_EPFind
		;
		;		Delete line at R2, line number R1, code at R0.
		;
._EPCDelete
		jsr 	#DeleteLine
		;	
		;		Check insert at R2, line number R1, code at R0.
		;
._EPCInsert
		ldm 	r3,r0,#2 				; is the line empty after the line number
		sknz 	r3
		jmp 	#_EPCDone 				; if so, do nothing more
		jsr 	#InsertLine
		;
		;		Completed edit
		;
._EPCDone	
		jsr 	#Command_Clear 			; do clear code 
		jmp 	#WarmStartNoReady 		; and warm start	

; *****************************************************************************
;
;				  Insert line at R2, line to insert is at R0
;
; *****************************************************************************

.InsertLine
		push 	r0,r1,r2,r3,r4,r5,link
		mov 	r3,r0,#0 				; line to insert -> R3
		jsr 	#FindProgramEnd 		; R0 now contains the program end. 
		mov 	r1,r0,#0 				; R1 now the same
		ldm 	r4,r3,#0 				; space to allocate (e.g. line offset)
		add 	r1,r4,#0 				; R0 = source, R1 = target
		;
		;		Check memory space
		;
		ldm 	r4,#endMemory 			; if >= end memory error
		sub 	r1,r4,#0
		sklt 	
		jmp 	#MemoryError
		add 	r1,r4,#0
		;
		;		Now make space for the new line.
		;
._ILMakeSpace
		ldm 	r5,r0,#0 				; copy word up
		stm 	r5,r1,#0
		mov 	r5,r0,#0 				; R5 = source ^ target address
		xor 	r5,r2,#0 				; e.g. have made enough space
		dec 	r0 						; copying up so backwards
		dec 	r1		
		skz 	r5
		jmp 	#_ILMakeSpace 			
		;
		;		Now copy line @ R3 to R2
		;
		ldm 	r1,r3,#0 				; words to copy
._ILCopyNew
		ldm 	r0,r3,#0
		stm 	r0,r2,#0
		inc 	r3
		inc 	r2
		dec 	r1
		skz 	r1
		jmp 	#_ILCopyNew
		pop 	r0,r1,r2,r3,r4,r5,link
		ret

; *****************************************************************************
;
;							Delete line at R2
;
; *****************************************************************************

.DeleteLine
		push	r0,r1,r2,link
		ldm 	r1,r2,#0 				; offset to next line in R1
		add 	r1,r2,#0 				; address of next line in R1 - copy R1->R2
		jsr 	#FindProgramEnd 		; end of program in R0
._DLCopy
		ldm 	r3,r1,#0 				; copy word
		stm 	r3,r2,#0
		mov 	r3,r1,#0 				; just copied program end -> R3
		xor 	r3,r0,#0
		inc 	r1 						; increment pointers
		inc 	r2
		skz 	r3 						; exit if done
		jmp 	#_DLCopy
		pop 	r0,r1,r2,link
		ret	

; *****************************************************************************
;
;					Get end of program address into R0
;
; *****************************************************************************

.FindProgramEnd
		push 	r1
		ldm 	r0,#programCode 			; look for program end.
._CCFindEnd
		ldm 	r1,r0,#0 					; get offset
		add 	r0,r1,#0 					; add it
		skz 	r1 							; skip if it wasn't zero.
		jmp 	#_CCFindEnd
		pop 	r1
		ret

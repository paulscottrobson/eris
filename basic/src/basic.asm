; *****************************************************************************
; *****************************************************************************
;
;		Name:		basic.asm
;		Purpose:	Basic ROM Startup
;		Created:	2nd March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

		org 	kernelEnd

; *****************************************************************************
;
;									Initialise
;
; *****************************************************************************

.ColdStart	
		stm 	sp,#initialSP 				; save initial stack pointer.
		mov 	r0,#freeBasicCode			; initialise code pointer.
		stm 	r0,#programCode
		jmp 	#RunProgram					; run program code.

		jsr 	#Command_New
		
; *****************************************************************************
;
;							  Warm start, also END
;
; *****************************************************************************

.WarmStart ;; [end]	
		ldm 	sp,#initialSP 				; reset the stack
		mov 	r0,#$12 					; go green
		jsr 	#OSPrintCharacter
.h1		jsr 	#OSLineInput
		inc 	r9
	 	jmp 	#h1




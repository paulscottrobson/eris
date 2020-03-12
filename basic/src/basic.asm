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
		dec 	sp 							; high memory address -> first free word
		stm 	sp,#returnStackTop 			; allocate space for BASIC return stack
		sub 	sp,#returnStackSize
		stm 	sp,#returnStackBottom 		; save the bottom position
		;
		stm 	sp,#initialSP 				; save initial stack pointer.
		;
		mov 	r0,#freeBasicCode			; initialise code pointer.
		stm 	r0,#programCode
		;
		mov 	r0,#basicPrompt
		jsr 	#OSPrintString
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
		break
	 	jmp 	#h1

.basicPrompt
		string "Basic[3A]  0.01[0D,0D]"



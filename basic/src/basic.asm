; *****************************************************************************
; *****************************************************************************
;
;		Name:		basic.asm
;		Purpose:	Basic ROM Startup
;		Created:	2nd March 2020
;		Reviewed: 	TODO
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

		org 	kernelEnd

; *****************************************************************************
;
;								Version String
;
; *****************************************************************************

		jmp 	#ColdStart
.basicPrompt
		string "Basic[3A]  0.10[0D,0D]"

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
		;
		;		Uncomment this to test the tokeniser
		;
		;jmp 	#TestTokeniserRoutine		
		;
		;		Uncomment this to automatically run the loaded program in the emulator.
		;
		jmp 	#RunProgram					; run program code.

		jsr 	#Command_New 				; New program.

; *****************************************************************************
;
;							  Warm start, also END
;
; *****************************************************************************

.WarmStart 
		ldm 	sp,#initialSP 				; reset the stack
		mov 	r0,#$12 					; go green
		jsr 	#OSPrintCharacter
		jsr 	#OSLineInput 				; read a line off the screen
		;
		jsr 	#TokeniseString 			; try to tokenise and error if failed.
		sknz 	r0
		jmp 	#TokeniseError
		;
		mov 	r11,r0,#0 					; put start of 'faux line' in R11.
		;
		ldm 	r2,r0,#2 					; look at first token to see if it is a number.
		skm 	r2 							; no, it isn't
		jmp 	#RunProgramR11 				; run program from R11
		jmp 	#EditProgram 				; else edit





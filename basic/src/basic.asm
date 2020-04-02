; *****************************************************************************
; *****************************************************************************
;
;		Name:		basic.asm
;		Purpose:	Basic ROM Startup
;		Created:	2nd March 2020
;		Reviewed: 	16th March 2020
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
		string "Basic[3A]  0.60[0D,0D,12]"

; *****************************************************************************
;
;									Initialise
;
; *****************************************************************************

.ColdStart	
		;
		;		Firstly just allocate memory for the three stacks (return, local and CPU)
		;
		dec 	sp 							; high memory address -> first free word
		stm 	sp,#returnStackTop 			; allocate space for BASIC return stack
		sub 	sp,#returnStackSize
		stm 	sp,#returnStackBottom 		; save the bottom position
		;
		stm 	sp,#localStackTop 			; now do the same for the local stack
		sub 	sp,#localStackSize 			
		stm 	sp,#localStackBottom
		;
		stm 	sp,#initialSP 				; save initial stack pointer.
		;
		mov 	r0,#freeBasicCode			; initialise code pointer.
		stm 	r0,#programCode 			; to the space allocate for BASIC programs
		;
		mov 	r0,#basicPrompt 			; display the prompt
		jsr 	#OSPrintString
		;
		;		Uncomment this to test the tokeniser
		;
		;jmp 	#TestTokeniserRoutine		
		;
		;		Check for autoexec.prg
		;
		jsr 	#OSReadJoystick				; is joystick fire 
		and 	r0,#$20 					; is the shift key presse
		skz 	r0
		jmp 	#Command_New 				; if it is, do not autoexec.boot
		mov 	r0,#5 						; does file autoexec.prg exist
		mov 	r1,#CSBootProgram
		jsr 	#OSFileOperation
		skz 	r0
		jsr 	#Command_New 				; New program if not

		jsr 	#OSResetAllChannels			; silence boot beep
		mov 	r0,#2						; load program to program code address
		ldm 	r2,#programCode
		jsr 	#OSFileOperation
		jmp 	#RunProgramNoLoad			; run program code from there.

.CSBootProgram
		string 	"autoexec.prg"

; *****************************************************************************
;
;							  Warm start, also END
;
; *****************************************************************************

.WarmStart 
		ldm 	sp,#initialSP 				; reset the stack
		jsr 	#OSLineInput 				; read a line off the screen
		;
		jsr 	#TokeniseString 			; try to tokenise and error if failed.
		sknz 	r0
		jmp 	#TokeniseError
		;
		mov 	r11,r0,#0 					; put start of 'faux line' in R11.
		;
		ldm 	r2,r0,#2 					; look at first token to see if it is a number.
		skm 	r2 							; skip if it isn't (that's 8000-FFFF => 0-32767)
		jmp 	#RunProgramR11 				; run program from R11 as a command
		jmp 	#EditProgram 				; else edit



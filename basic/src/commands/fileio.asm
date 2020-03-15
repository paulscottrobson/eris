; *****************************************************************************
; *****************************************************************************
;
;		Name:		fileio.asm
;		Purpose:	Load and Save code
;		Created:	14th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;								LOAD <procname>
;
; *****************************************************************************

.Command_Load	;; [load]
		push 	link
		jsr 	#EvaluateString
		mov 	r1,r0,#0
		mov 	r0,#1
		jsr 	#OSFileOperation
		skz 	r0
		jmp 	#LoadError
		jsr 	#Command_Clear
		pop 	link
		ret

; *****************************************************************************
;
;								Directory listing
;
; *****************************************************************************

.Command_Dir 	;; [dir]
		push 	link
		mov 	r0,#4 						; read directory into unused space
		ldm 	r1,#memAllocBottom
		jsr 	#OSFileOperation
._CDList
		ldm 	r0,r1,#0 					; check end 
		sknz 	r0
		jmp 	#_CDExit
		mov	 	r2,r0,#0 					; space becomes CR
		xor 	r2,#32
		sknz 	r2
		mov 	r0,#13
		jsr 	#OSLowerCase
		jsr 	#OSPrintCharacter
		inc 	r1
		jmp 	#_CDList
._CDExit		
		mov 	r0,#13 						; final CR
		jsr 	#OSPrintCharacter
		pop 	link
		ret

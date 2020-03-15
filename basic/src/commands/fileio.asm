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

; *****************************************************************************
;
;								Save program
;
; *****************************************************************************

.Command_Save	;; [save]
		push 	link
		mov 	r1,#_CSDefault
		ldm 	r0,r11,#0 					; check just save or save :
		sknz 	r0
		jmp 	#_CSHaveFileName
		xor		r0,#TOK_COLON
		sknz 	r0
		jmp 	#_CSHaveFileName

		jsr 	#EvaluateString 			; get save name
		;
		; 	TODO: Validate save name
		;
		mov 	r1,r0,#0 					; put string in R1
._CSHaveFileName
		jsr 	#FindProgramEnd 			; program end in R3
		mov 	r3,r0,#0
		ldm 	r2,#programCode 			; program start in R2
		sub 	r3,r2,#0 					; calculate length (end-start+1) => R3
		inc 	r3
		mov 	r0,#3 						; save command
		jsr 	#OSFileOperation 			; try to do it.
		skz 	r0
		jmp 	#SaveError
		pop 	link
		ret

._CSDefault
		string 	"last.save"

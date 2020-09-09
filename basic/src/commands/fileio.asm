; *****************************************************************************
; *****************************************************************************
;
;		Name:		fileio.asm
;		Purpose:	Load and Save code
;		Created:	14th March 2020
;		Reviewed: 	17th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;							  EXISTS(<filename>)
;
; *****************************************************************************

.Unary_Exists 	;; [exists(]
		push 	link
		jsr 	#EvaluateString 			; name of file to load
		jsr 	#CheckRightBracket
		mov 	r1,r0,#0 					; save in R1
		mov 	r0,#5 						; check exists.
		jsr 	#OSFileOperation 			; do load
		pop 	link 						; restore link
		sknz 	r0 							; false if error
		jmp 	#Unary_True
		jmp 	#Unary_False

; *****************************************************************************
;
;								LOAD <procname>
;
; *****************************************************************************

.Command_Load	;; [load]
		push 	link
		jsr 	#FileLoader					; do the load
		skz 	r0
		jmp 	#_CLExit
		jsr 	#Command_Clear 				; clear because program spaced has changed
		jmp 	#WarmStart 					; and warm start.
._CLExit		
		pop 	link
		ret
;
;		Load file, R0 = 0 on exit if BASIC
;
.FileLoader
		push 	link
		jsr 	#EvaluateString 			; name of file to load
		mov 	r1,r0,#0 					; save in R1
		ldm 	r2,#programCode 			; where program memory is.
		;
		ldm 	r0,r11,#0					; get next token
		xor 	r0,#TOK_COMMA 				; if comma, get load address
		skz 	r0
		jmp 	#_CLLoadContinue 			; if not load into program memory
		inc 	r11 						; skip comma
		jsr 	#EvaluateInteger 			; get load address
		mov		r2,r0,#0 					; override target address
._CLLoadContinue
		mov 	r0,#2 						; force load to address
		jsr 	#OSFileOperation 			; do load
		skz 	r0 				
		jmp 	#LoadError 					; error if failed
		;
		ldm 	r0,#programCode 			; XOR the load address with program base
		xor 	r0,r2,#0
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
		ldm 	r1,#memAllocBottom
._CDNextLine		
		mov 	r3,#3 						; CR after every 3 entries
._CDNext
		mov	 	r4,#17-1 					; 17 characters per element		
._CDList
		ldm 	r0,r1,#0 					; check end 
		sknz 	r0
		jmp 	#_CDExit
		jsr 	#OSLowerCase 			
		jsr 	#OSPrintCharacter
		inc 	r1
		dec 	r4
		xor 	r0,#' '						; if space done this one.
		skz 	r0
		jmp 	#_CDList
._CDPad mov 	r0,#' '						; pad to 17 chars
		jsr 	#OSPrintCharacter
		dec 	r4
		skm 	r4
		jmp 	#_CDPad
		dec 	r3 							; done 3 ?
		skz 	r3
		jmp 	#_CDNext
		mov 	r0,#13 						; CR
		jsr 	#OSPrintCharacter
		jmp 	#_CDNextLine		
._CDExit		
		mov 	r0,#13 						; final CR
		jsr 	#OSPrintCharacter
		pop 	link
		ret

; *****************************************************************************
;
;								Delete file
;
; *****************************************************************************

.Command_Delete ;; [delete]
		push 	link
		jsr 	#EvaluateString 			; get delete name 
		push 	r0 							; save it
		mov 	r1,r0,#0 					
		mov 	r0,#5 						; check exists.
		jsr 	#OSFileOperation 			; do load
		skz 	r0 
		jmp 	#DeleteFileError
		pop 	r1 							; restore name to r1
		mov 	r0,#9
		jsr 	#OSFileOperation 			; do it
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
		jsr 	#_CSValidate
		mov 	r1,r0,#0 					; put string in R1
._CSHaveFileName
		jsr 	#FindProgramEnd 			; program end in R3
		mov 	r3,r0,#0
		ldm 	r2,#programCode 			; program start in R2
		sub 	r3,r2,#0 					; calculate length (end-start+1) => R3
		inc 	r3
		;
		ldm 	r0,r11,#0 					; save addr after name
		xor 	r0,#TOK_COMMA 				; if comma, get Save address
		skz 	r0
		jmp 	#_CLSaveContinue 			; if not save into program memory
		inc 	r11 						; skip comma
		jsr 	#EvaluateInteger 			; get save address
		mov		r2,r0,#0 					; override save address
		jsr 	#CheckComma
		jsr 	#EvaluateInteger 			; get save address
		mov		r3,r0,#0 					; override save length
._CLSaveContinue
		mov 	r0,#3 						; save command
		jsr 	#OSFileOperation 			; try to do it.
		skz 	r0
		jmp 	#SaveError
		pop 	link
		ret

._CSDefault
		string 	"last.save"
;
;		Validate name - must be A-Z . 0-9
;
._CSValidate	
		push 	r0,r1,r2,link
		ldm 	r1,r0,#0 					; length in R0
		sknz 	r1
		jmp 	#SaveNameError
		mov 	r1,r0,#0 					; pointer in R1
		jsr 	#OSWordLength 				; convert to word length.
._CSVLoop
		inc 	r1 							; validate it in two halves
		ldm 	r2,r1,#0
		jsr 	#_CSSubValidate
		ldm 	r2,r1,#0
		ror 	r2,#8		
		jsr 	#_CSSubValidate
		dec 	r0
		skz 	r0
		jmp 	#_CSVLoop
		pop 	r0,r1,r2,link
		ret
;
._CSSubValidate
		and 	r2,#$FF 					; not if it is $00
		sknz 	r2
		ret
		push 	r0,link
		mov 	r0,r2,#0
		jsr 	#GetCharacterType 			; 0 punctuation 1 alphabet 2 number
		sknz 	r0
		jmp 	#SaveNameError
		pop 	r0,link
		ret



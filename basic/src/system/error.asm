; *****************************************************************************
; *****************************************************************************
;
;		Name:		error.asm
;		Purpose:	Error Handler / Messages
;		Created:	2nd March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;								Specific error handlers
;
; *****************************************************************************		
	 	
.SyntaxError
		jsr 	#GenErrorHandler
		string	"Syntax"
.TypeMismatchError
		jsr 	#GenErrorHandler
		string	"Wrong type"
.DivideZeroError:
		jsr 	#GenErrorHandler
		string 	"Division by Zero"
.AssertError
		jsr 	#GenErrorHandler
		string 	"Assert"
.LineError		
		jsr 	#GenErrorHandler
		string 	"Line unknown"
.MissingBracketError
		jsr 	#GenErrorHandler
		string 	"Missing )"
.BadNumberError
		jsr 	#GenErrorHandler
		string 	"Bad Number"		
.BadIndexError
		jsr 	#GenErrorHandler
		string 	"Bad Index"		
.MemoryError
		jsr 	#GenErrorHandler
		string  "Out of Memory"
.MissingCommaError
		jsr 	#GenErrorHandler
		string  "Missing ,"
.ArrayAutoError		
		jsr 	#GenErrorHandler
		string  "Unknown Array"
.ArrayExistsError		
		jsr 	#GenErrorHandler
		string  "Array exists"
.StopError		;; [stop]
		jsr 	#GenErrorHandler
		string 	"Stop"
.StrlenError
		jsr 	#GenErrorHandler
		string 	"String Size"
.ReturnError
		jsr 	#GenErrorHandler
		string 	"Return without Gosub"
		
; *****************************************************************************
;
;							General error handler
;
; *****************************************************************************

.GenErrorHandler
		mov 	r1,r13,#0					; save error message
		mov 	r0,#$11						; red
		jsr 	#OSPrintCharacter
		mov 	r0,r1,#0					; print error message
		jsr 	#OSPrintString
		ldm 	r0,#currentLine 			; address of current line
		ldm 	r0,r0,#1					; read line number
		sknz 	r0 							; skip if non zero
		jmp 	#_ehExit
		jsr 	#OSPrintInline 				; print at
		string 	" @ "
		mov 	r1,#10 						; convert line# to string and print that
		jsr 	#OSIntToStr
		jsr 	#OSPrintString
		jsr 	#OSPrintInline 				; print at
		string 	"[0D][12]"					; CR and make green
._ehExit		
		jmp 	#WarmStart

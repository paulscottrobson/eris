; *****************************************************************************
; *****************************************************************************
;
;		Name:		error.asm
;		Purpose:	Error Handler / Messages
;		Created:	2nd March 2020
;		Reviewed: 	16th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;							General error handler
;
; *****************************************************************************

.GenErrorHandler
		mov 	r1,link,#0					; get error message address from link
		mov 	r0,#$11						; red display colour.
		jsr 	#OSPrintCharacter
		mov 	r0,r1,#0					; print error message
		jsr 	#OSPrintString
		;
		ldm 	r0,#currentLine 			; address of current line
		ldm 	r0,r0,#1					; read line number of current line
		sknz 	r0 							; if zero
		jmp 	#_ehExit
		jsr 	#OSPrintInline 				; print @ as a seperator
		string 	" @ "
		mov 	r1,#10 						; convert line# to string and print that
		jsr 	#OSIntToStr
		jsr 	#OSPrintString
._ehExit
		jsr 	#OSPrintInline 				; print CR and make green
		string 	"[0D][12]"					
		jsr 	#OSResetAllChannels
		jmp 	#WarmStartNoReady

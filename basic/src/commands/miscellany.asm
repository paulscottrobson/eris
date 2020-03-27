; *****************************************************************************
; *****************************************************************************
;
;		Name:		miscellany.asm
;		Purpose:	Miscellaneous Commands
;		Created:	3rd March 2020
;		Reviewed: 	16th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;								Stop Program
;
; *****************************************************************************

.Command_Stop		;; [stop]	
		jmp 	#StopError
		
; *****************************************************************************
;
;								End Program
;
; *****************************************************************************

.Command_End		;; [end]	
		jmp 	#WarmStart

; *****************************************************************************
;
;								Assert Handler
;
; *****************************************************************************

.CommandAssert 		;; [assert]
		push 	link
		jsr 	#EvaluateInteger 			; assert what ?
		sknz 	r0
		jmp 	#AssertError 				; failed.
		pop 	link
		ret

; *****************************************************************************
;
;							Poke a memory location
;
; *****************************************************************************

.CommandPoke 		;; [poke]
		push 	link
		jsr 	#EvaluateInteger 			; address to poke -> R1
		mov 	r1,r0,#0 
		jsr 	#CheckComma
		jsr 	#EvaluateInteger 			; data -> R0
		stm 	r0,r1,#0 					; do the POKE
		pop 	link
		ret

; *****************************************************************************
;
;							Call a M/C Routine
;
; *****************************************************************************

.CommandSys 		;; [sys]
		push 	link
		jsr 	#EvaluateInteger 			; address -> R1
		mov 	r1,r0,#0 
		mov 	r0,#fixedVariables 			; pass variables in R0 e.g. the address of A-Z block
		push 	r11 						; R11 is the program position, don't want that changed.
		brl 	link,r1,#0 					; call the routine
		pop 	r11
		pop 	link
		ret

; *****************************************************************************
;
;					Code for ' and REM comment handlers
;				  Can be REM or REM "comment", same for '
;
; *****************************************************************************

.CommentCommand1 	;; [']
.CommentCommand2 	;; [rem]
		ldm 	r11,#currentLine 			; get current line
		ldm 	r0,r11,#0 					; read offset of current line
		add 	r11,r0,#0 					; add to take to next line.
		dec 	r11 						; last token of line $0000 will force next line.
		ret

; *****************************************************************************
;
;					  				Move cursor
;
; *****************************************************************************

.Command_Cursor 	;; [cursor]
		push 	link
		jsr 	#EvaluateInteger
		mov 	r1,r0,#0
		sub 	r0,#CharWidth
		sklt
		jmp 	#BadNumberError
		jsr 	#CheckComma
		jsr 	#EvaluateInteger
		mov 	r2,r0,#0
		sub 	r0,#CharHeight
		sklt
		jmp 	#BadNumberError
		;
		stm 	r1,#xTextPos
		stm 	r2,#yTextPos
		pop 	link
		ret

; *****************************************************************************
;
;					  Wait for a given number of 1/100 sec
;
; *****************************************************************************

.CommandWait 	;; [wait]
		push 	link
		jsr 	#EvaluateInteger 			; how long to wait
		ldm 	r1,#hwTimer					; add current value
		add 	r1,r0,#0
._CWTLoop
		jsr 	#OSSystemManager 			; keep stuff going
		skz 	r0 							; exit on break
		jmp 	#BreakError 				; error if broken.
		ldm 	r0,#hwTimer
		sub 	r0,r1,#0 					; until timer >= end signed
		skp 	r0
		jmp 	#_CWTLoop
		pop 	link
		ret

; *****************************************************************************
;
;					  Code for colon, which does nothing
;
; *****************************************************************************

.ColonHandler 	;; [:]
		ret


; *****************************************************************************
;
;								Renumber program
;
; *****************************************************************************

.RenumberProgram ;; [renumber]
		mov 	r1,#1000 					; current line number
		ldm 	r0,#programCode 			; R0 is current program
._RPLoop
		ldm 	r2,r0,#0 					; read offset to R2
		sknz 	r2 							; exit if offset zero
		ret		
		stm 	r1,r0,#1 					; overwrite line number
		add 	r1,#10 						; update line number
		add 	r0,r2,#0 					; next line
		jmp 	#_RPLoop

; *****************************************************************************
;
;			Code for non-executable, stops the build squawking
;
; *****************************************************************************

.Dummy1 		;; [)]
.Dummy2 		;; [,]
.Dummy3 		;; [;]
.Dummy4 		;; [to]
.Dummy5 		;; [step]
.Dummy6 		;; [then]
.Dummy7 		;; [#]
.Dummy8 		;; [crunch] 			
.Dummy9 		;; [flip] 
;
;		This lot are not commands per se, but are handled in RUN as token values.
;
.Dummy10 		;; [adc]
.Dummy11		;; [add]
.Dummy12		;; [brl]
.Dummy13 		;; [ldm]
.Dummy14 		;; [mov]
.Dummy15 		;; [mult]
.Dummy16 		;; [ror]
.Dummy17 		;; [skcm]
.Dummy18 		;; [skeq]
.Dummy19 		;; [skne]
.Dummy20 		;; [skse]
.Dummy21 		;; [sksn]
.Dummy22 		;; [stm]
.Dummy23 		;; [sub]
				jmp 	#SyntaxError

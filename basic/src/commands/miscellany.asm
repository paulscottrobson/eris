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
		brl 	link,r1,#0 					; call the routine
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
		ldm 	r0,r11,#0 					; is there a string there e.g. 01xx ?
		mov 	r1,r0,#0 					; length in R1
		and 	r1,#$00FF
		and 	r0,#$FF00 					; msb of token in R0 					
		xor 	r0,#$0100 					; if it is $0100 then 
		sknz 	r0
		add 	r11,r1,#0 					; add the length to R11. skipping string
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

.Dummy7 		;; [adc]
.Dummy8 		;; [add]
.Dummy9 		;; [brl]
.Dummy10 		;; [jmp]
.Dummy11		;; [jsr]
.Dummy12 		;; [ldm]
.Dummy13 		;; [mov]
.Dummy14 		;; [mult]
.Dummy15 		;; [ret]
.Dummy16 		;; [ror]
.Dummy17 		;; [skc]
.Dummy18 		;; [skcm]
.Dummy19 		;; [skeq]
.Dummy20 		;; [skm]
.Dummy21 		;; [sknc]
.Dummy22 		;; [skne]
.Dummy23 		;; [sknz]
.Dummy24 		;; [skp]
.Dummy25 		;; [skse]
.Dummy26 		;; [sksn]
.Dummy27 		;; [skz]
.Dummy28 		;; [stm]
.Dummy29 		;; [sub]
				jmp 	#SyntaxError

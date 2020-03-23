; *****************************************************************************
; *****************************************************************************
;
;		Name:		call.asm
;		Purpose:	Procedure Call Code
;		Created:	11th March 2020
;		Reviewed: 	17th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;								CALL <procname>
;
; *****************************************************************************

.Command_Call 	;; [call]
		push 	link
		jsr 	#ProcedureSearch			; try to find it.
		jsr 	#LocalNewFrame		 		; start a new local variable frame for locals/parameters
		ldm 	r0,r4,#0 					; are there any parameters
		xor 	r0,#TOK_RPAREN
		skz 	r0
		jsr 	#_CCADoParameters
		mov 	r11,r4,#0 					; update R11 with caller address - address after CALL <ident>
		jsr 	#CheckRightBracket 			; check that it is using () to call
		;
		jsr 	#StackPushPosition 			; push current position/line offset
		jsr 	#StackPushMarker 			; push a 'C' marker
		word 	'C'
		mov 	r11,r3,#0 					; new code address after PROC <identifier>
		stm 	r2,#currentLine 			; set current line
		;
		jsr 	#CheckRightBracket 			; check a right bracket follows the PROC definition
		pop 	link
		ret
		;
		;		Parameters. R4 is the call, and R3 the definition
		;
._CCADoParameters
		push 	r0,r1,r2,link
._CCADPLoop
		mov 	r11,r3,#0 					; put the definition into the current slot, 
		clr 	r0 							; do not clear default value
		jsr 	#LocalPushReference 		; localise it, (push on stack and do not set to default value).
		mov 	r3,r11,#0
		;
		ldm 	r2,r10,#esType1 			; get type, integer or string
		ldm 	r1,r10,#esValue1 			; get the reference to the variable in the parameter.
		;
		mov 	r11,r4,#0 					; evaluate the parameter passed in.
		;
		sknz 	r2 							; use the type of the target to type check the parameter value
		jsr 	#EvaluateInteger
		skz 	r2
		jsr 	#EvaluateString
		mov 	r4,r11,#0 					; put the pointer back.
		;
		sknz 	r2
		stm 	r0,r1,#0 					; save the value if integer
		skz 	r2
		jsr 	#StringAssign  				; assign string if err. string
._CCADPNotString		
		ldm 	r0,r4,#0 					; followed by comma ?
		inc 	r3
		inc 	r4
		xor 	r0,#TOK_COMMA
		sknz 	r0
		jmp 	#_CCADPLoop
		dec 	r4 							; undo the comma - get
		dec 	r3
		pop 	r0,r1,r2,link
		ret
		;
		;		Find the identifier at R11. On exit R4 is the token after the identifier in the
		;		call, and R3 the token after the identifier in the target , current line in R2
		;
.ProcedureSearch
		ldm 	r1,#procTable 				; R1 is the list of address of lines that begin PROC <ident>
		;
._PSELoop
		ldm 	r2,r1,#0 					; R2 is the one being checked now.
		inc 	r1 							; bump the list pointer
		sknz 	r2 							; end of list if zero.
		jmp 	#CallError
		mov 	r3,r2,#3 					; R3 is the target being checked, skip offset and PROC
		mov 	r4,r11,#0 					; R4 is the caller being checked
._PSECheck
		ldm 	r0,r3,#0 					; get the two.
		ldm 	r5,r4,#0
		inc 	r3 							; bump pointers.
		inc 	r4		
		xor 	r0,r5,#0 					; if they don't match, try the next entry in the table
		skz 	r0
		jmp 	#_PSELoop
		ror 	r5,#14 						; rotate end bit into sign position
		skm 	r5 							; go back if not the end.
		jmp 	#_PSECheck
		ret

; *****************************************************************************
;
;			 PROC <definition> causes a syntax error when executed
;
; *****************************************************************************

.Command_Proc 	;; [proc]
		jmp 	#SyntaxError

; *****************************************************************************
;
;									ENDPROC
;
; *****************************************************************************

.Command_EndProc 	;; [endproc]
		push 	link
		jsr 	#StackCheckMarker 			; check TOS is an 'C' marker.
		word 	'C'
		jmp 	#EndProcError
		jsr 	#StackPopPosition 			; restore position from stack.
		mov 	r0,#1+stackPosSize 			; and reclaim that many words off the stack
		jsr 	#StackPopWords
		jsr 	#LocalRestoreFrame 			; unpick the stack.
		pop 	link
		ret

; *****************************************************************************
;
;			Scan the program for lines beginning PROC <identifier> and
;			build a table of them
;
; *****************************************************************************

.ScanForProcedures
		ldm 	r2,#memAllocBottom 			; R2 start the table in low memory
		stm 	r2,#procTable 				; this is where the table is.
		ldm 	r3,#programCode 			; R3 is the program being scanned.
		;
._SFPLoop
		ldm 	r0,r3,#0 					; get offset 
		sknz 	r0 							; if zero, done the whole program
		jmp 	#_SFPExit
		;
		;		Now see if this line is PROC<ident>
		;
		ldm 	r1,r3,#2 					; get first token
		xor 	r1,#TOK_PROC 				; is it PROC ?
		skz 	r1
		jmp 	#_SFPNext 				
		;
		ldm 	r1,r3,#3 					; get thing after PROC
		and 	r1,#$C000	 				; is it an identifier
		xor 	r1,#$4000
		skz 	r1
		jmp 	#_SFPNext

		stm 	r3,r2,#0 					; write this line address out
		inc 	r2 							; bump pointer into proc table
		mov 	r1,r2,#4 					; check not reached the top e.g. table won't fit.
		ldm 	r4,#memAllocTop
		sub 	r1,r4,#0
		sklt
		jmp 	#MemoryError
		;
._SFPNext
		add 	r3,r0,#0 					; add previously loaded offset
		jmp 	#_SFPLoop 					; go round again

._SFPExit
		stm 	r14,r2,#0 					; save the end marker $0000
		inc 	r2 							; write out the new bottom memory addr
		stm 	r2,#memAllocBottom						
		ret

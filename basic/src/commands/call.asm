; *****************************************************************************
; *****************************************************************************
;
;		Name:		call.asm
;		Purpose:	Procedure Call Code
;		Created:	11th March 2020
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
		ldm 	r1,#procTable 				; R1 is the list of procedure lines
		;
._CCALoop
		ldm 	r2,r1,#0 					; R2 is the one being checked now.
		inc 	r1 							; bump the list pointer
		sknz 	r1
		jmp 	#CallError
		mov 	r3,r2,#3 					; R3 is the target being checked
		mov 	r4,r11,#0 					; R4 is the caller being checked
._CCACheck
		ldm 	r0,r3,#0 					; get the two.
		ldm 	r5,r4,#0
		inc 	r3 							; bump pointers.
		inc 	r4		
		xor 	r0,r5,#0 					; if they don't match, try the next entry
		skz 	r0
		jmp 	#_CCALoop
		ror 	r5,#14 						; rotate end bit into sign position
		skm 	r5 							; go back if not the end.
		jmp 	#_CCACheck
		;
		;		Successful search !
		;		
		mov 	r11,r4,#0 					; update R11 with caller address
		jsr 	#StackPushPosition 			; push current position/line offset
		jsr 	#StackPushMarker 			; push a 'C' marker
		word 	'C'
		mov 	r11,r3,#0 					; new code address after PROC <identifier>
		stm 	r2,#currentLine 			; set current line
		pop 	link
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
		inc 	r2 							; bump pointer
		mov 	r1,r2,#4 					; check not reached the top.
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

; *****************************************************************************
; *****************************************************************************
;
;		Name:		assembler.asm
;		Purpose:	Assembler core code
;		Created:	22nd March 2020
;		Reviewed: 	TODO
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;								Assembler Reset
;
; *****************************************************************************

.AsmReset
		stm 	r14,#asmPointer 			; clear the assembly pointer, which cannot be zero
		ret

; *****************************************************************************
;
;							Code <address>,<mode>
;
; *****************************************************************************

.Command_Code 		;; [code]
		push 	link
		jsr 	#EvaluateInteger 			; address
		stm 	r0,#asmPointer
		jsr 	#CheckComma
		jsr 	#EvaluateInteger 			; mode
		stm 	r0,#asmMode
		pop 	link
		ret	

; *****************************************************************************
;
;						Assemble numbers/strings
;
; *****************************************************************************

.Command_Word 		;; [word]
		push 	link
._CWLoop
		jsr 	#EvaluateExpression 		; evaluate expression
		ldm 	r0,r10,#esValue1 			; get value 
		ldm 	r1,r10,#esReference1 		; dereference it if required
		skz 	r1
		ldm 	r0,r0,#0
		ldm 	r1,r10,#esType1 			; get the type
		skz 	r1
		jmp 	#_CWString
		;
		jsr 	#AsmWord 					; assemble integer
		jmp 	#_CWNext
._CWString	
		mov 	r1,r0,#0 					; pointer in R1
		jsr 	#OSWordLength 				; # of words in R2
		mov 	r2,r0,#0
._CWCopyString
		ldm 	r0,r1,#0 					; output the string
		jsr 	#AsmWord
		inc 	r1
		dec 	r2
		skm 	r2 							; +1 to include the length count
		jmp 	#_CWCopyString

._CWNext
		ldm 	r0,r11,#0 					; get and bump
		inc 	r11
		xor 	r0,#TOK_COMMA 				; if comma loop back
		sknz 	r0
		jmp 	#_CWLoop
		dec 	r11 						; undo increment
		pop 	link
		ret

; *****************************************************************************
;
;					Assemble a single word into memory
;
; *****************************************************************************

.AsmWord
		push 	r1,r2,link
		ldm 	r1,#asmPointer 				; write to memory
		sknz 	r1 							; error if not done.
		jmp 	#NoAddressError 
		stm 	r0,r1,#0 					; write out
		mov 	r0,r1,#0 					; address in R0,R2
		mov 	r2,r1,#0
		inc 	r1 							; bump and write pointer
		stm 	r1,#asmPointer
		;	
		ldm 	r1,#asmMode 				; check if bit 1 set
		and 	r1,#2
		sknz 	r1 							; if not don't list
		jmp 	#_AWExit
		mov 	r1,#16 						; print address
		jsr 	#OSIntToStr
		jsr 	#OSPrintString
		mov 	r0,#58 						; print colon
		jsr 	#OSPrintCharacter
		ldm 	r0,r2,#0 					; get word back
		jsr 	#OSIntToStr
		jsr 	#OSPrintString
		mov 	r0,#13 						; CRLF
		jsr 	#OSPrintCharacter
._AWExit		
		pop 	r1,r2,link
		ret

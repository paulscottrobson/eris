; *****************************************************************************
; *****************************************************************************
;
;		Name:		rpl.asm
;		Purpose:	RPL Handler
;		Created:	15th April 2020
;		Reviewed: 	TODO
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;								RPL Compiler
;
; *****************************************************************************

.Unary_RPL 		;; [rpl(]
		ldm 	r0,#asmPointer 				; preserve code start
		push 	r0,r1,r2,r9,r10,link
		mov 	r0,#$5CE1 					; sub r12,r14,#1 					
		jsr 	#AsmWord
		mov 	r0,#$2DC0 					; stm r13,r14,#0
		jsr 	#AsmWord
._URPLLoop
		ldm 	r0,r11,#0 					; error if $0000
		sknz 	r0
		jmp 	#MissingBracketError
		xor 	r0,#TOK_RPAREN 				; exit if )
		sknz 	r0
		jmp 	#_URPLExit
		jsr 	#RPLCompileOne 				; compile one token/token group
		jmp 	#_URPLLoop
._URPLExit
		mov 	r0,#$1DC0 					; ldm r13,r12,#0
		jsr 	#AsmWord
		mov 	r0,#$3CE1 					; add r12,r14,#1
		jsr 	#AsmWord
		mov 	r0,#$AFD0 					; brl r15,r13
		jsr 	#AsmWord
		inc 	r11 						; skip )
		pop 	r0,r1,r2,r9,r10,link 		; restore
		stm 	r0,r10,#esValue1 			; save return value and exit
		stm 	r14,r10,#esReference1
		stm 	r14,r10,#esType1
		ret

; *****************************************************************************
;
;						Compile a single RPL element
;
; *****************************************************************************

.RPLCompileOne		
		push 	r0,r1,r2,r3,r4,r5,r6,link
		ldm 	r0,r11,#0 					; next token
		skp 	r0 							; if 8000-FFFF represents 0000-7FFF
		jmp 	#_RPLCOConstant1
		xor 	r0,#TOK_VBARCONSTSHIFT		; constant shift.
		sknz 	r0
		jmp 	#_RPLCOConstant0 			; do it as a 8000-FFFF constant
		ldm 	r0,r11,#0 					
		and 	r0,#$FF00 					; check it is $01xx
		xor 	r0,#$0100
		sknz 	r0
		jmp 	#_RPLCOString
;
;		Check Tokens, Variables in the dictionary
;
		mov 	r1,#RPLDictionary
._RPLTVLoop1
		mov 	r2,r1,#3					; R2 is the first token to compare
		mov 	r3,r11,#0 					; compare it against R3
		ldm 	r4,r1,#2 					; R4 is the number of characters to compare
		and 	r4,#15
._RPLTVLoop2
		ldm 	r5,r2,#0 					; get and compare them
		ldm 	r6,r3,#0
		xor 	r5,r6,#0
		skz 	r5
		jmp 	#_RPLTVNext 				; if different go to next
		inc 	r2 							; next to compare
		inc 	r3
		dec 	r4 							; until all compared.
		skz 	r4
		jmp 	#_RPLTVLoop2
		;
		mov 	r11,r3,#0 					; point past found word.
		ldm 	r0,r1,#2 					; get the length, check bit 15
		skp 	r0
		jmp 	#_RPLTVImmediate
		ldm 	r1,r1,#1 					; address
		;
		;		Compile call to R1
		;
._RPLCallCompile		
		mov 	r0,#$ADF0 					; jsr #nnnn
		jsr 	#AsmWord
		mov 	r0,r1,#0
		jsr 	#AsmWord
		jmp 	#_RPLCExit
		;
._RPLTVImmediate	
		ldm 	r0,r1,#1 					; get code address
		brl 	r13,r0,#0 					; call that routine.
		jmp 	#_RPLCExit
		;
		;		Go to next entry
		;
._RPLTVNext
		ldm 	r0,r1,#0 					; get offset
		add 	r1,r0,#0 					; advance to next
		ldm 	r0,r1,#0 					; check that offset
		skz 	r0 							; go back if non zero
		jmp 	#_RPLTVLoop1
;
;		Evaluate variable, perhaps :)
;
		; TODO: Check its an identifier first.
		jsr 	#EvaluateTermInteger 		; get a term.
		sknz 	r0
		jmp 	#CallError 					; not zero.
		mov 	r1,r0,#0 					; put in R1
		jmp 	#_RPLCallCompile
;
;		Handle string
;
._RPLCOString
		mov 	r1,r11,#1 					; address of string in R1
		ldm 	r0,r11,#0 					; get overall length and add
		and 	r0,#$00FF
		add 	r11,r0,#0
		jmp 	#_RPLCODoConstant 			; output string address as constant.
;
;		Handle constants / shifted constants
;
._RPLCOConstant0
		inc 	r11 						; skip constant shift token
		clr 	r0 							; xor with zero.
		skz 	r0
._RPLCOConstant1
		mov 	r0,#$8000 					; value to XOR.
		ldm 	r1,r11,#0 					; XOR with constant.
		xor 	r1,r0,#0 					; R1 = constant to write out
		inc 	r11 						; skip past constant
;
;		Code to output constant in R1
;
._RPLCODoConstant
		mov 	r0,#$58E1 					; sub r8,r14,#1 					
		jsr 	#AsmWord
		mov 	r0,#$2080  					; stm r0,r8,#0
		jsr 	#AsmWord
		;
		mov 	r0,r1,#0 					; check if $00-$0F
		and 	r0,#$FFF0
		skz 	r0
		jmp 	#_RPLCLongConstant
		;
		mov 	r0,#$00E0 					; mov r0,r14,#0 (short constant)
		add 	r0,r1,#0 					; now move r0,r14,#n
		jsr 	#AsmWord
		jmp 	#_RPLCExit
		;
._RPLCLongConstant
		mov 	r0,#$00F0 					; mov r0,r15,#0 (long constant)
		jsr 	#AsmWord
		mov 	r0,r1,#0 					; followed by data		
		jsr 	#AsmWord
		;
._RPLCExit
		pop 	r0,r1,r2,r3,r4,r5,r6,link
		ret

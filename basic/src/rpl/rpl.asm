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
;		clr 	r0
;		jsr 	#AsmWord
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
		push 	link
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
		break
._RPLCExit
		pop 	link
		ret
;
;		Todo  Tokens, Variables.
;

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
		jmp 	#_RPLCExit


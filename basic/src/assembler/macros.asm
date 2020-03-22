; *****************************************************************************
; *****************************************************************************
;
;		Name:		macros.asm
;		Purpose:	They aren't really macros, more syntactic sugar.
;		Created:	22nd March 2020
;		Reviewed: 	TODO
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;			The first group are simple macros that generate a constant
;
; *****************************************************************************

.Macro_Ret			;; [ret]
		mov 	r0,#$AFD0
		jmp 	#AsmWord

.Macro_Sknc			;; [sknc]
.Macro_Sklt			;; [sklt]
		mov 	r0,#$FFE0
		jmp 	#AsmWord

.Macro_Skc 			;; [skc]
.Macro_Skge			;; [skge]
		mov 	r0,#$FFE1
		jmp 	#AsmWord

; *****************************************************************************
;
;						The second group are jump and call 
;
; *****************************************************************************

.Macro_Jmp 			;; [jmp]
		mov 	r0,#$AFF0
		sknz 	r0
.Macro_Jsr 			;; [jsr]
		mov 	r0,#$ADF0		
		push 	link
		jsr 	#AsmWord
		jsr 	#CheckHash
		jsr 	#EvaluateInteger
		jsr 	#AsmWord
		pop 	link
		ret

; *****************************************************************************
;
;			The third group is take a single register as a parameter
;			Note that clr uses R14 here, in the Python assembler it uses XOR.
;
; *****************************************************************************

.Macro_Clr 	;; [clr]
		mov 	r2,#$00E0
		jmp 	#Macro_SingleReg
.Macro_Skz 	;; [skz]
		mov 	r2,#$B0E0
		jmp 	#Macro_SingleReg
.Macro_Sknz ;; [sknz]
		mov 	r2,#$C0E0
		jmp 	#Macro_SingleReg
.Macro_Skp ;; [skp]
		mov 	r2,#$D0E0
		jmp 	#Macro_SingleReg
.Macro_Skm ;; [skm]
		mov 	r2,#$E0E0
.Macro_SingleReg
		push 	link
		jsr 	#AssembleGetRegister 		; get a register
		ror 	r0,#8 						; shift into bits 8..11
		add 	r0,r2,#0 					; build
		jsr 	#AsmWord 		 			; and write
		pop 	link
		ret

; *****************************************************************************
;
;			Finally push and pop which can do multiple registers
;
; *****************************************************************************

.Macro_Push 	;; [push]
		clr 	r1 							; R1 = 0 (push) 1 (pull)
		skz 	r14
.Macro_Pop 		;; [pop]
		mov 	r1,#1
		clr 	r2 							; R2 is what registers. bit 15 = R0 etc.
		push 	link
._MacPGet	
		jsr 	#AssembleGetRegister 		; get a register
		mov 	r3,r0,#0 					; save it
		and 	r0,#$FFF0 					; check 0-15
		skz 	r0
		jmp 	#BadRegisterError
		;
		mov 	r4,#$8000 					; R4 is the bitmask.
		ror 	r4,r3,#0 					; this is the bit to set
		mov 	r0,r2,#0 					; check if it is already set in R2
		and 	r0,r4,#0 
		skz 	r0
		jmp 	#BadRegisterError
		xor 	r2,r4,#0 					; set that bit
		ldm 	r0,r11,#0 					; get next and bump pre-emptively
		inc 	r11
		xor 	r0,#TOK_COMMA 				; if , then go back
		sknz 	r0
		jmp 	#_MacPGet
		dec 	r11 						; undo pre-emptive bump.
		sknz 	r2 							; check any registers ?
		jmp 	#BadRegisterError
		;
		mov 	r0,#$5CE0 					; this is the base for subtracting in advance
		sknz 	r1 							; if R1 = 0 e.g. push
		jsr 	#_MacPAdjustSP 				; change the stack pointer.

		clr 	r4 							; R4 is the current offset.
		clr 	r5 							; R5 is the register number
		mov 	r3,r2,#0 					; R3 is the bits we destroy to check.
._MACStoreLoad
		add 	r3,r3,#0 					; shift bits into carry
		skc
		jmp 	#_MACSLNext
		;
		mov		r0,r5,#0 					; register number into bits 8..11 of R0
		ror 	r0,#8
		add 	r0,r4,#0 					; add offset now 0<reg>0<offset>
		;
		sknz 	r1 							; if PUSH
		add 	r0,#$20C0 					; stm Rx,R12,offset
		skz 	r1 							; if PULL
		add 	r0,#$10C0 					; ldm Rx,R12,offset
		jsr 	#AsmWord 					; write it out
		inc 	r4 							; bump frame offset
		;
._MACSLNext		
		inc 	r5 							; increment the current register number
		skz 	r3 							; go back if we haven't done everything.
		jmp 	#_MACStoreLoad
		;
		mov 	r0,#$3CE0 					; this is the base for adding afterwards
		skz 	r1 							; if R1 != 0 e.g. pop
		jsr 	#_MacPAdjustSP 				; change the stack pointer.
		pop 	link
		ret
;
;		Adjust SP (12) by the number of bits set in R2. Instruction Base is in R0.
;
._MACPAdjustSP
		push 	r0,r1,link
		mov 	r1,r2,#0 					; R1 we use to count the bits
._MACPACount
		add 	r1,r1,#0 					; shift left into carry
		sknc
		inc 	r0 							; adjust instructions using carry
		skz 	r1 							; until all bits shifted out
		jmp 	#_MACPACount		
		jsr 	#AsmWord 					; write the modified instruction
		pop 	r0,r1,link
		ret

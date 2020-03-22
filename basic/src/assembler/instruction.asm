; *****************************************************************************
; *****************************************************************************
;
;		Name:		instruction.asm
;		Purpose:	Assemble a single instruction
;		Created:	22nd March 2020
;		Reviewed: 	TODO
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;	   From the run handler ; process a single assembler instruction @ R11
;
; *****************************************************************************

.AssembleInstruction
		push 	link
		ldm 	r2,r11,#0 					; first get the instruction into R2
		and 	r2,#15 						; which is the lower 4 bits of the token
		ror 	r2,#4 						; put into bits 15..12
		inc 	r11 						; step past the instruction
		;
		jsr 	#AssembleGetRegister 		; get a register
		ror 	r0,#8 						; put into bits 11..8 and add to instruction in R2
		add 	r2,r0,#0
		jsr 	#CheckComma 				; skip the comma which must follow.
		;
		ldm 	r0,r11,#0 					; if what follows is a # then it is the long form
		xor 	r0,#TOK_HASH
		sknz 	r0
		jmp 	#_AILongFormat
		;
		;		Short format 	opcode r1,r2,#const
		;
		jsr 	#AssembleGetRegister 		; get another register
		ror 	r0,#12 						; put into bits 7..4
		add 	r2,r0,#0
		jsr 	#CheckComma 				; skip the comma which must follow.
		;
		jsr 	#CheckHash 					; check the hash follows.
		jsr 	#EvaluateInteger 			; and the parameter which must be 0-15
		mov 	r1,r0,#0
		and 	r1,#$FFF0
		skz 	r1
		jmp 	#BadNumberError
		add 	r0,r2,#0 					; build final opcode
		jsr 	#AsmWord 					; write it out
		jmp 	#_AIExit 					; and exit
		;
		;		Long format 	opcode r1,#const - const can be 1-15 or more than that.
		;
._AILongFormat
		jsr 	#CheckHash 					; check the hash follows.
		jsr 	#EvaluateInteger 			; get the parameter.
		sknz 	r0 							; if zero, check pass and assume long format
		jmp 	#_ATICheckZero
		mov 	r1,r0,#0 					; check if 1-15
		and 	r1,#$FFF0
		skz 	r1
		jmp 	#_AITwoByteLongFormat
		;
		add 	r0,r2,#0 					; make OP R,#n OP R,R14,#n as short constant
		add 	r0,#$E0 					; this is R14 as 2nd register
		jsr 	#AsmWord 					; write it out
		jmp 	#_AIExit 					; and exit
		;
._ATICheckZero		
		ldm 	r1,#asmMode 				; cannot have 2nd pass zero
		and 	r1,#1
		sknz 	r1
		jmp 	#BadNumberError 			; autoinitialised
._AITwoByteLongFormat
		mov 	r1,r0,#0 					; save value in R1
		mov 	r0,r2,#0 					; get opcode back
		add 	r0,#$F0 					; make OP R,#n OP R,R15,#0 : word n
		jsr 	#AsmWord
		mov 	r0,r1,#0 					; e.g. a 2 word instruction
		jsr 	#AsmWord
._AIExit
		pop 	link
		ret

; *****************************************************************************
;
;							Get a register reference
;
; *****************************************************************************

.AssembleGetRegister
		push 	r1,r2,r3,link
		mov 	r1,#AsmRegisters+15 		; check the R0-RF values in the LUT
		mov 	r0,#15
._AGRCheck
		ldm 	r2,r1,#0 					; table entry
		ldm 	r3,r11,#0 					; token
		inc 	r11 						; pre-emptive bump
		xor 	r2,r3,#0 					; if the same
		sknz 	r2
		jmp 	#_AGRExit 					; exit with const in R0
		dec 	r11 						; unpick
		dec 	r1 							; check backwards
		dec 	r0
		skm 	r0 							; until done the whole table
		jmp 	#_AGRCheck
		;
		jsr 	#EvaluateInteger
		mov 	r1,r0,#0 					; must be 0-15
		and 	r1,#$FFF0
		skz 	r1
		jmp 	#BadRegisterError
._AGRExit		
		pop 	r1,r2,r3,link
		ret

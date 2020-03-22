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

;			rList = self.evaluator.evaluateOperands(parts.group(2).strip().split(","),True)
;			rList.sort()
;			code = []
;			if isPush:															# make space
;				code = code + self.assemble("sub sp,r14,#{0}".format(len(rList)),True)
;			for i in range(0,len(rList)):										# read/write in frame
;				cmd = "stm" if isPush else "ldm"
;				code = code + self.assemble("{0} {1},sp,#{2}".format(cmd,rList[i],i),True)
;			if not isPush:														# restore sp
;				code = code + self.assemble("add sp,r14,#{0}".format(len(rList)),True)


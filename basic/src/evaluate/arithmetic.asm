; *****************************************************************************
; *****************************************************************************
;
;		Name:		arithmetic.asm
;		Purpose:	Basic arithmetic functions
;		Created:	3rd March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;								binary add
;
; *****************************************************************************

.BinaryOp_Add		;; [+]
		push 	link
		jsr 	#MultiTypeDispatch
		jmp 	#StringConcat
		jsr 	#CheckIntDereference
		ldm 	r0,r10,#esValue1
		ldm 	r1,r10,#esValue2
		add 	r0,r1,#0
		stm 	r0,r10,#esValue1
		pop 	link
		ret

; *****************************************************************************
;
;								binary sub
;
; *****************************************************************************

.BinaryOp_Sub		;; [-]
		push 	link
		jsr 	#CheckIntDereference
		ldm 	r0,r10,#esValue1
		ldm 	r1,r10,#esValue2
		sub 	r0,r1,#0
		stm 	r0,r10,#esValue1
		pop 	link
		ret

; *****************************************************************************
;
;							 binary multiply
;
; *****************************************************************************

.BinaryOp_Mult		;; [*]
		push 	link
		jsr 	#CheckIntDereference
		ldm 	r0,r10,#esValue1
		ldm 	r1,r10,#esValue2
		mult 	r0,r1,#0
		stm 	r0,r10,#esValue1
		pop 	link
		ret

; *****************************************************************************
;
;							 binary multiply/divide
;
; *****************************************************************************

.BinaryOp_Divide	;; [/]
		push 	link
		jsr 	#CheckIntDereference
		ldm 	r0,r10,#esValue1
		ldm 	r1,r10,#esValue2
		sknz 	r1
		jmp 	#DivideZeroError
		jsr 	#OSSDivide16
		stm 	r0,r10,#esValue1
		pop 	link
		ret

.BinaryOp_Mod	;; [mod]
		push 	link
		jsr 	#CheckIntDereference
		ldm 	r0,r10,#esValue1
		ldm 	r1,r10,#esValue2
		sknz 	r1
		jmp 	#DivideZeroError
		jsr 	#OSSDivide16
		stm 	r1,r10,#esValue1
		pop 	link
		ret

; *****************************************************************************
;
;							 logical and
;
; *****************************************************************************

.BinaryOp_And	;; [and]
		push 	link
		jsr 	#CheckIntDereference
		ldm 	r0,r10,#esValue1
		ldm 	r1,r10,#esValue2
		and 	r0,r1,#0
		stm 	r0,r10,#esValue1
		pop 	link
		ret

; *****************************************************************************
;
;							 logical or
;
; *****************************************************************************

.BinaryOp_Or	;; [or]
		push 	link
		jsr 	#CheckIntDereference
		ldm 	r0,r10,#esValue1 			; no OR in instruction set
		xor 	r0,#$FFFF 					; so ~(~A . ~B)
		ldm 	r1,r10,#esValue2
		xor 	r1,#$FFFF
		and 	r0,r1,#0
		xor 	r0,#$FFFF
		stm 	r0,r10,#esValue1
		pop 	link
		ret

; *****************************************************************************
;
;							 logical xor
;
; *****************************************************************************

.BinaryOp_Xor	;; [xor]
		push 	link
		jsr 	#CheckIntDereference
		ldm 	r0,r10,#esValue1
		ldm 	r1,r10,#esValue2
		xor 	r0,r1,#0
		stm 	r0,r10,#esValue1
		pop 	link
		ret

; *****************************************************************************
;
;							 binary indirection
;
; *****************************************************************************

.BinaryOp_Indirect		;; [!]
		push 	link
		jsr 	#CheckIntDereference
		ldm 	r0,r10,#esValue1
		ldm 	r1,r10,#esValue2
		add 	r0,r1,#0
		stm 	r0,r10,#esValue1
		stm		r15,r10,#esReference1
		pop 	link
		ret

; *****************************************************************************
;
;			Check binary values are both string, and dereference them
;
; *****************************************************************************

.CheckIntDereference
		ldm 	r0,r10,#esType1 			; both types should be zero.
		ldm 	r1,r10,#esType2
		add 	r0,r1,#0
		skz 	r0  						; if so *fall through* to dereference
		jmp 	#TypeMismatchError 

; *****************************************************************************
;
;						Dereference binary/unary values
;
; *****************************************************************************

.DereferenceBinary		
		ldm 	r0,r10,#esReference2 		; do the second one first
		ldm 	r1,r10,#esValue2 			
		skz 	r0 							; if a reference.
		ldm 	r1,r1,#0 					; dereference it.
		stm 	r1,r10,#esValue2			; write back
		stm 	r14,r10,#esReference2 		; clear reference flag
		;
.DereferenceUnary		
		ldm 	r0,r10,#esReference1 		; return if not reference.
		sknz 	r0
		ret
		ldm 	r0,r10,#esValue1 			; dereference it
		ldm 	r0,r0,#0 					
		stm 	r0,r10,#esValue1
		stm 	r14,r10,#esReference1 		; clear reference flag
		ret

; *****************************************************************************
;
;							Handle multi type binaries
;
;	If either is a string check they match and return, otherwise skip the
; 	return by 2.
;
; *****************************************************************************

.MultiTypeDispatch
		ldm 	r0,r10,#esType1 			; add the types together
		ldm 	r1,r10,#esType2
		add 	r0,r1,#0
		add 	link,#2 					; do the skip
		sknz 	r0 							; if either is a string
		ret
		;									; *one* at least is a string
		push 	link
		sknz 	r1 							; check type 2 string
		jmp 	#TypeMismatchError
		ldm 	r0,r10,#esType1 			; check type 1 string
		sknz 	r0
		jmp 	#TypeMismatchError
		pop 	link
		sub 	link,#2 					; unpick the skip
		ret		
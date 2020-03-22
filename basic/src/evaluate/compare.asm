; *****************************************************************************
; *****************************************************************************
;
;		Name:		compare.asm
;		Purpose:	Comparison functions
;		Created:	4th March 2020
;		Reviewed: 	17th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;							Equality check
;
; *****************************************************************************

.BinaryOp_NotEqual		;; [<>]
		push 	link
		jsr 	#MultiTypeDispatch
		jmp 	#_BNEString
		jsr 	#CheckIntDereference
		ldm 	r0,r10,#esValue1 			; compare two values
		ldm 	r1,r10,#esValue2 			
		xor 	r0,r1,#0 					; 0 if the same
._BNEReturn		
		skz 	r0 							; convert non zero to -1
		mov 	r0,#-1
		stm 	r0,r10,#esValue1
		pop 	link
		ret

._BNEString
		jsr 	#CompareStrings 			; do the string comparison
		jmp 	#_BNEReturn 				; 0 if equal, -1 or 1 if different

; *****************************************************************************
;
;							Greater-Equal check
;
; *****************************************************************************

.BinaryOp_GreaterEqual	;; [>=]
		push 	link
		jsr 	#MultiTypeDispatch
		jmp 	#_BGEString
		jsr 	#CheckIntDereference
		ldm 	r0,r10,#esValue1 			; get 2 values
		ldm 	r1,r10,#esValue2 			
		;
.BinaryCompare		
		add 	r0,#$8000					; fix for unsigned comparison
		add 	r1,#$8000
		;
		sub 	r0,r1,#0 					; compare unsigned
		clr 	r0 						
		sklt
		mov 	r0,#-1
		stm 	r0,r10,#esValue1
		pop 	link
		ret

._BGEString
		jsr 	#CompareStrings 			; do the string comparison
		skm 	r0 							; if >= 0
		jmp 	#_BGEReturnTrue
._BGEReturnFalse
		stm 	r14,r10,#esValue1 			; return false value
		pop 	link
		ret
._BGEReturnTrue
		mov 	r0,#-1
		stm 	r0,r10,#esValue1 			; return true value
		pop 	link
		ret


; *****************************************************************************
;
;							Less-Equal check
;
; *****************************************************************************

.BinaryOp_LessEqual	;; [<=]
		push 	link
		jsr 	#MultiTypeDispatch
		jmp 	#_BLEString
		jsr 	#CheckIntDereference
		ldm 	r1,r10,#esValue1 			; get 2 values other way round
		ldm 	r0,r10,#esValue2 			
		jmp 	#BinaryCompare

._BLEString
		jsr 	#CompareStrings 			; do the string comparison
		sknz 	r0 							; if = 0 true
		jmp 	#_BGEReturnTrue
		skp 	r0 							; if < 0 true
		jmp 	#_BGEReturnTrue
		jmp 	#_BGEReturnFalse

; *****************************************************************************
;
;								Reverse tests
;
; *****************************************************************************

.BinaryOp_Equal		;; [=]
		push 	link
		jsr 	#BinaryOp_NotEqual
.ReverseResult		
		ldm 	r0,r10,#esValue1
		xor 	r0,#$FFFF
		stm 	r0,r10,#esValue1
		pop 	link
		ret

.BinaryOp_Greater	;; [>]
		push 	link
		jsr 	#BinaryOp_LessEqual
		jmp 	#ReverseResult

.BinaryOp_Less	;; [<]
		push 	link
		jsr 	#BinaryOp_GreaterEqual
		jmp 	#ReverseResult

; *****************************************************************************
;
;					Compare two strings return -ve 0 +ve in R0
;
; *****************************************************************************

.CompareStrings
		stm 	r14,r10,#esType1 			; we're going to return an integer.
		;
		ldm 	r1,r10,#esValue1 			; r1, r2 are the two strings.
		ldm 	r2,r10,#esValue2
		ldm 	r3,r1,#0 					; get the two lengths
		ldm 	r4,r2,#0
		mov 	r5,r3,#0 					; put the shortest length into R5
		sub 	r5,r4,#0
		skm 	r5 							; skip if r3 < r4
		mov 	r3,r4,#0 					; r4 -> r3
		;
		;		Convert characters to match to words to match
		;
		inc 	r3
		ror 	r3,#1
		and 	r3,#$7FFF
		;
		;		Compare R3 words word reversed - so the first character is more significants
		;
._CSLLoop
		sknz 	r3 							; more to compare ?
		jmp 	#_CSLStartMatch 			; if not, the first n or n+1 chars match.
		dec 	r3 							; dec count to check
		inc 	r1 							; pre-increment as lengths first
		inc 	r2		
		ldm 	r0,r1,#0 					; get chars
		ldm 	r4,r2,#0
		ror 	r0,#8 						; byte swap so MSBs are more significant
		ror 	r4,#8
		sub 	r0,r4,#0 					; calculate the difference.
		sknz 	r0 							; if != 0 we have found a difference.
		jmp 	#_CSLLoop
		ret
		;
		;		The first minimum length characters match. So the outcome is decided by
		;		length - the longest length is higher, or 0 if the same
		;
._CSLStartMatch		
		mov 	r0,r5,#0
		ret


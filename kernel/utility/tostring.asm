; *****************************************************************************
; *****************************************************************************
;
;		Name:		tostring.asm
;		Purpose:	Convert integer to string
;		Created:	8th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;						Integer to String conversion. 
;
;	Converts a 16 bit integer in R0 to a string. R1 is the format ; the
;	low byte is the base, which is 2-16. If bit 15 is set it is done signed
;	otherwise it is done unsigned. 
;
;	It returns in R0 the address of a buffer contained a packed ASCIIZ 
;	representation of the string which OSPrintString() can print straight
;	off.
;
; *****************************************************************************

.OSXIntToStr
		push 	r1,r2,r3,r4,link
		;
		mov 	r2,#convBuffer 				; point R2 to the buffer
		stm 	r14,r2,#0 					; erase the length byte.
		stm 	r14,r2,#1 					; erase first character 
		;
		skm 	r1 							; - format ?
		jmp 	#_OSIsNotNegative
		skm 	r0 							; do - check 
		jmp 	#_OSISNotNegative
		mov 	r3,#'-' 					; write the - in the first slot LSB
		stm 	r3,r2,#1
		mov 	r3,#1 						; make the length now 1
		stm 	r3,r2,#0
		xor 	r0,#$FFFF 					; make R0 +ve.
		inc 	r0
._OSISNotNegative		
		and 	r1,#$001F 					; extract the base from the format, put in R3.
		mov 	r3,r1,#0
		jsr 	#_OSISRecurse 				; divide recursively.
		mov 	r0,#convBuffer 				; return conversion buffer address.
		pop 	r1,r2,r3,r4,link
		ret

._OSISRecurse
		push 	r1,link
		mov 	r1,r3,#0 					; R0 = value, R1 = base.
		jsr 	#OSUDivide16 				; divide by base. Result in R0, Modulus in R1
		skz 	r0 							; if result is non zero recurse
		jsr 	#_OSISRecurse
		sub 	r1,#10 						; convert back to ASCII
		skm 	r1
		add 	r1,#7
		add 	r1,#58
		;
		ldm 	r0,r2,#0 					; get current length
		ror 	r0,#1 						; bit 0->bit 15
		skp 	r0 							; if the odd characters, byte swap
		ror 	r1,#8
		;
		and 	r0,#$7FFF 					; divided length by 2, add to conv Buffer
		add 	r0,#convBuffer+1 			; and skip length -> current entry address
		ldm 	r4,r0,#0 					; write into buffer
		add 	r4,r1,#0
		stm 	r4,r0,#0
		stm 	r14,r0,#1 					; clear following
		ldm 	r0,r2,#0 					; bump count.
		inc 	r0
		stm 	r0,r2,#0
		pop 	r1,link						; exit
		ret


; *****************************************************************************
; *****************************************************************************
;
;		Name:		divide.asm
;		Purpose:	Integer Division (16 bit)
;		Created:	8th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;		Unsigned 16 bit divide of R0/R1. Result in R0, Remainder in R1
;
; *****************************************************************************

.OSXUDivide16
		push 	r2,r3,r4
		clr 	r2 								; R0 = Q R1 = M R2 = A
		mov 	r3,#16 							; pass through 16 times.
._OSXUDLoop1	
		;
		;		Shift AQ left
		;
		add 	r2,r2,#0 						; shift A left
		add 	r0,r0,#0 						; shift Q left
		adc 	r2,#0 							; add the carry from Q shift into A		
		;
		;		Check A-M >= 0, if so save in A and set Q bit 0.
		;
		mov 	r4,r2,#0 						; calculate A-M
		sub 	r4,r1,#0
		sklt									; if >= (carry flag)
		mov 	r2,r4,#0 						; update A with the result
		sklt
		inc 	r0 								; and set Q bit 0.
		;
		dec 	r3 								; done 16 iterations
		skz 	r3
		jmp 	#_OSXUDLoop1
		;
		mov 	r1,r2,#0 						; put the remainder in R1.
		pop 	r2,r3,r4 	
		ret

; *****************************************************************************
;
;		Signed 16 bit divide of R0/R1. Result in R0,Remainder in R1.
;
; *****************************************************************************

.OSXSDivide16
		push 	r2,r3,link

		mov 	r3,r0,#0 						; XOR the values into R3. If bit 15 set result is signed
		xor 	r3,r1,#0

		clr 	r2 								; abs value of R0.
		sub 	r2,r0,#0
		skp 	r0
		mov 	r0,r2,#0

		clr 	r2 								; abs value of R1.
		sub 	r2,r1,#0
		skp 	r1
		mov 	r1,r2,#0

		jsr 	#OSXUDivide16 					; do the unsigned divide.

		clr 	r2 								; calculate -answer
		sub 	r2,r0,#0
		skp 	r3 								; update sign if result signed.
		mov 	r0,r2,#0

		pop 	r2,r3,link
		ret
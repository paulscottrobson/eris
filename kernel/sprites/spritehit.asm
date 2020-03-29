; *****************************************************************************
; *****************************************************************************
;
;		Name:		spritehit.asm
;		Purpose:	Sprite Collision code
;		Created:	29th March 2020
;		Reviewed: 	TODO
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;			Check if sprite R0 and R1 collide within a box size <= R2
;
;						 Return R0 0 or -1,or 1 if error
;
; *****************************************************************************

.OSXSpriteCollision
		push 	r1,r2,r3,r4,r5,link


		mov 	r3,r2,#0 					; validate box size 0..15
		and 	r3,#$FFF0
		skz 	r3
		jmp 	#_OSXSCFail
		inc 	r2 							; so we can use < rather than <=

		ldm 	r4,#spriteCount 			; check sprite numbers.
		mov 	r3,r0,#0
		sub 	r3,r4,#0
		sklt
		jmp 	#_OSXSCFail
		mov 	r3,r1,#0
		sub 	r3,r4,#0
		sklt
		jmp 	#_OSXSCFail


		ldm 	r4,#spriteAddress 			; convert sprite # to addresses
		mult 	r0,#spriteRecordSize
		add 	r0,r4,#0
		mult 	r1,#spriteRecordSize
		add 	r1,r4,#0

		ldm 	r3,r0,#spStatus 			; check both are actually live.
		sknz 	r3
		jmp 	#_OSXSCNoCollide
		ldm 	r3,r1,#spStatus
		sknz 	r3
		jmp 	#_OSXSCNoCollide

		jsr 	#_OSXSCCheck 				; check x return lt on subraction
		sklt
		jmp 	#_OSXSCNoCollide

		inc 	r0 							; bump the pointer, so the same routine checks Y
		inc 	r1
		jsr 	#_OSXSCCheck 				; check x return lt on subraction
		sklt
		jmp 	#_OSXSCNoCollide

		mov 	r0,#-1 						; return -1
		skz 	r14

._OSXSCNoCollide
		clr 	r0 							; return 0
		skz 	r14
._OSXSCFail
		mov 	r0,#1 						; return error code
._OSXSCExit
		pop 	r1,r2,r3,r4,r5,link
		ret
;
;		Checks the collision distance between R0.x and R1.x is < R2, though R0 and R1
;		can point at Y. It's a bit of a hack.
;
._OSXSCCheck
		ldm 	r3,r0,#spNewX				; new R0.X in R3
		mov 	r5,r3,#0 					; if it is &1000 e.g. no change
		xor 	r5,#$1000
		sknz 	r5
		ldm 	r3,r0,#spX 					; load in the changed value

		ldm 	r4,r1,#spNewX				; new R1.X in R3
		mov 	r5,r4,#0 					; if it is &1000 e.g. no change
		xor 	r5,#$1000
		sknz 	r5
		ldm 	r4,r1,#spX 					; load in the changed value

		sub 	r3,r4,#0 					; calculate absolute difference
		skm 	r3
		jmp 	#_OSXNoAbs
		xor 	r3,#$FFFF
		inc 	r3
._OSXNoAbs
		sub 	r3,r2,#0 					; subtract box and return result in carry.
		ret		
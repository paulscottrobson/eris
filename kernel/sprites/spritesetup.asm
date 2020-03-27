; *****************************************************************************
; *****************************************************************************
;
;		Name:		spritesetup.asm
;		Purpose:	Set up sprites
;		Created:	26th March 2020
;		Reviewed: 	TODO
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;			Disable all sprites and reset everything to default values
;
; *****************************************************************************

.OSXSpriteReset
		push 	r0,r1
		stm 	r14,#spritesEnabled
		;
		ldm 	r0,#spriteAddress 			; area to clear
		ldm 	r1,#spriteCount 			; bytes to clear = sprites * recsize
		mult 	r1,#spriteRecordSize 		
._OSXSRClear		
		stm 	r14,r0,#0
		inc 	r0
		dec 	r1
		skz 	r1
		jmp 	#_OSXSRClear
		pop 	r0,r1
		jmp 	#OSIResetStatus

; *****************************************************************************
;
;		Reset sprite status. Clear all update flags in the status bit
;		and set all the 'new' values to $FFFF
;
; *****************************************************************************

.OSIResetStatus
		push 	r0,r1,r2
		ldm 	r2,#spriteAddress 			; area to initialise
		ldm 	r1,#spriteCount 			; number to initialise
._OSIRSLoop
		ldm 	r0,r2,#spStatus 			; clear all the status bits (bit 15)
		and 	r0,#$7FFF
		stm 	r0,r2,#spStatus
		;
		mov 	r0,#$1000 					; and set all the new values to $1000
		stm 	r0,r2,#spNewX
		stm 	r0,r2,#spNewY
		stm 	r0,r2,#spNewStatus
		add 	r2,#spriteRecordSize 		; do all records
		dec 	r1
		skz 	r1
		jmp 	#_OSIRSLoop
		pop 	r0,r1,r2
		ret

; *****************************************************************************
;
;						Select sprite R0. Return 0 if okay
;
; *****************************************************************************

.OSXSpriteSelect
		push 	r1,r2
		mov 	r2,r0,#0 					; put number in R2
		ldm 	r1,#spriteCount 			; check it is < sprite count
		sub 	r0,r1,#0 					; clear R0 in cases.
		mov 	r0,#1 						; return error if so.
		sklt
		jmp 	#_OSXSSExit
		stm 	r15,#spritesEnabled 		; sprites are enabled
		mult 	r2,#spriteRecordSize 		; now an offset 
		ldm 	r0,#spriteAddress 			; add base address
		add 	r0,r2,#0
		stm 	r0,#spriteSelect 			; saves exit
		clr 	r0 							; return 0
._OSXSSExit		
		pop 	r1,r2
		ret


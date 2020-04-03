; *****************************************************************************
; *****************************************************************************
;
;		Name:		spriteaccess.asm
;		Purpose:	Sprite Modifier Code
;		Created:	26th March 2020
;		Reviewed: 	TODO
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

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

; *****************************************************************************
;
;							Move current sprite to X,Y
;
; *****************************************************************************

.OSXSpriteMove
		push 	r2 							; save temp register
		;
		mov 	r2,r0,#0					; -32 ... width + 32
		add 	r2,#32
		sub 	r2,#pixelWidth+64
		sklt
		jmp 	#_OSXSMFail
		mov 	r2,r1,#0 					; -32 ... height + 32
		add 	r2,#32
		sub 	r2,#pixelHeight+64
		sklt
		jmp 	#_OSXSMFail
		;
		ldm 	r2,#spriteSelect 			; update value
		stm 	r0,r2,#spNewX
		stm 	r1,r2,#spNewY	
		clr 	r0 							; return zero
		skz 	r0 
._OSXSMFail
		mov 	r0,#1
		pop 	r2
		ret

; *****************************************************************************
;
;								Set image to R0
;
; *****************************************************************************

.OSXSpriteSetImage		
		push 	r1,r2,link
		mov 	r1,r0,#0 					; image -> R1
		ldm 	r2,#spriteImageCount 		; check image# < count
		sub 	r0,r2,#0 			
		sklt
		jmp 	#_OSXSSIFail

		mov		r0,#$FF00 					; mask
		jsr 	#OSIUpdateStatus 
		clr 	r0 							; exit with zero.
		skz 	r0
._OSXSSIFail
		mov 	r0,#1
		pop 	r1,r2,link
		ret

; *****************************************************************************
;
;								Set orientation to 0-3
;
; *****************************************************************************

.OSXSpriteSetOrientation
		push 	r1,link
		mov 	r1,r0,#0 					; colour -> R1
		sub 	r0,#4 						; check 0-3
		sklt
		jmp 	#_OSXSSOFail
		;
		ror 	r1,#3 						; put into correct place in word
		mov 	r0,#$9FFF 					; mask
		jsr 	#OSIUpdateStatus 
		clr 	r0 							; exit with zero.
		skz 	r0
._OSXSSOFail
		mov 	r0,#1
		pop 	r1,link
		ret

; *****************************************************************************
;
;								Set size to 1-2
;
; *****************************************************************************

.OSXSpriteSetSize
		push 	r1,link
		dec 	r0 							; now 0-1
		mov 	r1,r0,#0 					; size-1 -> R1
		and 	r0,#$FFFE 					; exit if 0 or 1
		skz 	r0
		jmp 	#_OSXSSSFail 				; set size fail.

		ror 	r1,#4 						; put into bit 12
		mov 	r0,#$EFFF 					; mask
		jsr 	#OSIUpdateStatus

		clr 	r0 							; exit with zero.
		skz 	r0
._OSXSSSFail
		mov 	r0,#1
		pop 	r1,link
		ret

; *****************************************************************************
;
;						  Update sprite colour to R0
;
; *****************************************************************************

.OSXSpriteSetColour
		push 	r1,link
		mov 	r1,r0,#0 					; colour -> R1
		sub 	r0,#16 						; check 0-15
		sklt
		jmp 	#_OSXSSCFail
		;
		ror 	r1,#8 						; put into correct place in word
		mov 	r0,#$F0FF 					; mask
		jsr 	#OSIUpdateStatus 
		clr 	r0 							; exit with zero.
		skz 	r0
._OSXSSCFail
		mov 	r0,#1
		pop 	r1,link
		ret

; *****************************************************************************
;
;								Kill off a sprite
;
; *****************************************************************************

.OSXSpriteKill
		push 	r1,link
		clr 	r0
		clr 	r1
		jsr 	#OSIUpdateStatus 
		pop 	r1,link
		ret

; *****************************************************************************
;
;					   Update status with value R1 mask R0
;
;	Required because the new Status may already have changed from the no 
;	change value.
;
; *****************************************************************************

.OSIUpdateStatus
		push 	r2,r3
		ldm 	r2,#spriteSelect 			; currently selected sprite
		ldm 	r3,r2,#spNewStatus 			; has the new status changed, e.g. new value set.
		xor 	r3,#spNoChange
		skz 	r3  						; if R3 is zero copy the old status to the new
		jmp 	#_OSIUSChanged 				; one as a basis.
		ldm 	r3,r2,#spStatus
		stm 	r3,r2,#spNewStatus
._OSIUSChanged		
		ldm 	r3,r2,#spNewStatus 			; get the new status
		and 	r3,r0,#0 					; and with mask
		add 	r3,r1,#0 					; add in data
		stm 	r3,r2,#spNewStatus 			; write back
		pop 	r2,r3
		ret

; *****************************************************************************
;
;					Get sprite Element R1 from Sprite # R0
;
; *****************************************************************************

.OSXGetSpriteInfo
		push 	r1,r2
		mult 	r0,#spriteRecordSize 		; make point to record
		ldm 	r2,#spriteAddress
		add 	r2,r0,#0  					; element in record -> R1
		add 	r2,r1,#0 			
		;
		ldm 	r1,r2,#spNewX-spX 			; read the updated value.
		mov 	r0,r1,#0 					; put in R0.
		xor 	r1,#spNoChange 				; if it is no change,
		sknz 	r1
		ldm 	r0,r2,#0 					; read current value
		pop 	r1,r2
		ret
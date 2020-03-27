; *****************************************************************************
; *****************************************************************************
;
;		Name:		spriteupdate.asm
;		Purpose:	Sprite Update code
;		Created:	26th March 2020
;		Reviewed: 	TODO
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;							Update all sprites
;
; *****************************************************************************

.OSISpriteUpdate
		push 	r0,r1,r2,r3,r4,link
		jsr 	#SpritePhase1 				; phase 1 ; erase and check what we redraw
		jsr 	#SpritePhase2 				; phase 2 ; redraw
		jsr 	#OSIResetStatus 			; phase 3 is reset everything for next time
		pop 	r0,r1,r2,r3,r4,link
		ret

; *****************************************************************************
;
;			 Sprite update Phase 1 - identify what needs redrawing
;
; *****************************************************************************

.SpritePhase1
		push 	link
		ldm 	r1,#spriteAddress 			; current sprite being checked
		ldm 	r2,#spriteCount 			; count to check
._SP1Loop
		;
		;		Check sprite is active and one of the new values has changed
		;
		ldm 	r4,r1,#spNewStatus			; check status, if zero go to next
		sknz 	r4
		jmp 	#_SP1Next
		ldm 	r0,r1,#spNewX 				; check if X,Y status has changed from $4000
		ldm 	r3,r1,#spNewY
		add 	r0,r3,#0 					; and them together. If the result is changed.
		add 	r0,r4,#0
		xor 	r0,#$C000 					; will be zero if $C000
		sknz 	r0
		jmp 	#_SP1Next
		;
		;		Try to erase old sprite.
		;	
		clr 	r0							; erase old sprite.
		jsr 	#SpriteDraw
		skz 	r0 							; if it wasn't on screen then go to the update
		jmp 	#_SP1Update 				; it doesn't matter about offscreen collisions.

		;
		;		TODO look for sprites this might collide with and set their redraw bits
		;

		;
		;		Update sprites setting redraw bit if new status
		;
._SP1Update
		ldm 	r3,r1,#spNewX 				; update X
		mov 	r4,r3,#0
		xor 	r4,#$4000
		skz 	r4
		stm 	r3,r1,#spX

		ldm 	r3,r1,#spNewY 				; update Y
		mov 	r4,r3,#0
		xor 	r4,#$4000
		skz 	r4
		stm 	r3,r1,#spY

		ldm 	r3,r1,#spNewStatus 			; update Status - sets redraw bit.
		mov 	r4,r3,#0
		xor 	r4,#$4000
		sknz 	r4 							; we get the old value if it was $4000
		ldm 	r3,r1,#spStatus 			; because we set it anyway.
		skm 	r3 							; already set, no set it and write back
		add 	r3,#$8000
		stm 	r3,r1,#spStatus

._SP1Next		
		add 	r1,#spriteRecordSize 		; do them all
		dec 	r2
		skz 	r2
		jmp 	#_SP1Loop
		pop 	link
		ret

; *****************************************************************************
;
;		Sprite update Phase 2 - redraw those marked as needing redrawing
;
; *****************************************************************************

.SpritePhase2
		push 	link
		ldm 	r1,#spriteAddress 			; current sprite being checked
		ldm 	r2,#spriteCount 			; count to check
._SP2Loop
		ldm 	r0,r1,#spStatus 			; skip if not set for repaint
		skm 	r0
		jmp 	#_SP2Next
		ror 	r0,#8 						; get sprite colour
		and 	r0,#15
		jsr 	#SpriteDraw 				; and redraw
._SP2Next		
		add 	r1,#spriteRecordSize 		; do them all
		dec 	r2
		skz 	r2
		jmp 	#_SP2Loop
		pop 	link
		ret

; *****************************************************************************
;
;		 Draw Sprite at R1 in Colour R0. Return non-zero if off screen
;
; *****************************************************************************

.SpriteDraw
		push 	r2,r3,link
		mov 	r3,r0,#0 					; colour into R3
		mov 	r0,#1 						; return value if offscreen
		;
		ldm 	r2,r1,#spX 					; must be -8 .. 328 and -8 .. 248
		add 	r2,#8 						; as orientated on centre
		sub 	r2,#pixelWidth+16
		sklt
		jmp 	#_SDExit
		ldm		r2,r1,#spY
		add 	r2,#8
		sub 	r2,#pixelHeight+16
		sklt
		jmp 	#_SDExit
		;
		jsr 	#OSWaitBlitter 				; wait for blitter
		;
		ldm 	r2,r1,#spX 					; set X and Y positions allowing for offset
		sub 	r2,#8 
		stm 	r2,#blitterX
		ldm 	r2,r1,#spY 
		sub 	r2,#8
		stm 	r2,#blitterY
		;
		ldm 	r0,r1,#spStatus 			; get the graphic to draw
		and 	r0,#$00FF
		ror 	r0,#12 						; x 16
		ldm 	r2,#spriteImageMemory 		; add to image memory pointer
		add 	r0,r2,#0
		stm 	r0,#blitterData 			; data source
		;
		ldm 	r0,#spriteRotate 			; sprite colour rotation
		ror 	r3,r0,#0 					; do the rotation
		ldm 	r0,#spriteMask 				; get the mask
		ror 	r0,#8 						; put into MSB
		add 	r0,r3,#0 					; add the colour
		stm 	r0,#blitterCMask
		;
		ldm 	r0,r1,#spStatus 			; get status bits
		and 	r0,#$6000 					; get flip bits
		add 	r0,#$10 					; 16 rows to draw
		stm 	r0,#blitterCmd

		clr 	r0 							; on screen return 0.
._SDExit
		pop 	r2,r3,link
		ret		
				
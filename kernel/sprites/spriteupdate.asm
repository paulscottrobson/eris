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
		jsr 	#SpritePhase1

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
		ldm 	r2,#spriteCount 			; count to checl
._SP1Loop
		ldm 	r4,r1,#spNewStatus			; check status, if zero go to next
		sknz 	r4
		jmp 	#_SP1Next
		ldm 	r0,r1,#spNewX 				; check if X,Y status has changed from $FFFF
		ldm 	r3,r1,#spNewY
		and 	r0,r3,#0 					; and them together. If the result is changed.
		and 	r0,r4,#0
		inc 	r0 							; will be zero if $FFFF
		sknz 	r0
		jmp 	#_SP1Next
		;
		ldm 	r0,r1,#spStatus 			; set the status flag, which means we must redraw it.
		skm 	r4 							; might be already set
		add 	r0,#$8000
		stm 	r0,r1,#spStatus
		clr 	r0							; erase old sprite.
		jsr 	#SpriteDraw
		skz 	r0 							; if it wasn't on screen then go to the next one.
		jmp 	#_SP1Next

		;
		;		TODO look for sprites this might collide with and set their redraw bits
		;

._SP1Next		
		add 	r1,#spriteRecordSize 		; do them all
		dec 	r2
		skz 	r2
		jmp 	#_SP1Loop
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
		mov 	r0,r1,#spStatus 			; get status bits
		and 	r0,#$6000 					; get flip bits
		add 	r0,#$10 					; 16 rows to draw
		stm 	r0,#blitterCmd

		clr 	r0 							; on screen return 0.
._SDExit
		pop 	r2,r3,link
		ret		
				
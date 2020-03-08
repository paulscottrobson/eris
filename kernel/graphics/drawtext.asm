; *****************************************************************************
; *****************************************************************************
;
;		Name:		drawtext.asm
;		Purpose:	Draw character on display
;		Created:	8th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;				As below, but draw background using bits 12..15
;
; *****************************************************************************

.OSXDrawSolidCharacter
		push 	r0,r1,link
		mov 	r1,r0,#0 					; save 
		and 	r0,#$F000 					; isolate background
		ror 	r0,#4 						; put into foreground slot
		add 	r0,#$A0 					; reverse-space
		jsr 	#OSDrawCharacter 			; draw background
		mov 	r0,r1,#0 					; get old back
		jsr 	#OSDrawCharacter 			; draw foreground
		pop 	r0,r1,link
		ret

; *****************************************************************************
;
;				  Draw character R0 at graphics position/colour
;
;					Bits 0..6 	Character code
;					Bit  7 		Invert flag
;					Bits 8..11 	Colour
;					Bits 12..15 Ignored
;
; *****************************************************************************

.OSXDrawCharacter
		push 	r0,r1,r2,r3,link
		jsr 	#OSWaitBlitter				; wait for blitter
		;

		ldm 	r1,#xGraphic 				; set graphic position.
		stm 	r1,#blitterX
		ldm 	r1,#yGraphic
		stm 	r1,#blitterY

		ldm 	r1,#colourMask 				; get the current mask in bits 0..7
		mov 	r2,r0,#0 					; get colour out of bits 8..11
		and 	r2,#$0F00 
		add 	r2,r1,#0 					; compose the two.
		ror 	r2,#8 						; colour in bits 0..3, mask in bits 8..11
		stm 	r2,#blitterCMask 			; that's the colour mask
		;
		clr 	r2 							; R2 is what we xor the data with.
		ror 	r0,#8 						; bit 15 is the MSB of the character code.
		skp 	r0
		dec 	r2 							; if it is set make R2 = $FFFF
		;
		ror 	r0,#8-2 					; put back in position and multiply by 4 
		and 	r0,#$01FC 					; mask out offset into the font table
		sub 	r0,#32*4 					; allow for space
		skp 	r0 							; space if 0..31
		clr 	r0
		mov 	r1,#FontData 				; R1 now points to the font data
		add 	r1,r0,#0
		;
		mov 	r3,#fontBuffer 				; R3 is where it is copied to.
		stm 	r3,#blitterData 			; which is also the blitter data source.
._OSDCExpand
		ldm 	r0,r1,#0 				 	; LSB first
		xor 	r0,r2,#0
		and 	r0,#$00FF
		ror 	r0,#8
		stm 	r0,r3,#0
		ldm 	r0,r1,#0 					; then MSB
		xor 	r0,r2,#0
		and 	r0,#$FF00
		stm 	r0,r3,#1
		;
		add 	r3,#2 						; bump R3
		inc 	r1 							; increment source pointer
		mov 	r0,r3,#0 					; check at end of font buffer
		xor 	r0,#fontBuffer+8
		skz		r0
		jmp 	#_OSDCExpand
		mov 	r0,#8 						; and write out 8 bytes, no background
		stm 	r0,#blitterCmd
		pop 	r0,r1,r2,r3,link
		ret

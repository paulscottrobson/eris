; *****************************************************************************
; *****************************************************************************
;
;		Name:		drawtext.asm
;		Purpose:	Draw character on display
;		Created:	8th March 2020
;		Reviewed: 	16th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;			  As below, but draw background using bits 12..15 colour
;
; *****************************************************************************

.OSXDrawSolidCharacter
		push 	r0,r1,link
		mov 	r1,r0,#0 					; save draw character
		and 	r0,#$F000 					; isolate background bits 12..15
		ror 	r0,#4 						; put into foreground slot 8..11
		add 	r0,#$7F 					; reverse-space solid block
		jsr 	#OSDrawCharacter 			; draw background solid block
		mov 	r0,r1,#0 					; get old character/colour back
		jsr 	#OSDrawCharacter 			; draw foreground over it
		pop 	r0,r1,link
		ret

; *****************************************************************************
;
;				  Draw character R0 at graphics position/colour
;
;					Bits 0..7 	Character code
;					Bits 8..11 	Colour
;					Bits 12..15 Ignored
;
; *****************************************************************************

.OSXDrawCharacter
		push 	r0,r1,r2,link
		mov 	r2,r0,#0 					; save in R2 to get colour out of bits 8..11
		and 	r0,#$FF 					; mask character code out of bits 0..7
		sub 	r0,#33 						; skip if <= 33 don't draw spaces either.
		skp 	r0
		jmp 	#_OSDCExit

		jsr 	#OSWaitBlitter				; wait for blitter
		;
		ldm 	r1,#xGraphic 				; set graphic position.
		stm 	r1,#blitterX
		ldm 	r1,#yGraphic
		stm 	r1,#blitterY

		ldm 	r1,#colourMask 				; get the current mask in bits 0..7
		and 	r2,#$0F00  					; mask the colour out of bits 8..11 of character
		add 	r2,r1,#0 					; compose the two.
		ror 	r2,#8 						; colour in bits 0..3, mask in bits 8..15
		stm 	r2,#blitterCMask 			; that's the colour.high mask.low
		;
		ror 	r0,#13 						; multiply (char# - 33) result by 8 the character height
		mov 	r1,#FontData+8 				; make R1 point to the font data. +8 because of space.
		add 	r1,r0,#0
		stm 	r1,#blitterData 			; which is also the blitter data source.
		mov 	r0,#8 						; and write out 8 bytes, no background
		stm 	r0,#blitterCmd
._OSDCExit		
		pop 	r0,r1,r2,link
		ret


; *****************************************************************************
; *****************************************************************************
;
;		Name:		drawtext.asm
;		Purpose:	Draw character on display
;		Created:	8th March 2020
;		Reviewed: 	TODO
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
		add 	r0,#$7F 					; reverse-space
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
		push 	r0,r1,r2,link
		mov 	r2,r0,#0 					; save in R2 to get colour out of bits 8..11
		and 	r0,#$7F 					; mask character code
		sub 	r0,#33 						; skip if <= 33
		skp 	r0
		jmp 	#_OSDCExit

		jsr 	#OSWaitBlitter				; wait for blitter
		;
		ldm 	r1,#xGraphic 				; set graphic position.
		stm 	r1,#blitterX
		ldm 	r1,#yGraphic
		stm 	r1,#blitterY

		ldm 	r1,#colourMask 				; get the current mask in bits 0..7
		and 	r2,#$0F00  					; mask the colour out.
		add 	r2,r1,#0 					; compose the two.
		ror 	r2,#8 						; colour in bits 0..3, mask in bits 8..11
		stm 	r2,#blitterCMask 			; that's the colour mask
		;
		ror 	r0,#13 						; multiply char# - 33 * 8
		mov 	r1,#FontData+8 				; R1 now points to the font data
		add 	r1,r0,#0
		stm 	r1,#blitterData 			; which is also the blitter data source.
		mov 	r0,#8 						; and write out 8 bytes, no background
		stm 	r0,#blitterCmd
._OSDCExit		
		pop 	r0,r1,r2,link
		ret


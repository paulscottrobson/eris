; *****************************************************************************
; *****************************************************************************
;
;		Name:		mode.asm
;		Purpose:	Mode setting
;		Created:	17th March 2020
;		Reviewed: 	TODO
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;				Set Mode to R0. High is the number of sprite planes
;				Low is the number of background planes
;				Clear the display
;
; *****************************************************************************
;
;		This sets up three values - suppose there are 2 sprite and 3 bgr planes
;
;			(i) the mask for the background 		00111
;			(ii) the mask for the sprite layer 		11000
;			(iii) the rotate right value to convert 
;					a colour to a sprite colour 	13 (decimal, e.g. 3 left)
;
; *****************************************************************************

.OSXSetPlanes
		push 	r0,r1,r2,r3,link
		mov 	r1,r0,#0					; save mode in R1
		and 	r0,#$00FF					; the number of planes in the background
		;
		xor 	r0,#15 						; 16-x is the number of rotations to the sprite plane
		inc 	r0
		and 	r0,#15
		stm 	r0,#spriteRotate 			
		;
		mov 	r2,#1						; 2^ this value is the number of colours in the background plane
		ror 	r2,r0,#0					; 1 fewer is the mask
		and 	r2,#$FF						; if plane empty
		skz 	r2
		dec 	r2
		stm 	r2,#colourMask
		;
		and		r1,#$FF00					; number of planes in sprite.
		ror 	r1,#8 						
		xor 	r1,#15
		inc 	r1 							; rotates for the sprite plane
		mov 	r2,#1
		ror		r2,r1,#0					; this is the number of colours in the sprite plane
		and 	r2,#$FF						; if plane empty
		skz 	r2
		dec 	r2							; this is the mask
		mov 	r3,r2,#0 					; unshifted sprite mask in R3
		ror 	r2,r0,#0					; and this makes it a sprite mask
		stm 	r2,#spriteMask
		;
		;		Set the background palette colours
		;
		ldm 	r0,#colourMask 				; start with colour mask
		sknz 	r0 							; skip if there is no background
		jmp 	#_spSetBgrEnd
._spSetBgrAll
		mov 	r1,r0,#0					; get the colour to update
		and 	r1,#7 						; read the colour to use -> R1
		add 	r1,#_spPaletteTable 		
		ldm 	r1,r1,#0		
		jsr 	#OSSetBackPlanePalette 		; update back palette
		dec 	r0
		skm 	r0
		jmp 	#_spSetBgrAll
		;
._spSetBgrEnd
		;
		;		Set the foreground palette colours
		;
		sknz 	r3 							; is there any foreground colours at all
		jmp 	#_spSetFgrEnd
._spSetFgrAll
		mov 	r0,r3,#0 					; R0 = foreground palette colour.
		mov 	r1,r3,#0
		and 	r1,#7 						; read the colour to use -> R1
		add 	r1,#_spPaletteTable 		
		ldm 	r1,r1,#0		
		jsr 	#OSSetFrontPlanePalette 	; update front palette
		dec 	r3
		skm 	r3
		jmp 	#_spSetFgrAll
._spSetFgrEnd
		;
		;		Erase the whole display using colour 0 mask $FF
		;
		mov 	r0,#$FF00 					
		jsr 	#OSIFillScreen
		;
		pop 	r0,r1,r2,r3,link
		ret
;
;		Palette table default colours for lower 3 bits of any plane
;
._spPaletteTable
		word 	0*16+0*4+0
		word 	0*16+0*4+3
		word 	0*16+3*4+0
		word 	0*16+3*4+3
		word 	3*16+0*4+0
		word 	3*16+0*4+3
		word 	3*16+3*4+0
		word 	3*16+3*4+3

; *****************************************************************************
;
;			Update a palette for background palette R0,BGR R1
;
; *****************************************************************************

.OSXSetBackPlanePalette
		push 	r0,r1,r2
		mov 	r2,r0,#0					; build <colour>:<bgr> in R2
		ror 	r2,#8	
		and 	r1,#$3F 					; mask the colour
		add 	r2,r1,#0 					
		ldm 	r1,#colourMask				; check colour < colourMask+1
		inc 	r1
		sub 	r0,r1,#0
		skge
		stm 	r2,#paletteRegister 		; if so, update the palette register.
		pop 	r0,r1,r2
		ret

; *****************************************************************************
;
;				  Set front plane palette colour R0, BGR R1
;
; *****************************************************************************
;
;		Comments are based on 3 sprite planes, 2 background planes,
;		setting colour 5.
;
.OSXSetFrontPlanePalette
		sknz 	r0 							; you cannot set colour 0, it is transparent.
		ret
		;
		push 	r0,r1,r2,r3
		;
		ldm 	r3,#spriteRotate 			; rotate the colour into position : 101 to be 10100
		ror 	r0,r3,#0 					; then into the upper half of the word (hence the 8)
		;
		ldm 	r2,#spriteMask 				; must be <= sprite mask : this will be 11100 - this is the
		sub 	r2,r0,#0  					; value of the highest colour in this plane (e.g. 7)
		skp 	r2							; e.g largest - required >= 0
		jmp 	#_OSSFPPExit
		;
		ror 	r0,#8 						; put the colour number into the MSB 10100 0000000
		and 	r1,#$3F 					; mask the colour
		add 	r0,r1,#0 					; make the word to write 10100 00bbggrr
		;
		mov 	r2,#1 						; the count to do is 1 << spriteRotate (e.g. 4)
		ror 	r2,r3,#0
		;
		;		So at this point R3 is 4 and R0 is 10100 00bbggrr
		;		
._OSSFPPLoop
		stm 	r0,#paletteRegister 		; set colour
		add 	r0,#$100 					; increment upper byte of colour e.g. colour number -> 10101
		dec 	r2 							; do R3 times so will do 10100 10101 10110 10111
		skz 	r2
		jmp 	#_OSSFPPLoop
._OSSFPPExit
		pop 	r0,r1,r2,r3
		ret

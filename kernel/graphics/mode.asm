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
		push 	r0,r1,r2,link
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
		dec 	r2							; this is thee mask
		ror 	r2,r0,#0					; and this makes it a sprite mask
		stm 	r2,#spriteMask

		mov 	r0,#15 						; do entire palette, both planes.
._spSetPalette
		mov 	r2,r0,#0 					; get palette number
		and 	r2,#7 						; what colour do we want to use
		add 	r2,#_spPaletteTable 		; the address of the colour to write
		ldm 	r2,r2,#0 					; get colour into R2
		mov 	r1,#1 						; write to sprite palette
		jsr 	#OSXSetPalette
		clr 	r1
		jsr 	#OSXSetPalette
		dec 	r0 							; do 255->0
		skm 	r0
		jmp 	#_spSetPalette
		pop 	r0,r1,r2,link
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
;					Update a palette for colour R0. 
;		Plane R1 (0 = background,1 = sprite plane), BGR 2 bit R2
;
; *****************************************************************************

.OSXSetPalette
		skz 	r1  						; don't do sprites
		ret
		push 	r0,r1,r2
		ror 	r0,#8
		add 	r0,r2,#0
		stm 	r0,#paletteRegister 		; write to palette register
		pop 	r0,r1,r2
		ret

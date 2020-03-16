; ***************************************************************************** ; *****************************************************************************
;
;		Name:		clear.asm
;		Purpose:	Screen Erase/Fill Routine
;		Created:	8th March 2020
;		Reviewed: 	TODO
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;									Clear Screen
;
; *****************************************************************************

.OSIClearScreen
		push 	r0,r1,link
		ldm 	r0,#bgrColour 				; build <mask><colour>
		ldm 	r1,#colourMask
		ror 	r1,#8
		add 	r0,r1,#0
		jsr 	#OSIFillScreen
		pop 	r0,r1,link
		ret

; *****************************************************************************
;
;					Fill Screen using colour/mask R1
;
; *****************************************************************************

.OSIFillScreen
		push 	r0,r1,link
		jsr 	#OSWaitBlitter 				; wait for blitter
		stm 	r0,#blitterCMask			; set the blitter mask
		mov 	r0,#_OSFSBar 				; solid bar
		stm 	r0,#blitterData
		mov 	r1,#PixelWidth-16 			; position of first band
._OSIFillLoop		
		jsr 	#OSWaitBlitter 				; wait for blitter
		stm 	r1,#blitterX 				; set position to (x,0)
		stm 	r14,#blitterY
		mov 	r0,#$8000+PixelHeight		; draw bar
		stm 	r0,#blitterCmd
		sub 	r1,#16 						; back 16 till -ve
		skm 	r1
		jmp 	#_OSIFillLoop
		pop 	r0,r1,link
		ret

._OSFSBar									; solid bar for screen filling.
		word 	$FFFF		
; ***************************************************************************** ; *****************************************************************************
;
;		Name:		clear.asm
;		Purpose:	Screen Erase/Fill Routine
;		Created:	28th February 2020
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
		push 	r0,link
		ldm 	r0,#gfxColour 					; get background colour
		ror 	r0,#4
		and 	r0,#$0F
		jsr 	#OSFillScreen 					; fill background
		mov 	r0,#$800F 						; erase foreground to clear.
		jsr 	#OSFillScreen
		pop 	r0,link
		ret

; *****************************************************************************
;
;				Fill screen with R0 (bit 15, plane, bit 0-3 colour)
;
; *****************************************************************************

.OSXFillScreen
		push 	r0,r1,r2,r3,link
		and 	r0,#$800F 						; fix up command
		add 	r0,#$2000 
		mov 	r3,#blitterBase 				; R3 is blitter base address
		jsr 	#OSWaitBlitter					; wait for blitter
		mov 	r1,#_OSXFSSolid 				; write data address out
		stm 	r1,r3,#blitterData-blitterBase
		mov 	r1,#PixelWidth-16 				; R1 is the X position
._OSXFSLoop1
		stm 	r1,r3,#blitterPos-blitterBase 	; set position
		mov 	r2,#PixelHeight >> 4			; R2 is the Y count
._OSXFSLoop2 			
		stm 	r0,r3,#blitterCmd-blitterBase	; draw vertical bar
		dec 	r2
		skz 	r2
		jmp 	#_OSXFSLoop2
		sub 	r1,#16 							; previous column
		skm 	r1
		jmp 	#_OSXFSLoop1
		pop 	r0,r1,r2,r3,link
		ret

._OSXFSSolid
		word 	$FFFF
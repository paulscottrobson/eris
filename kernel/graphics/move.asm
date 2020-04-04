; *****************************************************************************
; *****************************************************************************
;
;		Name:		move.asm
;		Purpose:	Move and Move and Plot
;		Created:	25th March 2020
;		Reviewed: 	TODO
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;								Plot pixel at R0,R1
;
; *****************************************************************************

.OSXPlotPixel
		push 	r0,link
		stm 	r0,#xGraphic
		stm 	r1,#yGraphic
		;
		jsr 	#OSSetInkColourMask 		; set colour/mask, which waits for blitter
		stm 	r0,#blitterX
		stm 	r1,#blitterY
		mov 	r0,#_OSXPPData
		stm	 	r0,#blitterData
		mov 	r0,#1 						; one pixel
		stm 	r0,#blitterCmd
		pop 	r0,link
		ret

._OSXPPData		
		word 	$8000

; *****************************************************************************
;
;						Set Graphic coordinates to R0,R1
;
; *****************************************************************************

.OSXGraphicsMove
		;
		;		After code, jump here to update x,y position
		;
.GraphicsSaveExit
		stm 	r0,#xGraphic
		stm 	r1,#yGraphic
		ret



; *****************************************************************************
; *****************************************************************************
;
;		Name:		frame.asm
;		Purpose:	Draw Rectangular Frame
;		Created:	25th March 2020
;		Reviewed: 	TODO
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;						Draw frame from current to R0,R1
;
; *****************************************************************************

.OSXDrawRectangle
		push 	r0,r1,r2,r3,link
		
		jsr 	#OSSetInkColourMask 		; set colour/mask
		jsr 	#OSIGraphicBoxCoordinates 	; (R0,R1) -> (R2,R3)

		push 	r0,r1
		jsr 	#OSXGraphicsMove
		mov 	r0,r2,#0
		jsr 	#OSXDrawLine 				; top
		mov 	r1,r3,#0
		jsr 	#OSXDrawLine 				; right

		pop 	r0,r1
		jsr 	#OSXGraphicsMove
		mov 	r1,r3,#0 					; left
		jsr 	#OSXDrawLine
		mov 	r0,r2,#0 					; bottom
		jsr 	#OSXDrawLine

		pop 	r0,r1,r2,r3,link
		jmp 	#GraphicsSaveExit
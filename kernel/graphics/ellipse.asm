; *****************************************************************************
; *****************************************************************************
;
;		Name:		ellipse.asm
;		Purpose:	Draw Solid/Frame Ellipse
;		Created:	30th March 2020
;		Reviewed: 	TODO
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;						Common code with a fill flag
;
; *****************************************************************************

.OSXDrawEllipse
		push 	r4
		mov 	r4,#1
		jmp 	#_OSXEllipseCommand
.OSXFillEllipse
		push 	r4
		clr		r4
._OSXEllipseCommand
		push 	r0,r1,r2,r3,r5,r6,r7,r8,r9,r10,link

		jsr 	#OSSetInkColourMask 		; set colour/mask
		jsr 	#OSIGraphicBoxCoordinates 	; (R0,R1) -> (R2,R3) top left/bottom right

		
		add 	r0,r2,#0 					; calculate mid point of ellipse
		ror 	r0,#1 						; -> R0,R1
		and 	r0,#$7FFF
		add 	r1,r3,#0
		ror 	r1,#1
		and 	r1,#$7FFF

		sub 	r2,r0,#0 					; calculate the x and y radii in R2,R3
		sub 	r3,r1,#0

		sknz	r2 							; exit if either radius is zero
		jmp 	#_OSXEllipseExit
		sknz 	r3
		jmp 	#_OSXEllipseExit

		;
		;		we know yR is < 120 and xR < 160. Calculate XR * 256 / YR -> R2
		;		which is the horizontal scalar. (both are > 0)
		;
		push 	r0,r1
		mov 	r0,r2,#0 					
		ror 	r0,#8
		mov 	r1,r3,#0
		jsr 	#OSUDivide16			
		mov 	r2,r0,#0
		pop 	r0,r1
		;
		;		Now in the python code in ellipse.py 
		;
		;		R0,R1: Centre of circle
		;		R2: Horizontal scalar * 256
		;		R3: Radius
		;		R4: 0 if outline, 0 if fill.
		;		R5: X
		; 		R6: Y
		;		R7: ddfX
		;		R8: ddfY
		;		R9: f
		;
		mov 	r9,#1 						; f = 1-Radius
		sub 	r9,r3,#0
		clr 	r7 							; ddfX = 0
		clr 	r8 							; ddfY = -2*radius
		sub 	r8,r3,#0
		sub 	r8,r3,#0
		clr 	r5 							; X = 0
		mov 	r6,r3,#0 					; Y = Radius
		;
		;		Main loop. We put the draw inside the loop so we only do it once
		;
._OSXEllipseLoop
		jsr 	#_OSXDrawAndFlip 			; draw 
		;
		mov 	r10,r5,#0 					; while X < Y
		sub 	r10,r6,#0 
		sklt
		jmp 	#_OSXEllipseExit 			;
		;
		skp 	r9 							; if F > 0
		jmp 	#_OSXEllipseEndF

		dec 	r6 							; Y = Y - 1
		add 	r8,#2 						; ddfY += 2
		add 	r9,r8,#0 					; f += ddfY

._OSXEllipseEndF		
		inc 	r5 							; X = X + 1
		add 	r7,#2 						; ddfX += 2
		add 	r9,r7,#1 					; F = F + ddfX + 1
		jmp 	#_OSXEllipseLoop 			; and go round again.

._OSXEllipseExit
		pop 	r0,r1,r2,r3,r5,r6,r7,r8,r9,r10,link
		pop 	r4
		ret
;
;		Pixel plotter. Draw all 4 quadrants, flipping X and Y and for Y and -Y
;
._OSXDrawAndFlip
		push 	link
		jsr 	#_OSEScaleXDrawAndSwap
		jsr 	#_OSEScaleXDrawAndSwap
		pop 	link
		ret

		break
;
;		Scale X, draw flipped in Y and swap over.
;
._OSEScaleXDrawAndSwap
		push 	link
		push 	r5
		mult 	r5,r2,#0 					; scale X to make it elliptical
		ror 	r5,#8
		and 	r5,#$00FF
		jsr 	#_OSEDrawAndFlipY
		jsr		#_OSEDrawAndFlipY
		pop 	r5
		jsr 	#_OSESwapXY
		pop 	link
		ret
;
;		Swap X and Y
;
._OSESwapXY
		mov 	r10,r5,#0
		mov 	r5,r6,#0
		mov 	r6,r10,#0
		ret
;
;		Draw one line or point pair and do Y = -Y
;
._OSEDrawAndFlipY
		push 	link
		skz 	r4
		jsr 	#_OSEDrawPixelPair
		sknz 	r4
		jsr 	#_OSEDrawLine
		xor 	r6,#$FFFF 					; Y = -Y
		inc 	r6
		pop 	link
		ret
;
;		Draw a line from XC-X,YC+Y to XC+X,YC+Y
;
._OSEDrawLine
		push 	r0,r1,r2,r3,r4,r5,link
		add 	r1,r6,#0 					; R1 = YC+Y
		mov 	r3,r1,#0 					; both R1 and R3 are YC+Y
		mov 	r4,r0,#0 					; R4 is XC
		sub 	r0,r5,#0 					; R0 = XC-X
		add 	r4,r5,#0 					; R4 = XC+X
		mov 	r2,r4,#0 					; R2 = XC+X
		stm 	r2,#xGraphic 				; set the 'last place'
		stm 	r3,#yGraphic
		skp 	r0
		clr 	r0
		skp 	r1
		clr 	r1
		skp 	r2
		clr 	r2
		skp 	r3
		clr 	r3
		jsr 	#OSFillRectangle 			; this is quicker than calling line which calls it anyway
		pop 	r0,r1,r2,r3,r4,r5,link
		ret
;
;		Draw a pair of pixels at X and -X (Handler for CURVE)
;
._OSEDrawPixelPair
		push 	link
		jsr 	#_OSEDrawPixelFlipX
		jsr 	#_OSEDrawPixelFlipX
		pop 	link
		ret
;
;		Draw a pixel at X and negate X
;
._OSEDrawPixelFlipX
		push 	link
		jsr 	#OSWaitBlitter
		mov 	r10,r5,#0 					; set blitterX to XC+X
		add 	r10,r0,#0
		skp 	r10
		clr 	r10
		stm 	r10,#blitterX
		mov 	r10,r6,#0 					; set blitterY to YC+Y
		add 	r10,r1,#0
		skp 	r10
		clr 	r10
		stm 	r10,#blitterY
		mov 	r10,#_OSXEllipsePixel 		; set ellipse pixel 
		stm 	r10,#blitterData
		mov 	r10,#1 						; draw 1 pixel
		stm 	r10,#blitterCmd

		xor 	r5,#$FFFF 					; negate X
		inc 	r5
		pop 	link
		ret

._OSXEllipsePixel
		word 	$8000
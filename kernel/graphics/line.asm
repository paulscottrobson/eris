; *****************************************************************************
; *****************************************************************************
;
;		Name:		line.asm
;		Purpose:	Draw Line (Bresenham)
;		Created:	25th March 2020
;		Reviewed: 	TODO
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

.OSXDrawLine
		push 	r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,link
		;
		jsr 	#OSSetInkColourMask 		; set colour/mask, which waits for blitter
		mov 	r4,#_OSDLPixel 				; pixel at far left, set as data
		stm 	r4,#blitterData
		;
		ldm 	r2,#xGraphic 				; R2,R3 = current position
		ldm 	r3,#yGraphic
		mov 	r4,r3,#0 					; check if right way up e.g. r3 >= r1
		sub 	r4,r1,#0

		sklt
		jmp 	#_OSXDrawLineNoSwap

		mov 	r4,r0,#0 					; swap round so x1,y1 above/level with x2,y2
		mov 	r0,r2,#0
		mov 	r2,r4,#0
		mov 	r4,r1,#0
		mov 	r1,r3,#0
		mov 	r3,r4,#0
._OSXDrawLineNoSwap
		;
		;		X0,Y0 are R0 and R1  X1,Y1 are R2 and R3
		;		DX,DY are R4,R5
		;		ERR is R6
		;
		mov 	r4,r2,#0					; DX = X1-X0
		sub 	r4,r0,#0
		mov 	r5,r1,#0 					; DY = Y0-Y1
		sub 	r5,r3,#0
		;
		;		If R4/R5 (e.g. dx or dy) is zero use the rectangle drawer.
		; 
		sknz 	r4
		jmp 	#_OSXDrawLineOptimise
		sknz 	r5
		jmp 	#_OSXDrawLineOptimise
		mov 	r9,#1 						; X STEP is 1.

		;
		;		At this point we use X2 and Y2 as counters, so we put DX and -DY in there
		;
		mov 	r2,r4,#0
		clr 	r3
		sub 	r3,r5,#0
		skm 	r2 							; if DX < 0 
		jmp 	#_OSXNotFlipped
		clr 	r4 							; fix up DX so it's positive
		sub 	r4,r2,#0
		mov 	r2,r4,#0 					; and make it counter and dx
		mov 	r9,#-1 						; draw r->l
		;
		;		The main Loop
		;
._OSXNotFlipped		
		mov 	r6,r4,#0 					; ERR = DX + DY
		add 	r6,r5,#0

._OSXDrawLineLoop		
		jsr 	#OSWaitBlitter 				; draw the pixel. already set colour/mask and data
		stm 	r0,#blitterX
		stm 	r1,#blitterY
		mov 	r7,#$8001 					; one vertical no increment
		stm 	r7,#blitterCmd

		mov 	r7,r2,#0 					; keep going till counters are zero
		add 	r7,r3,#0
		sknz 	r7
		jmp 	#_OSXDrawLineExit
._OSXDrawLineAdjust
		mov 	r7,r6,#0 					; check E2 (2 x ERR) >= DY
		add 	r7,r7,#0
		mov 	r8,r7,#0 					; save E2 in R8
		sub 	r7,r5,#0
		skp 	r7
		jmp 	#_OSXDLA1
		add 	r6,r5,#0 					; ERR = ERR + DY
		add 	r0,r9,#0  					; X0 += X DIR
		dec 	r2 							; adjust counter in X2
._OSXDLA1		
	
		mov 	r7,r4,#0 					; check DX >= E2
		sub 	r7,r8,#0
		skp 	r7 
		jmp 	#_OSXDLA2

		add 	r6,r4,#0 					; ERR = ERR + DX
		inc 	r1 							; Y0 ++
		dec 	r3 							; adjust counter in Y2
._OSXDLA2
		jmp 	#_OSXDrawLineLoop

._OSXDrawLineOptimise
		pop 	r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,link
		jmp 	#OSFillRectangle

._OSXDrawLineExit
		pop 	r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,link
		jmp 	#GraphicsSaveExit

._OSDLPixel
		word	$8000

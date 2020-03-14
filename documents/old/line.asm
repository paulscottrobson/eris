; *****************************************************************************
; *****************************************************************************
;
;		Name:		line.asm
;		Purpose:	Draw Line
;		Created:	1st March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

;
;		R0 		y0:x0
;		R1 		y1:x1
;		R2 		dx
; 		R3 		dy
;		R4 		err
;		R5/R6 	e2
;		R7 		the X increment
;
.OSXDrawLine
		push	r0,r1,r2,r3,r4,r5,r6,r7,link
		ldm 	r1,#gfxPosition 				; R0, R1 now have the two line positions.
		mov 	r2,r1,#0 						; if R0 > R1 then swap them
		sub 	r2,r0,#0
		sklt
		jmp 	#_OSDLNoSwap
		mov 	r2,r1,#0
		mov 	r1,r0,#0
		mov 	r0,r2,#0
._OSDLNoSwap 									; now R0 and R1 are in vertical order.
		mov 	r2,r1,#0 						; calculate dx (x1 - x0) in R2
		mov 	r3,r0,#0
		and 	r2,#$00FF
		and 	r3,#$00FF
		sub 	r2,r3,#0 						
		;
		mov 	r7,#1 							
		skm 	r2 								; if dx is negative it's right to left
		jmp 	#_OSDLNotRToL
		xor 	r2,#$FFFF 						; negate R2
		inc 	r2
		sub 	r7,#2 							; and go backwards
._OSDLNotRToL		
		;
		mov 	r3,r0,#0 						; calculate dy (y0 - y1) in R3
		mov 	r4,r1,#0
		ror 	r3,#8
		ror 	r4,#8
		and 	r3,#$00FF
		and 	r4,#$00FF
		sub 	r3,r4,#0
		;
		mov 	r4,r3,#0 						; err = dx + dy
		add 	r4,r2,#0 						
		;
		jsr		#_OSDLPlot 						; write pixel out.
		;
._OSDLLoop:
		mov 	r5,r0,#0	 					; is r0 = r1 ?
		xor 	r5,r1,#0
		sknz 	r5
		jmp 	#_OSDLExit

		mov 	r5,r4,#0 						; e2 = 2 * err
		add 	r5,r5,#0
		mov 	r6,r5,#0
		sub 	r5,r3,#0 						; check e2 >= dy
		skp 	r5
		jmp 	#_OSDLSkip1
		;
		add 	r4,r3,#0 						; err += dy
		add 	r0,r7,#0  						; x0 ++ or --
		;
._OSDLSkip1
		mov 	r5,r2,#0 						; check dx >= e2
		sub 	r5,r6,#0
		skp 	r5
		jmp 	#_OSDLSkip2
		;
		add 	r4,r2,#0 						; err += dx
		add 	r0,#256 						; y0++
		;
._OSDLSkip2
		jsr		#_OSDLPlot 						; write pixel out.
		jmp 	#_OSDLLoop

._OSDLExit:		
		pop		r0,r1,r2,r3,r4,r5,r6,r7,link
		stm 	r0,#gfxPosition 				; update drawing posiiton onexit
		ret

._OSDLPlot 
		push 	r1,link
		jsr 	#OSWaitBlitter 					; wait for blitter to be free
		stm 	r0,#blitterPos
		mov 	r1,#_OSDLPixel
		stm 	r1,#blitterData
		ldm 	r1,#gfxColour 					; write one pixel without increment
		and 	r1,#$000F
		add 	r1,#$2100
		stm 	r1,#blitterCmd
		pop 	r1,link
		ret

._OSDLPixel:
		word 	$8000
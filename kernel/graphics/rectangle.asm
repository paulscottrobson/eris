; *****************************************************************************
; *****************************************************************************
;
;		Name:		rectangle.asm
;		Purpose:	Draw Rectangle
;		Created:	1st March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;				Draw rectangle from current to R0, move to R0
;
; *****************************************************************************

.OSXDrawRectangle
		push 	r0,r1,r2,link
		ldm 	r1,#gfxPosition 			; R1 is the current drawing position. Count in R0.
		sub 	r0,r1,#0					; work out the size.
		add 	r0,#$0101
		;
._OSDRLoop1
		mov 	r2,r0,#0 					; get the 8 bit width into R2
		and 	r2,#$00FF
		sknz 	r2 
		jmp 	#_OSDRExit 					; exit if zero.
		and 	r2,#$000F 					; xsize of the next bar : 0 = 16 pixels. (conveniently)
		jsr 	#_OSDRVerticalBar
		sknz 	r2 							; r2 is now the number of pixels
		mov 	r2,#16 						; (e.g. 0 => 16)
		add 	r1,r2,#0 					; advance position
		sub 	r0,r2,#0 					; decrement size
		jmp 	#_OSDRLoop1 				; and go round again.

._OSDRExit
		pop 	r0,r1,r2,link
		stm 	r0,#gfxPosition 			; and update the position
		ret

;
;		Vertical bar at R1, width in R2 (0 = 16). Height in R0.1
;

._OSDRVerticalBar		
		push 	r1,r2,r3,r4,link
		jsr 	#OSWaitBlitter 				; wait for free blitter
		stm 	r1,#blitterPos 				; set position.
		ldm 	r4,#gfxColour 				; R4 is the draw colour
		and 	r4,#$0F 					; foreground only
		mov 	r1,#$FFFF 					; this graphic for a 16 pixel vertical bar
		sknz 	r2 							; use if R2 = 0
		jmp 	#_OSDRHaveGraphic
		;
		mov 	r1,#$0001
		ror 	r1,r2,#0 					; so 1 = $8000 2 = $4000 3 = $2000 ...
		dec 	r1 							; so 1 = $7FFF 2 = $3FFF 3 = $1FFF ...
		xor 	r1,#$FFFF 					; so 1 = $8000,2 = $C000,3 = $E000 ...
._OSDRHaveGraphic
		mov 	r2,#drawTemp 				; write this graphic into draw temp
		stm 	r1,r2,#0 			
		stm 	r2,#blitterData 			; and use that data for the drawing.
		;
		mov 	r2,r0,#0 					; height into R2.
		ror 	r2,#8
		and 	r2,#$00FF 					
._OSDRVerticalBarLoop
		sknz 	r2 							; more to draw
		jmp 	#_OSDRExit2 				; if not then exit		

		mov 	r1,r2,#0 					; vertical size is lower 4 bits of count
		and 	r1,#$0F 					; 0 => 16
		ror 	r1,#8 						; 0s00
		add 	r1,#$2000 					; set the no-increment bit.
		add 	r1,r4,#0 					; add colour.
		jsr 	#OSWaitBlitter 				; wait for blitter to be ready. Duplicate first time round
		stm 	r1,#blitterCmd 				; and do that command.
		dec 	r2 							; go to previous 16 bit boundary.
		and 	r2,#$FFF0
		jmp 	#_OSDRVerticalBarLoop

._OSDRExit2
		pop 	r1,r2,r3,r4,link
		ret
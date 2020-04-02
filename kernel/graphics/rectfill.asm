; *****************************************************************************
; *****************************************************************************
;
;		Name:		rectfill.asm
;		Purpose:	Draw Solid Rectangle
;		Created:	25th March 2020
;		Reviewed: 	20th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;				Draw rectangle from current position to R0,R1
;
; *****************************************************************************

.OSXFillRectangle
		push 	r0,r1,r2,r3,r4,r5,link
		jsr 	#OSISetInkColourMask 		; set colour/mask
		jsr 	#OSIGraphicBoxCoordinates 	; (R0,R1) -> (R2,R3)
		sub 	r3,r1,#0 					; R3 is the height (difference + 1)
		add 	r3,#$8001 					; make it a non incrementing data command
		sub 	r2,r0,#0  					; R2 is the horizontal size.
		inc 	r2
._OSXFRLoop
		mov 	r5,#$FFFF 					; mask to use if 16 wide.
		mov 	r4,r2,#0 					; is remaining width a multiplier of 16
		and 	r4,#15 						; R4 is the remainder of division by 16
		sknz 	r4
		jmp 	#_OSXFRHaveMask
								
		mov 	r5,#1	 					; R5 = 1:$8000,$4000,$2000 .... 15:$0002
		ror 	r5,r4,#0 					
		dec 	r5 							; R5 = 1:$7FFF,$3FFF,$1FFF .... 15:$0001
		xor 	r5,#$FFFF 					; R5 = 1:$8000,$C000,$E000 .... 15:$FFFE
._OSXFRHaveMask
		jsr 	#OSWaitBlitter 				; wait for free blitter.
		stm 	r0,#blitterX
		stm 	r1,#blitterY
		mov 	r4,#blitterTemp 			; set the data pointer.
		stm 	r5,r4,#0
		stm 	r4,#blitterData
		stm 	r3,#blitterCmd 				; do the blit
		;
		mov 	r4,r2,#0 					; calc # pixels done
		and 	r4,#15
		sknz 	r4
		mov 	r4,#16
		add 	r0,r4,#0 					; move x position
		sub 	r2,r4,#0 					; shrink width
		skz 	r2 							; until width = 0
		jmp 	#_OSXFRLoop
		pop 	r0,r1,r2,r3,r4,r5,link		
		jmp 	#GraphicsSaveExit

; *****************************************************************************
;
;		Load the old position in R2,R3 and sort so its a box with (R0,R1) at
;		top left and (R2,R3) at bottom right.
;		
; *****************************************************************************

.OSIGraphicBoxCoordinates
		push 	r4
		ldm 	r2,#xGraphic
		ldm 	r3,#yGraphic
		;
		mov 	r4,r0,#0
		sub 	r4,r2,#0
		skge 	
		jmp 	#_OSGCXNoSortX		
		mov 	r4,r0,#0
		mov 	r0,r2,#0
		mov 	r2,r4,#0
._OSGCXNoSortX		
		mov 	r4,r1,#0
		sub 	r4,r3,#0
		skge 	
		jmp 	#_OSGCXNoSortY
		mov 	r4,r1,#0
		mov 	r1,r3,#0
		mov 	r3,r4,#0
._OSGCXNoSortY		
		pop 	r4
		ret


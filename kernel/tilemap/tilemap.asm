; *****************************************************************************
; *****************************************************************************
;
;		Name:		tilemap.asm
;		Purpose:	Tilemap main routine
;		Created:	31st March 2020
;		Reviewed: 	TODO
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;		Draw a tilemap. Origin point (R0,R1) Offset (R2,R3) Size (R4,R5)
;		Data (R6)
;
;		This does *not* clip.
;
; *****************************************************************************

.OSXDrawTileMap
		push 	r0,r1,r2,r3,r4,r5,r6,r7,r8,link
		mov 	r7,#16 					; tile size
		;
		;		First handle where the offset is not a multiple of the tile size.
		;		If not, shift the drawing of the first time up and/or left, and
		;		increment the tile draw size by 1 as required.
		;
		jsr 	#_OSXDTMProcessX
		jsr 	#_OSXDTMProcessY
		;
		;		At this point we have a solid number of tiles, draw them a line at a time.
		;	
._OSXDTM1
		sknz 	r5 						; done all vertical ?
		jmp 	#_OSXDTMExit
		dec 	r5 						; decrement the count.
		push 	r0,r2,r4 				; save horizontal values - draw point, offset in table, size
._OSXDTM2		
		sknz 	r4 						; done all horizontal ?
		jmp 	#_OSXDTMDoneHorizontal
		dec 	r4 						; decrement the count.
		jsr 	#OSXDrawOneTile
		add 	r0,r7,#0 				; add tile size to x draw point
		inc 	r2 						; increment x offset
		jmp 	#_OSXDTM2 				; loop round
._OSXDTMDoneHorizontal		
		pop 	r0,r2,r4 				; restore horizontal values
		add 	r1,r7,#0 				; add tile size to y draw point
		inc 	r3 						; increment Y offset
		jmp 	#_OSXDTM1 				; loop round again
;
._OSXDTMExit		
		pop 	r0,r1,r2,r3,r4,r5,r6,r7,r8,link
		ret

; *****************************************************************************
;
;		Draw tile at (R0,R1) offset in table (R2,R3), data pointer R6
;		tile size R7.
;
; *****************************************************************************

.OSXDrawOneTile
		push 	r0,r1,r4,r5,r8,link
		jsr 	#OSWaitBlitter
		stm		r0,#blitterX 			; set X and Y
		stm 	r1,#blitterY

		skp 	r2 						; if either offset -ve then background
		jmp 	#_OSXDotBackground 		;
		skp 	r3
		jmp 	#_OSXDotBackground
		mov 	r0,r2,#0 				; check offset < limits
		ldm 	r1,r6,#2
		sub 	r0,r1,#0
		sklt
		jmp 	#_OSXDotBackground
		mov 	r0,r3,#0 				; check offset < limits
		ldm 	r1,r6,#3
		sub 	r0,r1,#0
		sklt
		jmp 	#_OSXDotBackground
		;
		;		On the tile map. Get the tile out and process it.
		;
		mov 	r0,r3,#0 				; Y offset
		ldm 	r1,r6,#2 				; X Size
		mult 	r0,r1,#0 				; Y * Width
		add 	r0,r2,#5 				; add X + 5
		add 	r0,r6,#0 				; now points into the table
		ldm 	r0,r0,#0 				; read the tile.
		;
		mov 	r5,r0,#0 				; command base in R5
		and 	r5,#$6000 				; mask out unwanted command bits.
		add 	r5,#$0800 				; set the fill background bit.
		mov 	r8,r0,#0 				; get colour bits out
		ror 	r8,#8
		and 	r8,#7
		;
		and 	r0,#255					; tile number.
		ror 	r0,#12 					; multiply by 16
		ldm 	r1,#spriteImageMemory 	; add the image memory base
		add 	r0,r1,#0
		mov 	r4,r0,#0 				; put in R4
		jmp 	#_OSXDotDraw
		;
		;		Come here to draw a background tile (e.g. colour 0)
		;		
._OSXDOTBackground		
		mov 	r4,#_OSXTileMasks 		; R4 is the data pointer
		mov 	r5,#$8000 				; R5 is the command base
		ldm 	r8,r6,#4				; R8 colour
		;
		;		Data @ R4, Command Base @ R5 ; set up and print
		;
._OSXDOTDraw		
		stm 	r4,#blitterData 		; set data
		;
		ldm 	r4,#colourMask 			; put colour mask into MSB
		ror 	r4,#8
		add 	r4,r8,#0 				; add colour in.
		stm 	r4,#blitterCMask 		; set colour/mask.
		;
		add 	r5,r7,#0 				; add size of tile to command base.
		stm 	r5,#blitterCmd 			; and draw the tile.
		;
		pop 	r0,r1,r4,r5,r8,link
		ret

._OSXTileMasks
		word 	$FFFF

; *****************************************************************************
;
;		R0 x Draw Position R2 x Offset into map in pixels, R4 count, R7 tile size
;
; *****************************************************************************

._OSXDTMProcessX
		mov 	r8,r2,#0 				; R8 = XO & 15
		and 	r8,#15
		sknz 	r8
		jmp 	#_OSXDTMDivide
		;
		sub 	r0,r8,#0 				; X = X - (X & 15)
		sub 	r2,r8,#0 				; XO = XO - (X & 15)
		;
		inc 	r4
._OSXDTMDivide		
		mov 	r8,r2,#0
		ror 	r2,#4
		and 	r2,#$0FFF
		skp 	r8
		add 	r2,#$F000
		ret
;
;		Exact copy using Y
;
._OSXDTMProcessY
		mov 	r8,r3,#0 				; R8 = YO & 15
		and 	r8,#15
		sknz 	r8
		jmp 	#_OSXDTMDivide2
		;
		sub 	r1,r8,#0 				; Y = Y - (Y & 15)
		sub 	r3,r8,#0 				; YO = YO - (Y & 15)
		;
		inc 	r5
._OSXDTMDivide2
		mov 	r8,r3,#0
		ror 	r3,#4
		and 	r3,#$0FFF
		skp 	r8
		add 	r3,#$F000
		ret		
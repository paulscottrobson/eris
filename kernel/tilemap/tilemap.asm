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
		push 	r0,r1,r2,r3,r4,r5,r6,r7,link
		;
		;		First handle where the offset is not a multiple of the tile size.
		;		If not, shift the drawing of the first time up and/or left, and
		;		increment the tile draw size by 1 as required.
		;
		; 	TODO: The above bit !
		;
		;		Convert the pixel offsets to tile offsets
		;
		ror 	r2,#4 					; this is a fudge for the above routine in 16x16
		ror 	r3,#4 					; signed division of offset !!!
		and 	r2,#$0FFF
		and 	r3,#$0FFF
		mov 	r7,#16 					; tile size
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
		pop 	r0,r1,r2,r3,r4,r5,r6,r7,link
		ret

; *****************************************************************************
;
;		Draw tile at (R0,R1) offset in table (R2,R3), data pointer R6
;
; *****************************************************************************

.OSXDrawOneTile
		push 	r4,r5,link


		pop 	r4,r5,link
		ret

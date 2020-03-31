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
		push 	r0,r1,r2,r3,r4,r5,r6,link
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
		ror 	r3,#4
		and 	r2,#$0FFF
		and 	r3,#$0FFF
		;
		;		At this point we have a solid number of tiles, draw them a line at a time.
		;	
		
		pop 	r0,r1,r2,r3,r4,r5,r6,link
		ret
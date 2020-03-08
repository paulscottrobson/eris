; *****************************************************************************
; *****************************************************************************
;
;		Name:		drawtext.asm
;		Purpose:	Draw character on display
;		Created:	28th February 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;				  Draw character R0 at graphics position/colour
;
; *****************************************************************************

.OSXDrawCharacter
		push 	r0,r1,link
		and 	r0,#$FF 						; mask off char
		ldm 	r1,#gfxColour 					; add colour to MSB
		ror 	r1,#8
		add 	r0,r1,#0
		ldm 	r1,#gfxPosition
		jsr 	#OSIDrawCharacter
		add 	r1,#CharPixelWidth
		stm 	r1,#gfxPosition
		pop 	r0,r1,link
		ret

; *****************************************************************************
;
;					Draw character R0 at position R1
;
;				 R0 = <back:4><fore:4><0:1><character:7>
;
; *****************************************************************************

.OSIDrawCharacter		
		push 	r0,r2,r3,link

		mov 	r2,#blitterBase 				; access blitter via R2
		;
		;		draw the background
		;
		jsr 	#OSWaitBlitter 					; blitter available
		stm 	r1,r2,#blitterPos-blitterBase 	; write position.
		mov 	r3,#_OSDCMask
		stm 	r3,r2,#blitterData-blitterBase 	; write data
		mov 	r3,r0,#0 						; get background
		ror 	r3,#12
		and 	r3,#15
		add 	r3,#$2800 						; write don't increment
		stm 	r3,r2,#blitterCmd-blitterBase	; do it.	
		;
		;		Now draw the character on top.
		;
		jsr 	#OSWaitBlitter 					; blitter available
		stm 	r1,r2,#blitterPos-blitterBase 	; write position.
		mov 	r3,r0,#0 						; calculate data position, character
		and 	r3,#$7F 						; mask out character

;		sknz 	r3 								; these two lines make xx00 visible.
;		mov 	r3,#$7F 						; and are for testing the screen editor only.

		sub 	r3,#$20 						; ignore $00-$1F
		skp 	r3
		jmp 	#_OSXDCExit
		ror 	r3,#13 							; multiply by 8
		add 	r3,#FontData 					; add font table base
		stm 	r3,r2,#blitterData-blitterBase 	; set the data pointer.
		mov 	r3,r0,#0 						; get foreground colour
		ror 	r3,#8
		and 	r3,#15 
		add 	r3,#$0800						; write 8 rows
		stm 	r3,r2,#blitterCmd-blitterBase	; do it.
._OSXDCExit
		pop 	r0,r2,r3,link
		ret

._OSDCMask
		word 	$FC00 							; mask to erase.		
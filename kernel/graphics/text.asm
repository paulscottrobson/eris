; *****************************************************************************
; *****************************************************************************
;
;		Name:		text.asm
;		Purpose:	Graphic text drawing
;		Created:	2nd April 2020
;		Reviewed: 	TODO
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

.OSXDrawString	
		push 	r1,r2,r3,r4,r5,link			; don't save R0 as it's updated to print
		jsr 	#OSSetInkColourMask 		; set colour/mask
		ldm 	r3,r2,#0 					; get count to print
._OSXDSLoop
		inc 	r2
		ldm 	r4,r2,#0 					; do both halves
		jsr 	#_OSXDSDrawOne
		ldm 	r4,r2,#0
		ror 	r4,#8
		jsr 	#_OSXDSDrawOne
		skz 	r3							; loop back if not done
		jmp 	#_OSXDSLoop

		pop 	r1,r2,r3,r4,r5,link 			
		jmp 	#GraphicsSaveExit

._OSXDSDrawOne
		sknz 	r3 							; already done them all
		ret
		and 	r4,#$00FF 					; mask off, and convert to starting at 33
		sub 	r4,#33
		skge
		jmp 	#_OSXDSDrawOneExit
		;
		push 	link
		jsr 	#OSWaitBlitter 				; wait for blitter
		stm 	r0,#blitterX 				; write now done.
		stm 	r1,#blitterY 				

		ror 	r4,#13 						; multiply (char# - 33) result by 8 the character height
		ldm 	r5,#defaultFont 			; make R1 point to the font data
		add 	r5,r4,#8					; +8 because we do not print space hence sub r0,#33
		stm 	r5,#blitterData 			; which is also the blitter data source.
		mov 	r4,#8 						; and write out 8 bytes, no background
		stm 	r4,#blitterCmd
		pop 	link

._OSXDSDrawOneExit
		dec 	r3 							; decrement count
		add 	r0,#6 						; write one character
		ret
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
		sknz 	r3 							; size zero.
		ret
		push 	r1,r2,r3,r4,r5,r6,link		; don't save R0 as it's updated to print
		jsr 	#OSSetInkColourMask 		; set colour/mask
		ldm 	r6,r2,#0 					; get count to print
._OSXDSLoop
		inc 	r2
		ldm 	r4,r2,#0 					; do both halves
		jsr 	#_OSXDSDrawOne
		ldm 	r4,r2,#0
		ror 	r4,#8
		jsr 	#_OSXDSDrawOne
		skz 	r6							; loop back if not done
		jmp 	#_OSXDSLoop

		pop 	r1,r2,r3,r4,r5,r6,link 			
		jmp 	#GraphicsSaveExit

._OSXDSDrawOne
		sknz 	r6 							; already done them all
		ret
		and 	r4,#$00FF 					; mask off, and convert to starting at 33
		sub 	r4,#33
		skge
		jmp 	#_OSXDSDrawOneExit
		;
		push 	link
		jsr 	#OSWaitBlitter 				; wait for blitter
		stm 	r0,#blitterX 				; set position
		stm 	r1,#blitterY 				

		ror 	r4,#13 						; multiply (char# - 33) result by 8 the character height
		ldm 	r5,#defaultFont 			; make R1 point to the font data
		add 	r5,r4,#8					; +8 because we do not print space hence sub r0,#33

		mov 	r4,r3,#0 					; if size = 1
		xor 	r4,#1 
		sknz 	r4
		jmp 	#_OSXDSScale1
		mov 	r4,r5,#0
		jsr 	#_OSXDrawScaledCharacter
		jmp 	#_OSXDSExit2
._OSXDSScale1
		stm 	r5,#blitterData 			; which is also the blitter data source.
		mov 	r4,#8 						; and write out 8 bytes, no background
		stm 	r4,#blitterCmd
._OSXDSExit2
		pop 	link

._OSXDSDrawOneExit
		dec 	r6 							; decrement count
		mov 	r4,r3,#0
		mult 	r4,#6
		add 	r0,r4,#0 					; write one character
		ret
;
;		Draw scaled character at R0,R1, Scale R3, Data R4
;
._OSXDrawScaledCharacter
		push 	r1,r2,r4,r5,link
		mov 	r2,#7 						; rows to print	in R2
._OSXDSCLoop
		push 	r0 							; save X
		ldm 	r5,r4,#0 					; get data into R5
		inc 	r4
._OSXDSCLoop2		
		skp 	r5 							; draw block if bit 15 set
		jsr 	#_OSXDrawScaledPixel
		add 	r5,r5,#0 					; shift data left
		add 	r0,r3,#0 					; advance by pixel width
		skz 	r5 							; finished
		jmp 	#_OSXDSCLoop2
		pop 	r0 							; restore X
		add 	r1,r3,#0 					; down one row
		dec 	r2 							; do all 7 rows.
		skz 	r2
		jmp 	#_OSXDSCLoop
		pop 	r1,r2,r4,r5,link
		ret		
;
;		Draw pixel at R0,R1, Scale R3
;
._OSXDrawScaledPixel
		push 	r0,r1,link
		jsr 	#OSWaitBlitter 				; wait for blitter
		stm 	r0,#blitterX 				; set position
		stm 	r1,#blitterY 				
		;
		mov 	r0,#1 						
		ror 	r0,r3,#0 					; 1 = $8000,2 = $4000 etc.
		dec 	r0 							; 1 = $7FFF.2 = $3FFF etc.
		xor 	r0,#$FFFF 					; 1 = $8000 2 = $C000 etc.
		mov 	r1,#blitterTemp 			; use as drawing.
		stm 	r0,r1,#0					; set temp
		stm 	r1,#blitterData 			
		;
		mov 	r0,r3,#0 					; size
		add 	r0,#$8000 					; repeat same word
		stm 	r0,#blitterCmd

		pop 	r0,r1,link
		ret

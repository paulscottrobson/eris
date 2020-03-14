; *****************************************************************************
; *****************************************************************************
;
;		Name:		lineinput.asm
;		Purpose:	Line Input code
;		Created:	9th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;			Input a line from the screen, return text as ASCIIZ @ R0  
;
;							(note the text is coloured)
;	(Note, the text is in screen memory, so it may change if you print to it,
;	 if you wish to do this copy it to a buffer)
; *****************************************************************************

.OSXLineInput
		push 	r1,link		
		clr 	r0 								; don't print anything first time.
._OSXLIEdit		
		jsr 	#OSPrintCharacter 				; print char
		jsr 	#OSCursorGet 					; get next
		mov 	r1,r0,#0 						; is it CR ?
		sub 	r1,#13
		skz 	r1
		jmp 	#_OSXLIEdit
		;
		mov 	r0,#14 							; print a non-destructive CR
		jsr 	#OSXPrintCharacter 
		jsr 	#_OSCurrentTextR1				; get address into R1
		mov 	r0,r1,#0 						; put into R0
		;
		;		Keep going back until you hit a $xx00 at the end of the previous line. Note
		;		that there is a $0000 word before the top left character in the text buffer
		; 		as a stop
		;
._OSXLIFindStart:
		sub 	r0,#charWidth 					; up one line.
		mov 	r1,r0,#0 						; read the word before, e.g. last char of prev line.
		dec 	r1
		ldm 	r1,r1,#0
		and 	r1,#$00FF 						; the text is coloured so strip that off.
		skz 	r1 								; if zero, R0 points to the line start.		
		pop 	r1,link
		ret

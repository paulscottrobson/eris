; *****************************************************************************
; *****************************************************************************
;
;		Name:		substring.asm
;		Purpose:	Unary SubString functions
;		Created:	17th April 2020
;		Reviewed: 	TODO
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;		 sub.count(string$,sep$) returns number of elements in substring
;
; *****************************************************************************

.Unary_SubCount 	;; [sub.count(]
		push 	r1,r2,r3,r4,link
		jsr 	#EvaluateString 			; get string into R1
		mov 	r1,r0,#0
		jsr 	#OSXWordLength 				; chars to check in R3
		mov 	r3,r0,#0
		jsr 	#CheckComma 			
		jsr 	#UCGetSeperator 			; get seperator character code to R2.
		jsr 	#CheckRightBracket
		mov 	r4,#1 						; reset the count to 1 (no seperator = 1 element)
._USCLoop
		sknz 	r3 							; done them all ?
		jmp 	#_USCExit
		dec 	r3
		inc 	r1 							; pre-increment because of count
		ldm 	r0,r1,#0 					; check low
		and 	r0,#$00FF
		xor 	r0,r2,#0
		sknz 	r0
		inc 	r4		
		ldm 	r0,r1,#0 					; check high
		ror 	r0,#8
		and 	r0,#$00FF
		xor 	r0,r2,#0
		sknz 	r0
		inc 	r4		
		jmp 	#_USCLoop

._USCExit
		stm 	r4,r10,#esValue1
		stm 	r14,r10,#esType1
		stm 	r14,r10,#esReference1
		pop 	r1,r2,r3,r4,link
		ret

; *****************************************************************************
;
;		 	sub.get(string$,sep$) return string element 1..n
;
; *****************************************************************************

.Unary_SubGet 		;; [sub.get$(]
		push 	r1,r2,r3,r4,r5,r6,link
		jsr 	#EvaluateString 			; get string into R4, skip past length.
		mov 	r4,r0,#1
		jsr 	#OSXWordLength 				; words to check in R3, maximum
		mov 	r3,r0,#0
		jsr 	#CheckComma 			
		jsr 	#UCGetSeperator 			; get seperator character code to R6
		mov 	r6,r2,#0 
		jsr 	#CheckComma 			
		jsr 	#EvaluateInteger 			; integer to R5, this is the element number.
		dec 	r0 							; zero base it.
		mov 	r5,r0,#0
		skp 	r0
		jmp 	#BadNumberError
		jsr 	#CheckRightBracket
		;
		;		Source string in R4. Words to check in R3. Sep in R6. Element # in R5 (0+)
		;
		mov 	r0,r3,#2 					; use the string creation routines in string.asm
		jsr 	#SFAllocate 				; create a temporary string which can fit the whole string.
		stm 	r0,r10,#esValue1 			; return as a string value
		stm 	r15,r10,#esType1 			; (EvaluateInteger clears reference)
		;
		;		Find the string start.
		;
._USGFindStart
		sknz 	r3 							; run out of string ?
		jmp 	#_USGExit
		;
		sknz 	r5 							; has the counter reached zero ?
		jmp 	#_USGCopyAll 				; copy the whole string out.
		;
		ldm 	r0,r4,#0 					; check the low byte (first char) first
		and 	r0,#$00FF
		xor 	r0,r6,#0
		sknz 	r0 							; if it is a marker, decrement counter
		dec 	r5
		sknz 	r5 							; if that counter is *now* zero, the upper byte is part of it.
		;
		jmp 	#_USGCopyUpperAll
		ldm 	r0,r4,#0 					; now do the high byte
		ror 	r0,#8
		and 	r0,#$00FF
		xor 	r0,r6,#0
		sknz 	r0 							; if it is a marker, decrement counter
		dec 	r5
		inc 	r4 							; go to next character.
		dec 	r3 							; decrement counter.
		jmp 	#_USGFindStart


._USGCopyAll
		sknz 	r3 							; nothing left to copy
		jmp 	#_USGExit
		;
		ldm 	r0,r4,#0 					; get LSB
		and 	r0,#$00FF
		xor 	r0,r6,#0 					; is it the seperator
		sknz 	r0 				
		jmp 	#_USGExit 					; exit if so.
		xor 	r0,r6,#0 					; get it back
		jsr 	#SFAddCharacter 			; output it
		;
._USGCopyUpperAll
		ldm 	r0,r4,#0 					; get MSB and repeat it.
		ror 	r0,#8 						
		and 	r0,#$00FF
		sknz 	r0 							; might be $00
		jmp 	#_USGExit
		xor 	r0,r6,#0 					; is it the seperator
		sknz 	r0 				
		jmp 	#_USGExit 					; exit if so.
		xor 	r0,r6,#0 					; get it back
		jsr 	#SFAddCharacter 			; output it
		;
		inc 	r4 							; next character
		dec 	r3
		jmp 	#_USGCopyAll

._USGExit
		pop 	r1,r2,r3,r4,r5,r6,link
		ret

; *****************************************************************************
;
;							Get a valid seperator into R2 
;
; *****************************************************************************

.UCGetSeperator
		push 	r0,link
		jsr 	#EvaluateString
		ldm 	r2,r0,#1 					; first character into R2
		ldm 	r0,r0,#0 					; get length
		xor 	r0,#1 						; should be one.		
		skz 	r0
		jmp 	#BadNumberError
		pop 	r0,link
		ret
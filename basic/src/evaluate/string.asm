; *****************************************************************************
; *****************************************************************************
;
;		Name:		string.asm
;		Purpose:	String concatenation / splitting functions
;		Created:	5th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;			Concatenate 1st/2nd string entry (already checked)
;
; *****************************************************************************

.StringConcat
		jsr 	#DereferenceBinary			; dereference.
		ldm	 	r0,r10,#esValue1 			; work out memory requirements by reading the lengths
		ldm 	r1,r0,#0 					
		ldm 	r0,r10,#esValue2 
		ldm 	r0,r0,#0
		add 	r0,r1,#0
		mov 	r1,r0,#0 					; check if >= max string size
		sub 	r1,#maxStringSize+1
		sklt
		jmp 	#StrlenError
		ror 	r0,#1 						; divide by 2
		and 	r0,#$7FFF 					
		add 	r0,#2 						; add a little extra space.
		jsr 	#SFAllocate					; and lazy writing.
		;
		ldm 	r3,r10,#esValue1 			; output the 1st string
		stm 	r1,r10,#esValue1 			; write this address as the result string address
		jsr 	#_SCOutput
		ldm 	r3,r10,#esValue2 			; output the 2nd string
		jsr 	#_SCOutput
		pop 	link
		ret
;
;		Write string at R3.
;
._SCOutput		
		push 	link
		mov 	r0,r3,#0 					; how many bytes to copy ?
		jsr 	#OSWordLength
		mov 	r4,r0,#0 					; into R4
._SCOutLoop		
		inc 	r3 							; next character
		sknz 	r4 							; exit if finished.
		jmp 	#_SCOutExit
		dec 	r4

		ldm 	r0,r3,#0 					; output low
		jsr 	#SFAddCharacter
		ldm 	r0,r3,#0 					; output high
		ror 	r0,#8
		jsr 	#SFAddCharacter
		jmp 	#_SCOutLoop
._SCOutExit		
		pop 	link
		ret

; *****************************************************************************
;
;	Allocate R0 bytes of string memory and set up R1 (base) and R2 (offset)
;
; *****************************************************************************

.SFAllocate
		push 	link
		jsr 	#AllocateTempMemory 		; allocate bytes for new string
		mov 	r1,r0,#0 					; R1 is the next word to write
		clr 	r2 							; R2 is the rotation for that word, 0->8->0
		stm 	r14,r1,#0 					; clear the length and first word
		stm 	r14,r1,#1
		pop 	link
		ret

; *****************************************************************************
;
;					Write R0 to R1/R2 pair creating a string
;
; *****************************************************************************

.SFAddCharacter
		and 	r0,#$00FF 					; convert to byte as its a character
		sknz 	r0 							; do not output $00
		ret
		push 	r3,r4
		mov 	r4,r2,#0 					; R4 = R2 rotated right
		ror 	r4,#1
		skp 	r4 							; if R2 bit 0 was set rotate R0 8
		ror 	r0,#8
		and 	r4,#$7FFF 					; R4 now is the offset
		add 	r4,r1,#1 					; now the address of the character
		ldm 	r3,r4,#0 					; get character
		add 	r3,r0,#0 					; add new one in
		stm 	r3,r4,#0 					; write back
		stm 	r14,r4,#1					; clear next word
		inc 	r2 							; increment offset/length
		stm 	r2,r1,#0  					; save in string header
		pop 	r3,r4
		ret

; *****************************************************************************
;
;				Mid$( - left$( and right$( also use this code
;
; *****************************************************************************

.Unary_Mid 		;; [mid$(]
		push 	link
		jsr 	#EvaluateString 			; get string into R3
		mov 	r3,r0,#0
		jsr 	#CheckComma 				
		jsr 	#EvaluateInteger 			; get start into R4		
		mov 	r4,r0,#0
		mov 	r5,#maxStringSize 			; this is the default for the third parameter
		ldm 	r0,r11,#0 					; is the next character a )
		xor 	r0,#TOK_RPAREN
		sknz	r0
		jmp 	#UnaryStringSliceCommon 	; if so, it's mid$(a$,x)
		jsr 	#CheckComma 				
		jsr 	#EvaluateInteger 			; get end into R5
		mov 	r5,r0,#0
		;
		;		String slicing Common code for left$, mid$ and right$ 
		;
		;		At this point, R3 points to the string, R4 to the start pos, R5 to the end pos
		;		note these positions start at 1.
		;
.UnaryStringSliceCommon
		jsr 	#CheckRightBracket 			; check there's a right bracket
		dec 	r4 							; convert position to offset (so 1 => start)
		;
		skp 	r4 							; check both are +ve
		jmp 	#BadNumberError
		skp 	r5
		jmp 	#BadNumberError
		sknz 	r5 							; if length is 0 then return empty string
		jmp 	#_USSCNull
		;
		;
		;		Check start offset < length. If >= then it is an empty string.
		;
		ldm 	r0,r3,#0 					; get string length in R0.
		mov 	r1,r4,#0 					
		sub 	r1,r0,#0 					
		sklt 							
		jmp 	#_USSCNull
		;
		;		Allocate memory for the string
		;
		mov 	r0,r5,#0 					; divide by 2, add 2 to get text size.
		ror 	r0,#1	
		and 	r0,#$7FFF
		add 	r0,#2
		jsr 	#SFAllocate 		 		; allocate string, setup r1 and r2
		stm 	r0,r10,#esValue1 			; save it so it is returned.
		clr 	r6 							; 0 = LSB 8 = MSB
		;
		;		Source String in R3. Start Offset in R4. Final Length in R5.
		;		(remember these are packed word). R6 contains the next byte half to use 0/8 rotate
		;
		;		R1 and R2 are set up so that we can write the string out.
		;
		; -------------------------------------------------------------------------------------
		;		
		;		Output characters until either (i) you reach a $00 or (ii) all chars have
		;		been copied
		;
		inc 	r3 							; advance R3 over length byte
._USSCCopyLoop
		dec 	r4 							; decrement the start offset. if this is still +ve
		skm 	r4 							; then we do not start copying, yet.
		jmp 	#_USSCNextCharacter
		;
		ldm 	r0,r3,#0 					; get the next character out.
		ror 	r0,r6,#0 					; rotate it into position
		and 	r0,#$00FF 					; convert to a byte
		sknz 	r0 							; if it is zero then exit, end of source
		jmp 	#_USSCExit
		jsr 	#SFAddCharacter 			; write that to the new string
		dec 	r5 							; decrement the final length
		sknz 	r5
		jmp 	#_USSCExit 					; exit if that is zero, e.g. we've done them all.
._USSCNextCharacter
		xor 	r6,#8 						; flip byte half
		sknz 	r6 							; if that was 8->0
		inc 	r3 							; look at the next word
		jmp 	#_USSCCopyLoop

._USSCNull
		mov 	r0,#1 						; allocate 1 character it is cleared
		jsr 	#SFAllocate 
		stm 	r0,r10,#esValue1 			; make return value

._USSCExit
		stm 	r14,r10,#esReference1 		; constant
		stm 	r15,r10,#esType1 			; string
		pop 	link
		ret

; *****************************************************************************
;
;							left$(a$,n) == mid$(a$,1,n)
;
; *****************************************************************************

.Unary_Left 		;; [left$(]
		push 	link
		jsr 	#EvaluateString 			; get string into R3
		mov 	r3,r0,#0
		jsr 	#CheckComma 				
		mov 	r4,#1 						; start = 1
		jsr 	#EvaluateInteger 			; get length into R5
		mov 	r5,r0,#0
		jmp 	#UnaryStringSliceCommon

; *****************************************************************************
;
;						right$(a$,n) == mid$(a$,len(a$)-n+1,...)
;
; *****************************************************************************

.Unary_Right 		;; [right$(]
		push 	link
		jsr 	#EvaluateString 			; get string into R3
		mov 	r3,r0,#0
		ldm 	r4,r3,#0 					; get string length into R4
		inc 	r4 							; add 1. if right$("abc",3) you start at 3-3+1
		jsr 	#CheckComma 				
		jsr 	#EvaluateInteger 			; get right count
		sub 	r4,r0,#0 					; calculate start position
		skp 	r4 							; if <= 0 make start position 1
		mov 	r4,#1
		sknz 	r4
		mov 	r4,#1
		mov 	r5,#maxStringSize 			; to the end of the string.
		jmp 	#UnaryStringSliceCommon

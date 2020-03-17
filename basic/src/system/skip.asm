; *****************************************************************************
; *****************************************************************************
;
;		Name:		skip.asm
;		Purpose:	Structure forward skip.
;		Created:	10th March 2020
;		Reviewed: 	16th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;				Skip forward from R11, looking for token R0 or R1
;						 allowing for CMD+ and CMD- tokens
;									Busts R2,R3,R4
;
; *****************************************************************************

.SkipStructure 	
		clr 	r3 							; R3 is the structure level at any time
		;
		;		Forward Search
		;
._SSLoop
		ldm 	r2,r11,#0 					; get next token
		sknz 	r2 							; if zero, goto next line
		jmp 	#_SSNextLine
		;
		;		If in another level, don't check against required tokens.
		;
		skz 	r3 							; if structure level +ve don't bother checking
		jmp 	#_SSNext
		;
		xor 	r2,r0,#0 					; compare against tokens passed in, R0 first
		sknz 	r2
		jmp 	#_SSFound
		ldm 	r2,r11,#0 					; then R1, goto found code if match and level = 0
		xor 	r2,r1,#0
		sknz 	r2
		jmp 	#_SSFound
		;
		;		Nex token
		;
._SSNext
		ldm 	r2,r11,#0 					; get token
		and 	r2,#$FF00 					; check if it is a string 01xx
		xor 	r2,#$0100
		sknz 	r2
		jmp 	#_SSString
		;
		;		Look to see if it is a command token.
		;
		ldm 	r2,r11,#0 					; get token and copy to R4
		mov 	r4,r2,#0
		inc 	r11 						; bump to next token 

		and 	r2,#$F800 					; is it 0011 1xxx xxxx xxxx e.g. a command token
		xor 	r2,#$3800
		skz 	r2 							; if command token, 
		jmp 	#_SSLoop		
		;
		;		Handle command token - analyse to see structure change
		;
		ror 	r4,#9 						; R4 contains token 
		and 	r4,#3 						; R4 is now 1:-1 2:no change 3:+1
		sub 	r4,#2 						; now -1 0 -1
		add 	r3,r4,#0 					; add to structure level in R3
		skm 	r3 							; if -ve then error, we've got them mixed up
		jmp 	#_SSLoop 					
		jmp 	#StructureError
		;
		;		Handle String 01xx
		;
._SSString		
		ldm 	r2,r11,#0 					; get length 
		and 	r2,#$00FF
		add 	r11,r2,#0 					; add to position 
		jmp 	#_SSLoop
		;
		;		Reached end of line.
		;
._SSNextLine
		inc 	r11 						; skip over the end of line marker
		ldm 	r2,r11,#0 					; read the next word, the offset
		sknz 	r2 							; if zero, then structure failure
		jmp 	#StructureError
		;
		stm 	r11,#currentLine 			; set the current line to this new line
		add 	r11,#2 						; skip over offset and line number
		jmp 	#_SSLoop 					; and keep going
		;
		;		Found either token with level at zero, exit successfully.
		;
._SSFound
		inc 	r11 						; skip over the found token.
		ret 								; and exit

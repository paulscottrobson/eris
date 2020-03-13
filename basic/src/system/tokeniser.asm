; *****************************************************************************
; *****************************************************************************
;
;		Name:		tokeniser.asm
;		Purpose:	Coloured ASCII -> Tokenised code
;		Created:	12th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;		Tokenise coloured ASCII at R0. Return address of buffer in R0
;	 	or 0 if tokenising failed.
;
; *****************************************************************************

.TokeniseString	
		push 	r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,link
		mov 	r9,#tokenBuffer 			; tokenised code goes here.
		stm 	r14,r9,#0 					; zero the first two words
		stm 	r14,r9,#1
		add 	r9,#2 						; and skip them
		mov 	r8,r0,#0 					; characters come from here.
		mov 	r7,#$007F 					; R7 is the character mask 					
		;
		;		Main tokenising loop
		;
._TSLoop		
		ldm 	r0,r8,#0 					; look at next character
		and 	r0,r7,#0 					; as a character
		mov 	r3,r0,#0 					; put in R3.
		sknz 	r0
		jmp 	#_TSExit 					; exit if end of list
		xor 	r0,#' '						; if space , skip over
		inc 	r8
		sknz 	r0
		jmp 	#_TSLoop
		dec 	r8 							; R8 now points to current character
		;
		jsr 	#TokeniseElement 			; do one element
		skz 	r0 							; fail if return zero
		jmp 	#_TSFail
		jmp 	#_TSLoop

._TSExit
		stm 	r14,r9,#0 					; mark buffer end with a $0000
		mov 	r0,#tokenBuffer 			; return token buffer
		sknz 	r0 							; skip the clear
._TSFail
		clr 	r0							; come here if you fail.
		pop 	r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,link
		ret

; *****************************************************************************
;
;		Tokenise a single element @ R8. First char in R3. Buffer in R9.
;		Returns R0 #0 if error
;
; *****************************************************************************

.TokeniseElement
		push 	link
		;
		;		Identify whether it is punctuation, identifier (A-Z/.) or digit
		;
		mov 	r0,r3,#0 					; get character
		jsr 	#GetCharacterType 			; 0 punctuation 1 alphabet 2 number
		add 	r0,#_TEHandlerTable 		; address to jump to
		ldm 	r0,r0,#0 					; get branch address
		brl 	r15,r0,#0 					; and go there
		;
		;		Come back here depending on whether tokenisation succeeds or not.
		;
.TEExitOkay 								; come here if tokenised ok
		clr 	r0
		skz 	r0
.TEExitFail									; come here if failed.
		mov 	r0,#1 				
		pop 	link
		ret
		;
		;		Which handler do we go off and use
		;
._TEHandlerTable
		word 	TokenisePunctuation 		; 0 (punctuation)
		word 	TokeniseIdentKeyword		; 1 (identifier)
		word	TokeniseConstant 			; 2 (number)		

; *****************************************************************************
;
;							Tokenise a constant
;
; *****************************************************************************

;
;		Enter here with R2 = token R1 = base - for & and % prefixes
;
.TokeniseConstantBase
		stm 	r2,r9,#0					; write token out
		inc 	r9 	
		inc 	r8 							; skip over the token
		jmp 	#TCContinue 				; and skip over the start
;
;		Enter here for base 10
;
.TokeniseConstant
		mov 	r1,#10 						; by default, do base 10
.TCContinue		
		mov 	r10,r8,#0 					; this is the data source for the fetch function
		mov 	r0,#TokConstFetch 			; set up to fetch with helper function
		jsr 	#OSStrToInt 				; convert to integer
		skz 	r1 							; if error, fail
		jmp 	#TEExitFail
		;
		skm 	r0 							; if the result is 8000-FFFF need a constant shift
		jmp 	#_TCNoShift
		;
		mov 	r1,#TOK_VBARCONSTSHIFT 		; write constant shift out
		stm 	r1,r9,#0
		inc 	r9
._TCNoShift
		skm 	r0 							; if shifted bit 15 is already set
		add 	r0,#$8000		
		stm 	r0,r9,#0 					; write out as token with bit 15 set
		inc 	r9 							; skip over it.
		;
		mov 	r8,r10,#0 					; get the pointer back
		dec 	r8 							; we will have gone one too far.
		jmp 	#TEExitOkay 				; and return successfully.
;
;		Helper function for OSStrToInt
;				
.TokConstFetch
		ldm 	r0,r10,#0 					; get and bump next
		inc 	r10
		and 	r0,#$007F 					; strip it back
		ret

; *****************************************************************************
;
;								Handle punctuation
;
; *****************************************************************************

.TokenisePunctuation
		;
		;		Three special cases : %101010 &FE4A and "hello, world"
		;
		mov 	r0,r3,#0 					
		mov 	r1,#2 						; %<binary constant>
		mov 	r2,#TOK_PERCENT
		xor 	r0,#'%'
		sknz 	r0
		jmp 	#TokeniseConstantBase
		;		
		mov 	r1,#16 						; &<hex constant>
		mov 	r2,#TOK_AMPERSAND
		xor 	r0,#'%'^'&'
		sknz 	r0
		jmp 	#TokeniseConstantBase
		;
		xor 	r0,#'&'^'"'					; "<quoted string>"
		sknz 	r0
		jmp 	#TokeniseStringConstant
		;
		;		At this point we know it's normal punctuation
		;
		inc 	r8 							; advance past the punctuation marker
		ldm 	r0,r8,#0 					; look at the next character to see if it is punctuation
		and 	r0,r7,#0
		jsr 	#GetCharacterType 			; 0 punctuation 1 alphabet 2 number
		skz 	r0 							
		jmp 	#TokPuncCheckSingle
		;
		;		2 punctuation characters follow each other, so check to see if they exist
		; 		as a pair first (e.g. >= vs >)
		;
		ldm 	r0,r8,#0 					; get second again
		inc 	r8 							; advance incase successful		
		and 	r0,r7,#0 					; mask out characters
		ror 	r0,#8 						; shift to MSB
		add 	r0,r3,#0 					; <2nd>|<1st>
		jsr 	#TokPuncCheckExists 		; scan for this punctuation marker.
		skz 	r0 		 					; if found, write it out.					
		jmp 	#TokPuncWriteToken
		dec 	r8 							; unpick the advance past the second.
		;
		;		Check for a stand alone punctuation character
		;
.TokPuncCheckSingle
		mov 	r0,r3,#0 					; get the character back
		jsr 	#TokPuncCheckExists 		; scan for this punctuation marker.
		sknz 	r0 							; if not, we cannot tokenise this
		jmp 	#TEExitFail
		;
		;		Write the token in R0 out and exit
		;
.TokPuncWriteToken		
		stm 	r0,r9,#0
		inc 	r9
		jmp 	#TEExitOkay
;
;		Helper function. For the token in R0, set bit 15 (currently clear) and check the tokenise
;		table for that token, return token in R0 if found, 0 if not found
;		
.TokPuncCheckExists
		push 	r3,r4,r5
		mov 	r4,#TokeniserWords 			; R4 points into table
		mov	 	r3,r0,#0 					; R3 is the token to match
		add 	r3,#$8000 					; set bit 7 so token correct.
		clr 	r5 							; R5 is the base count.
._TPCELoop
		ldm 	r0,r4,#0 					; reached end of table
		sknz 	r0
		jmp 	#_TPCEExit 					; if so exit with R0 = 0
		;
		ldm 	r0,r4,#1 					; get the high-low token to see if they match
		xor 	r0,r3,#0 					; compare it
		sknz 	r0 							; if they match, then do the found code.
		jmp 	#_TPCEFound
		;
		ldm 	r0,r4,#0 					; get the type/size byte
		and 	r0,r7,#0 					; mask out the size
		add 	r4,r0,#1 					; advance to next (size does not include the t/s byte)
		inc 	r5 							; bump the counter
		jmp 	#_TPCELoop
		;
._TPCEFound
		ldm 	r0,r4,#0 					; found a match, get the type/size byte
		and 	r0,#$FF00 					; isolate the type
		add 	r0,r0,#0 					; shift into bits 9..13
		add 	r0,r5,#0 					; add the counter, the token base ID
		add 	r0,#$2000 					; and the base value for the tokens at 2000-3FFF
._TPCEExit				
		pop 	r3,r4,r5
		ret

; *****************************************************************************
;
;							Handle a string constant
;
; *****************************************************************************

.TokeniseStringConstant
		inc 	r8 							; advance past opening quote mark to first char of string.
		mov 	r6,r9,#0 					; save start in R6
		stm 	r14,r6,#1 					; start size in R6+1
		stm 	r14,r6,#2 					; zero first word.
		mov 	r5,r6,#2 					; R5 is the write pointer, where the next character goes
		;
		;		Get and write next character
		;		 					
.TokStringLoop		
		ldm 	r0,r8,#0 					; get next character
		and 	r0,r7,#0
		sknz 	r0 							; if zero, line end so we failed as no matching closing quote
		jmp 	#TEExitFail
		xor 	r0,#34						; found closing quote
		sknz 	r0
		jmp 	#TokStringComplete 			; we are done.
		;
		ldm 	r1,r6,#1 					; get the actual length so far
		inc 	r1 							; increment it and write back
		stm 	r1,r6,#1
		ror 	r1,#1 						; R1 is now -ve if this is odd. e.g. char 0,2,4,6,8
		;
		ldm 	r0,r8,#0 					; get next character back
		and 	r0,r7,#0
		inc 	r8 							; skip it.
		skm 	r1 							; for even characters 1,3,5
		ror 	r0,#8 						; shift it into the upper byte.
		;
		ldm 	r2,r5,#0 					; add to current word
		add 	r2,r0,#0
		stm 	r2,r5,#0
		stm 	r14,r5,#1 					; clear the next word.
		skm 	r1 							; for even characters, advance to the next word.
		inc 	r5
		jmp 	#TokStringLoop

.TokStringComplete
		inc 	r8 							; advance past the closing quote.
		ldm 	r0,r6,#1 					; get the count.
		and 	r0,#1 						; if it is odd, advance to next - this is padding with $00
		skz 	r0
		inc 	r5
		;
		mov 	r9,r5,#0 					; advance token buffer pointer to next slot.
		sub 	r5,r6,#0 					; this it the overall length
		add 	r5,#$0100 					; make it a string token
		stm 	r5,r6,#0 					; write in the first word
		and 	r5,#$FF00 					; check it hasn't overflowed
		xor 	r5,#$0100
		skz 	r5
		jmp 	#TEExitFail 				; if so it has failed to tokenise, string too long
		jmp 	#TEExitOkay

; *****************************************************************************
;
;						Tokenise an identifier/keyword
;
; *****************************************************************************

.TokeniseIdentKeyword
		;
		;		First, we extract the alphanumeric/dot part of the identifier
		;
		mov 	r6,r9,#0 					; R6 is the start of the identifier in the tokeniser buffer.
		clr 	r5 							; R5 is the first/second byte flag.
		stm 	r14,r9,#0 					; zero first byte of identifier.
._TIKBuildIdent		
		ldm 	r0,r8,#0 					; look at the next token
		and 	r0,r7,#0
		jsr 	#OSUpperCase 				; capitalise it.
		mov 	r3,r0,#0 					; save in R3
		;
		mov		r1,#37 						; 37 is code for '.'
		xor 	r0,#'.'						; which has handled seperately.
		sknz 	r0
		jmp 	#_TIKHaveCharacter
		;
		mov 	r0,r3,#0					; get character back
		jsr 	#GetCharacterType 			; 0 punctuation 1 alphabet 2 number
		sknz 	r0 							; end of identifier
		jmp 	#_TIKHaveIdent
		;
		mov		r1,r3,#0 					; R1 = original character
		sub 	r1,#64 						; adjust for A-Z : 1-26
		dec 	r0 							; if R0 is number, e.g. 2
		skz 	r0
		add 	r1,#64-48+27 				; adjust for 0-9 27-36
		;
		;		Have the converted character in R1
		;
._TIKHaveCharacter
		skz 	r5 							; if it's character 2 multiply it by 40
		mult 	r1,#40
		ldm 	r0,r9,#0 					; add into the current word
		add 	r0,r1,#0
		stm 	r0,r9,#0
		stm 	r14,r9,#1 					; clear next word
		skz 	r5 							; if it's character 2 bump the write pointer
		inc 	r9
		xor 	r5,#1 						; toggle first/second flag
		inc 	r8 							; next source and go round
		jmp 	#_TIKBuildIdent
		;
		;		Have the identifier at R6 .. R9, except for the last if odd.
		;
._TIKHaveIdent
		skz 	r5  						; if just written the low byte only, then go to next								
		inc 	r9 
		;
		dec 	r9 							; set the last bit of the identifier flag (bit 13)
		ldm 	r0,r9,#0 					; on the last word of the identifier.
		add 	r0,#$2000
		stm 	r0,r9,#0
		inc 	r9
		;
		;		Now type it. Checking for $ and then (. Identifier is R6..R9-1
		;
		mov 	r5,#$4000 					; we set these bits anyway, as they identify the identifier.
		;
		ldm 	r0,r8,#0 					; look at next, check if $
		and 	r0,r7,#0
		xor 	r0,#'$'
		sknz 	r0
		add 	r5,#$1000 					; if so set bit 11
		sknz 	r0
		inc 	r8
		;
		ldm 	r0,r8,#0 					; look at next, check if (
		and 	r0,r7,#0
		xor 	r0,#'('
		sknz 	r0
		add 	r5,#$0800 					; if so set bit 10
		sknz 	r0
		inc 	r8
		;
		mov 	r1,r6,#0 					; now apply that addition to the whole identifier.
._TIKApplyTyping
		ldm 	r0,r1,#0 					; add to the word
		add 	r0,r5,#0
		stm 	r0,r1,#0
		inc 	r1 							; next word
		mov 	r0,r1,#0 					; loop back if not at end.
		xor 	r0,r9,#0
		skz 	r0
		jmp 	#_TIKApplyTyping		
		;
		;		Now there is a fully fledged identifier with all the bits set from R6 .. R9-1
		;		Check if it is a token.
		;
		mov 	r4,#TokeniserWords 			; R4 points into table
		mov 	r5,r9,#0 					; R5 contains the identifier length which we can use to speed up.
		sub 	r5,r6,#0
		clr 	r11 						; R11 counts the tokens we've read.
._TIKCheckIdentifier
		ldm 	r0,r4,#0 					; read type/size byte
		sknz 	r0 							; if it is zero, leave things as they are, e.g. the identifier as is
		jmp 	#TEExitOkay
		;
		and 	r0,r7,#0 					; get the word length into R0
		mov 	r3,r0,#0 					; save in R3
		xor 	r0,r5,#0 					; is it the same as the token we have ?
		skz 	r0
		jmp 	#_TIKNext
		;
		;		Lengths match so compare token at R6 with that at R4+1, length R5
		;
		mov 	r1,r6,#0 					; R1, R2 are the pointers
		mov 	r2,r4,#1  					; R3 contains the word length.
._TIKCheckWord
		ldm 	r0,r1,#0 					; compare [R1][R2]
		ldm 	r10,r2,#0
		xor 	r0,r10,#0
		skz 	r0 							; different, go to next
		jmp 	#_TIKNext
		inc 	r1 							; bump pointers
		inc 	r2
		dec 	r3 							; do R3 words
		skz 	r3
		jmp 	#_TIKCheckWord
		;
		;		We have a token. R4 points to its type/size, R11 is the token ID
		;
		ldm 	r0,r4,#0 					; found a match, get the type/size byte
		and 	r0,#$FF00 					; isolate the type
		add 	r0,r0,#0 					; shift into bits 9..13
		add 	r0,r11,#0 					; add the counter, the token base ID
		add 	r0,#$2000 					; and the base value for the tokens at 2000-3FFF
		mov 	r9,r6,#0 					; throw away the identifier and write the token
		stm 	r0,r9,#0 					
		stm 	r14,r9,#1  					; write a following $0000
		inc 	r9
		jmp 	#TEExitOkay 				; and exit successfully
		;
		;		Look at next token.
		;
._TIKNext
		ldm 	r0,r4,#0 					; get type/size
		and 	r0,r7,#0 					; isolate size
		add 	r4,r0,#1 					; go to next record
		inc 	r11 						; one more token
		jmp 	#_TIKCheckIdentifier

; *****************************************************************************
;
;			Support routine, compares null terminated lists at R0/R1
;
; *****************************************************************************

.CompareR0R1
		ldm 	r2,r0,#0
		ldm 	r3,r1,#0
		inc 	r0
		inc 	r1
		xor		r2,r3,#0
		skz 	r2
		break
		skz 	r3
		jmp 	#CompareR0R1
		ret
		
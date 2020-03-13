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
		push 	r3,r7,r8,r9,link
		mov 	r9,#tokenBuffer 			; tokenised code goes here.
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
		pop 	r3,r7,r8,r9,link
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
		word 	SyntaxError 				; 1 (identifier)
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
		break

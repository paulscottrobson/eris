; *****************************************************************************
; *****************************************************************************
;
;		Name:		ustring.asm
;		Purpose:	Unary String functions
;		Created:	4th March 2020
;		Reviewed: 	17th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;									Val( 
;
; *****************************************************************************

.Unary_Val		;; [val(]
.Unary_Val2		;; [to.number(]
		push 	link
		jsr 	#EvaluateString 			; get string into R0.
		jsr 	#ValStrGetBase 				; optional base default 10
		jsr 	#CheckRightBracket 			; check there's a right bracket
		;
		jsr 	#CompactStringToInteger		; convert to integer
		skz 	r1 							; error
		jmp 	#BadNumberError
		;
._ValExit		
		stm 	r0,r10,#esValue1 			; save value
		stm 	r14,r10,#esType1 			; it's an integer constant
		stm	 	r14,r10,#esReference1
		;
		pop 	link
		ret

; *****************************************************************************
;
;					Check if number, similar code to val()
;
; *****************************************************************************

.Unary_IsNumber 	;; [is.number(]
		push 	link
		jsr 	#EvaluateString 			; get string into R0.
		jsr 	#ValStrGetBase 				; optional base default 10
		jsr 	#CheckRightBracket 			; check there's a right bracket
		;
		jsr 	#CompactStringToInteger		; convert to integer
		clr 	r0
		sknz 	r1 							; zero if error
		mov 	r0,#-1
		jmp 	#_ValExit

; *****************************************************************************
;
;		Support function which returns base in R1 10 or n if ,n in tokens
;
; *****************************************************************************

.ValStrGetBase
		push	r0,link
		ldm 	r0,r11,#0 					; check comma
		xor 	r0,#TOK_COMMA
		mov 	r1,#10 						; 10 if nothing
		skz 	r0
		jmp 	#_VSGBExit		
		inc 	r11 						; skip comma
		jsr 	#EvaluateInteger 			; get the base
		mov 	r1,r0,#0 
		sub 	r0,#2 						; range 2..17
		skge
		jmp 	#BadNumberError
		sub 	r0,#15
		sklt 	
		jmp 	#BadNumberError
._VSGBExit
		pop 	r0,link
		ret

; *****************************************************************************
;
;		Convert compact string at R0 in base R1, returns R0 value R1 error
;
; *****************************************************************************

.CompactStringToInteger
		push 	r9,r10,r11,link 			; these are temp reg for string extraction
		clr 	r11 						; R11 is 0 (low) #0 (high)
		mov 	r10,r0,#1 					; R10 is the string itself.
		ldm 	r9,r0,#0 					; R9 is the character count.
		mov 	r0,#StringExtract 			; this is the function that gets the characters
		jsr 	#OSStrToInt 				; convert to integer
		pop 	r9,r10,r11,link
		ret

; *****************************************************************************
;
;		    			String extractor function. 
;				State is in R9 (count) R10 (ptr) R11 (half)
;
; *****************************************************************************

.StringExtract
		clr 	r0 							; if count is zero, return zero
		sknz 	r9
		ret
		;
		dec 	r9 							; decrement count
		ldm 	r0,r10,#0 					; read the next character
		skz 	r11 						; if it is the upper half (r11 != 0)
		ror 	r0,#8 						; swap the bytes.
		and 	r0,#$00FF 					; mask the character off.
		;
		xor 	r11,#1 						; toggle the half.
		sknz 	r11 						; if it has gone from 1->0 bump ptr
		inc 	r10
		ret

; *****************************************************************************
;
;								Chr$(
;
; *****************************************************************************

.Unary_Chr		;; [chr$(]
		push 	link
		jsr 	#EvaluateInteger 			; get integer into R0.
		jsr 	#CheckRightBracket 			; check there's a right bracket
		and 	r0,#$00FF 					; make 8 bit value.
.UnaryReturnCharacter
		mov 	r1,r0,#0 					; save character in R0		
		mov 	r0,#2 						; allocate space for 2 words
		jsr 	#AllocateTempMemory 		; this address -> R0
		stm 	r1,r0,#1 					; write the character out.
		mov 	r1,#1 						; set the length
		stm 	r1,r0,#0
.UnaryReturnR0		
		stm 	r0,r10,#esValue1 			; make it a constant string
		stm 	r15,r10,#esType1
		stm 	r14,r10,#esReference1
		pop 	link 						; and exit
		ret

; *****************************************************************************
;
;				Get$( Inkey$( are Get/Inkey with conversion
;
; *****************************************************************************

.Unary_GetString	;; [get$(]
		push 	link
		jsr 	#Unary_Get
		ldm 	r0,r10,#esValue1
		jmp 	#UnaryReturnCharacter

.Unary_InkeyString	;; [inkey$(]
		push 	link
		jsr 	#Unary_Inkey
		ldm 	r0,r10,#esValue1
		skz 	r0 							; no character available return ""
		jmp 	#UnaryReturnCharacter
		mov 	r0,#_UISNullString
		jmp 	#UnaryReturnR0
._UISNullString
		word 	0

; *****************************************************************************
;
;							Convert Integer to String
;
; *****************************************************************************

.Unary_Str		;; [str$(]
.Unary_Str2		;; [to.string$(]
		push 	link
		jsr 	#EvaluateInteger 			; get integer into R0.
		jsr 	#ValStrGetBase 				; optional base default 10
		jsr 	#CheckRightBracket 			; check there's a right bracket

		mov 	r2,r1,#0 					; if base 10 print as signed
		xor 	r2,#10
		sknz 	r2
		add 	r1,#$8000 					
		jsr 	#OSIntToStr
		;
		mov 	r1,r0,#0 					; source to copy in R1 - copy so str$(x)+str$(x) works :)
		mov 	r0,#maxIStrSize 			; allocate memory for the copy
		jsr 	#AllocateTempMemory 		; R0 now contains the target address for the copy
		stm 	r0,r10,#esValue1 			; make it a constant string with that address
		stm 	r15,r10,#esType1
		stm 	r14,r10,#esReference1
		mov 	r2,#maxIStrSize 			; count to copy
._USCopy	
		ldm 	r3,r1,#0 					; copy string over.
		stm 	r3,r0,#0
		inc 	r1
		inc 	r0
		dec 	r2
		skz 	r2
		jmp 	#_USCopy
		;		
		pop 	link 						; and exit
		ret

; *****************************************************************************
;
;							Upper/Lower case functions
;
; *****************************************************************************

.Unary_Upper 	;; [upper$(]
		clr 	r2 							; R2 = 0 => U/C
		skz 	r14
.Unary_Lower 	;; [lower$(]
		mov 	r2,#1
		push 	link
		jsr 	#EvaluateString 			; R0 = string address
		jsr 	#CheckRightBracket
		mov 	r1,r0,#0 					; copy to R1
		jsr 	#OSWordLength 				; number of words in string.
		mov 	r3,r0,#0  					; save in R3
		inc 	r0 							; add one to allow for length word
		jsr 	#AllocateTempMemory 		; allocate space for it
		mov 	r4,r0,#0 					; put in R4
		stm 	r4,r10,#esValue1 			; save as return value
		;
		ldm 	r0,r1,#0 					; copy length
		stm 	r0,r4,#0
._UCaseLoop
		sknz 	r3 							; finished ?
		jmp 	#_UCaseExit
		dec 	r3 							; decrement count.
		inc 	r1 							; next characters
		inc 	r4		
		;
		ldm 	r0,r1,#0 					; do lower character
		sknz 	r2
		jsr 	#OSUpperCase
		skz 	r2
		jsr 	#OSLowerCase
		mov 	r5,r0,#0 					; save in R5
		;
		ldm 	r0,r1,#0 					; do upper character
		ror 	r0,#8
		sknz 	r2
		jsr 	#OSUpperCase
		skz 	r2
		jsr 	#OSLowerCase
		ror 	r0,#8 						; back into position
		add 	r0,r5,#0 					; build compressed string
		stm 	r0,r4,#0
		jmp 	#_UCaseLoop 				; and go around.
._UCaseExit
		pop 	link
		ret

		
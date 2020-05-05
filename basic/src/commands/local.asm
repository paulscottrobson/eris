; *****************************************************************************
; *****************************************************************************
;
;		Name:		local.asm
;		Purpose:	Local Handler
;		Created:	21st March 2020
;		Reviewed: 	TODO
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;								LOCAL Command
;
; *****************************************************************************

.Command_Local		;; [local]
		push 	link
._CLOLoop
		mov 	r4,r11,#0 					; save start of identifier.
		mov 	r0,#1 						; clear local variable
		jsr 	#LocalPushReference 		; push a variable reference
		ldm 	r0,r11,#0 					; are we followed by a comma
		inc 	r11 						; skip over it - may be undone.
		xor 	r0,#TOK_COMMA
		sknz 	r0 							; if not get another variable
		jmp 	#_CLOLoop
		xor 	r0,#TOK_COMMA^TOK_EQUAL 	; check for =
		dec 	r11 						; undo the comma increment
		skz 	r0
		jmp 	#_CLOExit
		;	
		mov 	r11,r4,#0 					; should now be x = 42
		jsr 	#Command_Let 				; use the LET code.
._CLOExit		
		pop 	link
		ret

; *****************************************************************************
;
;							Reset local stack. 
;
; *****************************************************************************

.LocalReset
		ldm 	r0,#localStackTop 			; reset the local stack
		stm 	r0,#localStackPtr
		mov 	r1,#-1
		stm 	r1,r0,#0 					; write $FFFF as the top stack marker.
											; [lsp] always points to the last marker.
		ret 								; and the stack top.

; *****************************************************************************
;
;				Start new local frame by pushing $00 on the stack
;		
; *****************************************************************************

.LocalNewFrame
		push 	link
		clr 	r0 							; push zero marking the end of a local frame
		jsr 	#LocalPush 
		pop 	link
		ret

; *****************************************************************************
;
;								Push R0 on stack
;
; *****************************************************************************

.LocalPush
		push 	r1
		ldm 	r1,#localStackPtr
		dec 	r1
		stm 	r0,r1,#0
		stm 	r1,#localStackPtr
		pop 	r1
		ret

; *****************************************************************************
;
;			R11 points to a local variable or a parameter. This must be
;			a non array. Identify it, push its current value on the locals
;			stack and set it to either "" or 0 according to type.
;
;			On exit R10, the evaluation stack, holds the reference/type/value
;			as normal.
;
; *****************************************************************************

.LocalPushReference
		push 	r4,link
		mov 	r4,r0,#0 					; save clear flag in R4
		ldm 	r0,r11,#0 					; check it is an identifier and not an array
		and 	r0,#$4800 					; 01 is identifier, bit 11 is array flag
		xor 	r0,#$4000
		skz 	r0
		jmp 	#TypeMismatchError
		;
		stm 	r14,#reportUnknownVariable 	; permit definitions
		mov 	r9,#(TOK_PLING & 0x1E00)-0x400
		jsr 	#Evaluator 					; get the lhs, which should be a reference
		stm 	r15,#reportUnknownVariable 	; turn permission off
		;	
		ldm 	r0,r10,#esReference1 		; check it is a reference
		sknz 	r0
		jmp	 	#TypeMismatchError
		;
		ldm 	r0,r10,#esType1 			; is it a string or an integer ?
		skz 	r0
		jmp 	#_LPRSString
		;
		;		Push integer and set old to zero.
		;
		ldm 	r1,r10,#esValue1 			; this is a reference
		ldm 	r0,r1,#0 					; get value at reference
		jsr 	#LocalPush 					; push value first
		mov 	r0,r1,#0
		jsr 	#LocalPush 					; push reference
		mov 	r0,#$7FFF					; push $7FFF indicating integer
		jsr 	#LocalPush
		;
		skz 	r4 							; only if clearing new local
		stm 	r14,r1,#0 					; set the new local variable to zero
		jmp 	#_LPRSExit
		;
		;		Push string
		;
._LPRSString
		ldm 	r0,r10,#esValue1 			; get address of string in R1
		ldm 	r1,r0,#0 					; as it is a reference.
		mov 	r0,r1,#0 					; get the word length
		jsr 	#OSWordLength 				; number of words to write into R2, also the marker.
		mov 	r2,r0,#1 					; and also R3 as a count - must be > 0
		mov 	r3,r0,#1 					; we add one to allow for the length word which goes too.
._LPRSSaveString
		ldm 	r0,r1,#0 					; save a value
		jsr 	#LocalPush
		inc 	r1
		dec		r3
		skz 	r3
		jmp 	#_LPRSSaveString
		mov 	r0,r2,#0 					; book end it with the string.
		jsr 	#LocalPush
		;
		ldm 	r0,r10,#esValue1 			; address of string variable
		jsr 	#LocalPush 					; e.g. where the string has come from
		mov 	r1,#_LPRSNulLString 		; default string value
		skz 	r4 							; only if clearing new local
		stm 	r1,r0,#0
		;
		ldm 	r0,#localStackPtr
._LPRSExit		
		pop 	r4,link
		ret

._LPRSNulLString
		word 	0

; *****************************************************************************
;
;				Restore locals and parameters off the local stack
;
; *****************************************************************************

.LocalRestoreFrame
		ldm 	r8,#localStackPtr 			; R8 points to the local stack
._LRFLoop
		ldm 	r0,r8,#0 					; get next entry
		inc 	r8 							; bump and write back
		stm 	r8,#localStackPtr
		sknz 	r0 							; if found 0, e.g. the zero marker, then complete
		ret
		xor 	r0,#$7FFF 					; check for integer marker ($7FFF)
		skz 	r0
		jmp 	#_LRFTryString
		;
		;		Pop an integer off the local stack.
		;		
		ldm 	r1,r8,#0 					; address
		ldm 	r0,r8,#1 					; data
		stm 	r0,r1,#0 					; set data back
		add 	r8,#2 						; pop off stack
		jmp 	#_LRFLoop
		;
		;		Pop a string off the local stack.
		;
._LRFTryString
		dec 	r8
		ldm 	r3,r8,#0 					; get the target address into R3.
		ldm 	r3,r3,#0 					; de reference it
		ldm 	r1,r8,#1 					; get the count to copy into R1
		mov 	r2,r8,#0 					; get the first word to copy into R2
		add 	r2,r1,#1 					; we wrote it out backwards
		add 	r8,r1,#2 					; make R8 point to the next element.
._LRFSCopy
		ldm 	r0,r2,#0 					; get the next character, going backwards		
		stm 	r0,r3,#0 					; write out
		dec 	r2
		inc 	r3
		dec 	r1
		skz 	r1
		jmp 	#_LRFSCopy 					; until the whole string is done.
		jmp 	#_LRFLoop 					; go do the next one


		break		
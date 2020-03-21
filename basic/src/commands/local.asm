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
._CLLoop
		jsr 	#LocalPushReference 		; push a variable reference
		ldm 	r0,r11,#0 					; are we followed by a comma
		inc 	r11 						; skip over it - may be undone.
		xor 	r0,#TOK_COMMA
		sknz 	r0 							; if not get another variable
		jmp 	#_CLLoop
		dec 	r11 						; undo the comma increment
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
; *****************************************************************************

.LocalPushReference
		push 	link
		ldm 	r0,r11,#0 					; check it is an identifier and not an array
		and 	r0,#$4800 					; 01 is identifier, bit 11 is array flag
		xor 	r0,#$4000
		skz 	r0
		jmp 	#TypeMismatchError
		;
		mov 	r9,#(TOK_PLING & 0x1E00)-0x400
		jsr 	#Evaluator 					; get the lhs, which should be a reference
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
		mov 	r0,#1						; push 1 indicating integer
		jsr 	#LocalPush
		stm 	r14,r1,#0 					; set the new local variable to zero
		jmp 	#_LPRSExit
		;
		;		Push string
		;
._LPRSString
		break

._LPRSExit		
		pop 	link
		ret

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
		dec 	r0 	
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
		break		
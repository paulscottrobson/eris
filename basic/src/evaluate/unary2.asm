; *****************************************************************************
; *****************************************************************************
;
;		Name:		unary2.asm
;		Purpose:	More Basic unary functions
;		Created:	16th March 2020
;		Reviewed: 	17th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;				Page returns a reference to the program Code word
;
; *****************************************************************************

.Command_Page	 ;; [page]
		mov 	r0,#programCode
		stm 	r0,r10,#esValue1 			; update value
		stm 	r14,r10,#esType1 			; make integer *reference*
		stm 	r15,r10,#esReference1			
		ret

; *****************************************************************************
;
;				 SysVar(n) returns a system variable value
;
; *****************************************************************************

.Command_SysVar 	;; [sysvar(]
		push 	link
		jsr 	#EvaluateInteger 			
		jsr 	#OSReadSystemVariable
		jmp 	#_JoyExit
		
; *****************************************************************************
;
;							Joystick axis functions
;
; *****************************************************************************

.Command_Jx 	;; [joyx(]	
		clr 	r2 							; shift of joystick read value
		skz 	r2
.Command_Jy		;; [joyy(]
		mov 	r2,#2	
		push 	link
		jsr 	#OSReadJoystick 			; read and shift joystick
		ror 	r0,r2,#0	 				; now in bits 0..1
		and 	r0,#3 						; 0 no press. 1 left 2 right
		add 	r0,r0,#0 					; 0 no press 2 left 4 right
		sknz 	r0
		mov 	r0,#3 						; now 2 3 4
		sub 	r0,#3 						; now -1 0 1
._JoyExit		
		stm 	r0,r10,#esValue1 			; update value
		stm 	r14,r10,#esType1 			; make integer constant
		stm 	r14,r10,#esReference1			
		jsr 	#CheckRightBracket 			; check there's a right bracket
		pop 	link
		ret

; *****************************************************************************
;
;							Joystick button function
;
; *****************************************************************************

.Command_JButton ;; [joyb(]
		push 	link
		jsr 	#EvaluateInteger 			; must be 1 or 2
		dec 	r0 							; 0 or 1
		mov 	r1,r0,#0 					
		sub 	r0,#2
		sklt
		jmp 	#BadNumberError 			
		jsr 	#OSReadJoystick 			; read and shift joystick
		ror 	r0,r1,#4 					; by 4 or 5
		and 	r0,#1 						; 0 or 1
		skz 	r0
		sub 	r0,#2 						; 0 or -1
		jmp 	#_JoyExit


; *****************************************************************************
;
;							Allocate low memory
;
; *****************************************************************************

.Unary_Alloc ;; [alloc(]
		push 	link
		jsr 	#EvaluateInteger 			; how much ?
		jsr 	#CheckRightBracket
		ldm 	r1,#memAllocBottom 			; R1 = address
		add 	r0,r1,#0 					; add to and update low memory
		stm 	r0,#memAllocBottom
		stm 	r1,r10,#esValue1 			; set return
		stm 	r14,r10,#esType1 			; make integer constant
		stm 	r14,r10,#esReference1			
		sknc 	
		jmp 	#MemoryError
		ldm	 	r2,#memAllocTop 			; check hit top memory
		sub 	r1,r2,#0
		sklt 	
		jmp 	#MemoryError
		;
		pop 	link
		ret

; *****************************************************************************
;
;								Key press check
;
; *****************************************************************************

.Unary_Key 	;; [key(]
		push 	link
		jsr 	#EvaluateInteger 			; key to check.
		jsr 	#CheckRightBracket 

		mov 	r1,r0,#0 					; R1 is rotation of $8000 for the row on diagram
		ror 	r1,#4
		and 	r1,#15
		xor 	r1,#15

		and 	r0,#15 						; R0 is rotation of $8000 for the col on diagram
		xor 	r0,#15

		mov 	r2,#$8000 					; put the bit to write out in R2, the mask in R3
		mov 	r3,r2,#0
		ror 	r2,r1,#0
		ror 	r3,r0,#0

		stm 	r2,#keyboardPort 			; read the keyboard
		ldm 	r0,#keyboardPort
		and 	r0,r3,#0 					; check if pressed
		skz 	r0
		mov 	r0,#-1 						; return -1
		stm 	r0,r10,#esValue1 			; set return value in R0, type already int val.
		pop 	link
		ret

; *****************************************************************************
;
;							event(<var>,<time>)
;
; *****************************************************************************
;
;		Returns true every <time> 1/100s
;
.Unary_Event 	;; [event(]
		push 	link
		mov 	r9,#(TOK_PLING & 0x1E00)-0x400
		jsr 	#Evaluator 					; get a reference.
		ldm 	r0,r10,#esReference1 		; it *must* be a reference
		sknz 	r0 							; which is a variable/array or a !expression
		jmp 	#SyntaxError 	
		ldm 	r0,r10,#esType1 			; and it must be an integer.
		skz 	r0
		jmp 	#TypeMismatchError
		ldm 	r1,r10,#esValue1 			; get the variable address into R1
		;
		jsr 	#CheckComma
		jsr 	#EvaluateInteger 			; get the time elapsed betwen into R0
		jsr 	#CheckRightBracket
		;
		ldm 	r2,r1,#0 					; get current value
		inc 	r2 							; if -1 then fail automatically, on hold.
		sknz 	r2
		jmp 	#_UEVFail
		;
		ldm 	r2,#hwTimer 				; get the current timer
		ldm 	r3,r1,#0 					; get the variable
		sknz 	r3 							; if it is zero initialise it.
		jmp 	#_UEVStart
		;	
		sub 	r2,r3,#0		
		skp 	r2 							; has it timed out e.g. timer >= variable.
		jmp 	#_UEVFail
		;
		add 	r3,r0,#0 					; add the elapsed time to the variable value
		stm 	r3,r1,#0 					; and write it back
		inc 	r3 							; if -1, then fudge it to zero.
		sknz 	r3
		stm 	r3,r1,#0
		;
._UEVFire
		mov 	r0,#-1 						; return true
		jmp 	#_UEVExit
._UEVStart		
		add 	r2,r0,#0 					; add required time to timer
		stm 	r2,r1,#0 					; write it back
._UEVFail
		clr 	r0 							; return zero		
._UEVExit		
		stm 	r0,r10,#esValue1 			; set return value in R0, type already int val.
		pop 	link
		ret

; *****************************************************************************
;
;									min and max
;
; *****************************************************************************

.Unary_Min		;; [min(]
		clr 	r2
		skz 	r2
.Unary_Max 		;; [max(]
		mov 	r2,#1
		push	r3,r4,link
		jsr 	#EvaluateInteger 
		mov 	r1,r0,#0
		jsr 	#CheckComma
		jsr 	#EvaluateInteger 
		jsr 	#CheckRightBracket
		mov 	r3,r1,#0
		mov 	r4,r0,#0
		add 	r3,#$8000					; signed compare
		add 	r4,#$8000
		skz 	r2
		sub 	r4,r3,#0
		sknz 	r2
		sub 	r3,r4,#0
		stm 	r0,r10,#esValue1
		skc
		stm 	r1,r10,#esValue1
		pop 	r3,r4,link
		ret
		
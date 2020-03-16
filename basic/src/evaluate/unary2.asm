; *****************************************************************************
; *****************************************************************************
;
;		Name:		unary2.asm
;		Purpose:	More Basic unary functions
;		Created:	16th March 2020
;		Reviewed: 	TODO
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

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


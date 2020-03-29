; *****************************************************************************
; *****************************************************************************
;
;		Name:		sprite.asm
;		Purpose:	Sprite commands
;		Created:	27rd March 2020
;		Reviewed: 	TODO
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;								Sprite commands
;
; *****************************************************************************

.Command_Sprite 	;; 	[sprite]
		push 	link
		ldm 	r0,r11,#0 					; check for sprite load
		xor 	r0,#TOK_LOAD
		skz 	r0
		jmp 	#_CSpriteNumber
		inc 	r11 						; skip load token
		jsr 	#EvaluateString 			; file name.
		mov 	r1,r0,#0 					; put in R1
		mov 	r0,#2 						; force load to address
		ldm 	r2,#spriteImageMemory		; R2 = load address
		jsr 	#OSFileOperation 			; do load
		skz 	r0 				
		jmp 	#LoadError 					; error if failed
._CSpriteExit		
		pop 	link 						; exit
		ret
		;
		;		Sprites command, so get sprite number
		;
._CSpriteNumber
		ldm 	r0,#spriteMask 				; check there is a sprite plane !
		sknz 	r0
		jmp 	#NoSpritePlaneError
		;
		jsr 	#EvaluateInteger
		jsr 	#OSSpriteSelect 			; make that one current
		skz 	r0
		jmp 	#BadNumberError 			; bad sprite #
		;
		;		New command here
		;
._CSpriteCommand		
		ldm 	r0,r11,#0 					; get next token
		inc 	r11 						; bump over it
		xor 	r0,#TOK_TO 	 				; sprite move
		sknz 	r0
		jmp 	#_CSpriteMove
		xor 	r0,#TOK_TO^TOK_DRAW 		; sprite set graphic
		sknz 	r0
		jmp 	#_CSpriteDraw
		xor 	r0,#TOK_DRAW^TOK_INK 		; sprite set colour
		sknz 	r0
		jmp 	#_CSpriteInk
		xor 	r0,#TOK_FLIP^TOK_INK 		; sprite set flip
		sknz 	r0
		jmp 	#_CSpriteFlip
		jmp 	#SyntaxError
		;
		;		MOVE x,y
		;
._CSpriteMove
		jsr 	#EvaluateInteger 			; coordinates to R0,R1
		mov 	r2,r0,#0
		jsr 	#CheckComma
		jsr 	#EvaluateInteger
		mov 	r1,r0,#0
		mov 	r0,r2,#0
		jsr 	#OSSpriteMove	 			; set sprite position
._CSpriteCheckExit		
		skz 	r0
		jmp 	#BadNumberError
		ldm 	r0,r11,#0					; what follows ?
		sknz 	r0
		jmp 	#_CSpriteExit 				; exit if EOL
		xor 	r0,#TOK_COLON 				; exit if colon
		sknz 	r0
		jmp 	#_CSpriteExit
		jmp 	#_CSpriteCommand 			; otherwise chain commands
		;
		;		DRAW n
		;
._CSpriteDraw		
		jsr 	#EvaluateInteger
		jsr 	#OSSpriteSetImage
		jmp 	#_CSpriteCheckExit
		;
		;		INK n
		;		
._CSpriteInk
		jsr 	#EvaluateInteger
		jsr 	#OSSpriteSetColour
		jmp 	#_CSpriteCheckExit
		;
		;		FLIP n
		;		
._CSpriteFlip
		jsr 	#EvaluateInteger
		jsr 	#OSSpriteSetOrientation
		jmp 	#_CSpriteCheckExit

;SPRITE LOAD "" 			- load sprite data
;SPRITE 1 TO x,y 		- move sprite
;SPRITE 1 DRAW 12 		- set graphic #
;SPRITE 1 INK 4 			- set colour #
;SPRITE 1 FLIP n 		- set sprite flip bits

; *****************************************************************************
;
;								Hit (n1,n2)
;
; *****************************************************************************

.Unary_Hit		;; [hit(]
		push 	link
		jsr 	#EvaluateInteger 			; first sprite
		mov 	r3,r0,#0 					; save in R3
		jsr 	#CheckComma
		jsr 	#EvaluateInteger 			; second sprite
		mov 	r1,r0,#0 					; -> R1
		mov 	r2,#15 						; default box size 
		;
		ldm 	r0,r11,#0 					; check if followed by comma
		xor 	r0,#TOK_COMMA
		skz 	r0
		jmp 	#_UHHaveParameters 			; if not use default parameters
		inc 	r11							; step over comma
		jsr 	#EvaluateInteger 			; get box size -> R2
		mov 	r2,r0,#0
._UHHaveParameters
		jsr 	#CheckRightBracket 			; right bracket
		mov 	r0,r3,#0 					; R0 R1 sprites, R2 box size.
		jsr 	#OSSpriteCollision 			; check sprite collision.		
		mov 	r2,r0,#0 					; check for error
		xor 	r2,#1 						; which is 1.
		sknz 	r2
		jmp 	#BadNumberError 			; bad values.

		stm 	r0,r10,#esValue1 			; return the collision result
		stm 	r14,r10,#esType1
		stm 	r14,r10,#esReference1
		pop 	link
		ret

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
		xor 	r0,#TOK_FLIP^TOK_DIM 		; sprite set size.
		sknz 	r0
		jmp 	#_CSpriteDim
		xor 	r0,#TOK_DIM^TOK_END 		; sprite end
		sknz 	r0
		jmp 	#_CSpriteEnd
		xor 	r0,#TOK_END^TOK_RUN 		; sprite run
		sknz 	r0
		jmp 	#_CSpriteRun
		xor 	r0,#TOK_RUN^TOK_STOP 		; sprite stop
		sknz 	r0
		jmp 	#_CSpriteStop
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
		;
		;		DIM n
		;
._CSpriteDim		
		jsr 	#EvaluateInteger
		jsr 	#OSSpriteSetSize
		jmp 	#_CSpriteCheckExit
		;
		;		END 
		;
._CSpriteEnd
		jsr 	#OSSpriteKill
		jmp 	#_CSpriteCheckExit
		;
		;		RUN
		;
._CSpriteRun
		jsr 	#EvaluateString				; get string
		;
		mov 	r1,r0,#0
		ldm 	r2,#memAllocBottom 			; if < memAllocBottom then in program
		sub 	r1,r2,#0
		skge
		jmp 	#_CSpriteRunOkay
		;
		mov 	r1,r0,#0
		ldm 	r2,#memAllocTop 			; if >= memAllocTop then concreted
		sub 	r1,r2,#0
		skge
		jmp 	#TypeMismatchError 			; if in the middle, it is workspace string.
._CSpriteRunOkay		
		skz 	r14
		;
		;		STOP
		;		
._CSpriteStop
		clr 	r0
		jsr 	#OSSpriteScript
		clr 	r0
		jmp 	#_CSpriteCheckExit

; *****************************************************************************
;
;								Hit (n1,n2,<range>)
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

; *****************************************************************************
;
;							Access Sprite Information
;	
; *****************************************************************************

.Unary_SpriteX 	;; [sprite.x(]
		clr 	r1
		sknz 	r15
.Unary_SpriteY 	;; [sprite.y(]
		mov 	r1,#spY
		sknz 	r15
.Unary_SpriteI 	;; [sprite.info(]
		mov 	r1,#spStatus
		push 	link
		;
		jsr 	#EvaluateInteger 			; get sprite #
		jsr 	#CheckRightBracket
		ldm 	r2,#spriteCount 			; check < count
		sub 	r0,r2,#0
		sklt 	r0
		jmp 	#BadNumberError
		add 	r0,r2,#0 					; fix back
		jsr 	#OSGetSpriteInfo			; get information
		;
		stm 	r0,r10,#esValue1 			; return the collision result
		stm 	r14,r10,#esType1
		stm 	r14,r10,#esReference1
		pop 	link
		ret

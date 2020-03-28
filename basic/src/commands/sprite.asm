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
		jsr 	#_UHGetOneSprite 			; get first sprite ato R2
		mov 	r2,r1,#0
		jsr 	#CheckComma 				; skip comma
		jsr 	#_UHGetOneSprite 			; get second sprite 
		sknz 	r1 							; exit if either not activated
		jmp 	#_UHFail
		sknz 	r2
		jmp 	#_UHFail
		;
		;		Check if r1 collides with r2.
		;
		ldm 	r0,r1,#spX 					; check difference + 8 < 16
		ldm 	r3,r2,#spX
		sub 	r0,r3,#0
		add 	r0,#8
		sub 	r0,#16
		sklt
		jmp 	#_UHFail
		;
		ldm 	r0,r1,#spY
		ldm 	r3,r2,#spY
		sub 	r0,r3,#0
		add 	r0,#8
		sub 	r0,#16
		sklt
		jmp 	#_UHFail
		;
		mov 	r0,#-1						; return -1 if hit
		sknz 	r0
._UHFail									; return 0 if missed
		clr 	r0
		stm 	r0,r10,#esValue1
		stm 	r14,r10,#esType1
		stm 	r14,r10,#esReference1
		jsr 	#CheckRightBracket 			; right bracket
		pop 	link
		ret
		;
		;		Get one parameter, check legal sprite #, check if active. Return R1 = 0 if not in use
		;		or address in R1
		;
._UHGetOneSprite
		push 	r2,link		
		jsr 	#EvaluateInteger
		mov 	r1,r0,#0 					; put sprite number in R1
		ldm 	r2,#spriteCount 			; check < sprite count
		sub 	r0,r2,#0
		sklt
		jmp 	#BadNumberError 			; error if not.
		;
		mult 	r1,#spriteRecordSize 		; multiply by spriterecord size and add address
		ldm 	r0,#spriteAddress
		add 	r1,r0,#0
		ldm 	r0,r1,#spStatus				; read status, exit if zero
		sknz 	r0 							; if zero clear R1 as its not in use
		clr 	r1
._UHGOSExit
		pop 	r2,link	
		ret

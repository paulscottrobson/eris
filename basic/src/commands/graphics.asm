; *****************************************************************************
; *****************************************************************************
;
;		Name:		graphics.asm
;		Purpose:	Simple Graphics keywords
;		Created:	18th March 2020
;		Reviewed: 	TODO
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;								CLS INK and PAPER
;
; *****************************************************************************

.Command_Cls		;; [cls]
		push 	link
		mov 	r0,#$FF00 					; erase the whole graphics memory				
		jsr 	#OSIFillScreen		
		mov 	r0,#12						; text cls
		jsr 	#OSPrintCharacter
		jsr 	#OSSpriteReset 				; reset sprites
		pop 	link
		ret

.Command_Ink 		;; [ink]
		push	link
		jsr 	#EvaluateInteger 			; get colour, must be 0-15
		mov 	r1,r0,#0
		and 	r1,#$FFF0
		skz 	r1
		jmp 	#BadNumberError
		add 	r0,#$10 					; make control
		jsr 	#OSPrintCharacter
		pop 	link
		ret

.Command_Paper		;; [paper]
		push 	link
		mov 	r0,#15 						; swap fgr/bgr
		jsr 	#OSPrintCharacter
		jsr 	#Command_Ink 				; set the ink colour
		mov 	r0,#15 						; swap fgr/bgr
		jsr 	#OSPrintCharacter
		pop 	link
		ret

; *****************************************************************************
;
;								SCREEN Mode setting
;
; *****************************************************************************

.Command_Screen 	;; 	[screen]
		push 	link
		jsr 	#EvaluateInteger 			; background planes
		mov 	r1,r0,#0
		and 	r0,#$FFF8
		skz 	r0
		jmp 	#BadNumberError
		;
		jsr 	#CheckComma
		;
		jsr 	#EvaluateInteger 			; sprite planes
		mov 	r2,r0,#0
		and 	r0,#$FFF8
		skz 	r0
		jmp 	#BadNumberError
		;
		ror 	r2,#8 						; sprite plane count in upper byte
		mov 	r0,r1,#0
		add 	r0,r2,#0 					; background in lower byte
		jsr 	#OSSetPlanes 				; set plane sizes
		pop 	link
		ret

; *****************************************************************************
;
;								BLIT command
;
; *****************************************************************************

.Command_Blit 	;; [blit]
		push 	link
		jsr 	#OSWaitBlitter 				; check it's not busy.
		jsr 	#EvaluateInteger  			; x
		stm 	r0,#blitterX
		jsr 	#CheckComma
		jsr 	#EvaluateInteger 			; y
		stm 	r0,#blitterY
		jsr 	#CheckComma
		jsr 	#EvaluateInteger  			; data or index
		mov 	r1,r0,#0
		and 	r1,#$FF00 					; is it 0-255 if so use sprite image.
		skz		r1
		jmp 	#_CBlitData
		mov 	r1,r0,#0 					; check legitimate value.
		ldm 	r2,#spriteImageCount 		
		sub 	r1,r2,#0
		sklt
		jmp 	#BadNumberError
		ror 	r0,#12 						; multiply by 16
		ldm 	r1,#spriteImageMemory		; and sprite image memory address
		add 	r0,r1,#0
._CBlitData		
		stm 	r0,#blitterData
		jsr 	#CheckComma
		jsr 	#EvaluateInteger 
		stm 	r0,#blitterCMask
		jsr 	#CheckComma
		jsr 	#EvaluateInteger 			; cmd
		stm 	r0,#blitterCmd
		pop 	link
		ret						


; *****************************************************************************
;
;						Palette <colour>,<plane>,<rgb>
;
; *****************************************************************************

.Command_Palette 	;; [palette]
		push 	link
		jsr 	#EvaluateInteger 			; colour -> R2
		mov 	r2,r0,#0
		jsr 	#CheckComma
		jsr 	#EvaluateInteger 			; target -> R3
		mov 	r3,r0,#0
		and 	r0,#$FFFE 					; check target is 0 or 1
		skz 	r0
		jmp 	#BadNumberError
		jsr 	#CheckComma
		jsr 	#EvaluateInteger 			; palette -> R1
		mov 	r1,r0,#0
		and 	r1,#7
		;
		mov 	r0,r2,#0 					; colour in R2, RGB value in R3
		sknz 	r3 							; if target = 0 do back plane		
		jsr 	#OSXSetBackPlanePalette
		skz 	r3 							; if target = 1 do front plane		
		jsr 	#OSXSetFrontPlanePalette
		pop 	link
		ret


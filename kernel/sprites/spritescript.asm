; *****************************************************************************
; *****************************************************************************
;
;		Name:		spritescript.asm
;		Purpose:	Sprite Scripting Code
;		Created:	6th May 2020
;		Reviewed: 	TODO
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;							Set sprite script to R0
;
; *****************************************************************************

.OSXSpriteScript
		push 	r1
		ldm 	r1,#spriteSelect			; write out script
		stm 	r0,r1,#spScriptPtr
		stm 	r14,r1,#spScriptOffset 		; zero offset, delay, velocity
		stm 	r14,r1,#spCycleDelay
		stm 	r14,r1,#spVelocity
		pop 	r1
		ret


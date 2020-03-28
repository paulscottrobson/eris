; *****************************************************************************
; *****************************************************************************
;
;		Name:		manager.asm
;		Purpose:	Handles routine operations
;		Created:	20th March 2020
;		Reviewed: 	TODO
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;								Handle Regular events
;
;	This uses R14 as a temp to minimise time when nothing happens in the 
;	check part.
;
; *****************************************************************************

.OSXSystemManager
		ldm 	r0,#hwTimer 				; read timer.
		ldm 	r14,#nextManagerEvent 		; read next manager event into R14.
		sub 	r0,r14,#0  			 		; carry clear if time out.
		xor 	r14,r14,#0 					; zero R14, the standard state
		skm 	r0
		jmp 	#_OSXSMCode
		clr 	r0 
		ret 	
		;
		;		At this point, R0 has the elapsed time in centiseconds.
		;
._OSXSMCode		
		push 	r1,link
		ldm 	r1,#hwTimer 				; reset the next event.
		add 	r1,#timerRate 				; to timer + event time.
		stm 	r1,#nextManagerEvent
		;
		;		Actual event code, R0 is elapsed time in centiseconds
		;
		ldm 	r1,#SpritesEnabled			; sprites enabled ?
		skz 	r1
		jsr 	#OSXSpriteUpdate 			; if so do the update code.
		jsr 	#OSIUpdateSound 			; update the sound system
		jsr 	#OSICheckBreak 				; check if break is pressed.
		pop 	r1,link
		ret

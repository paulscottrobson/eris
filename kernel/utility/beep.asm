; *****************************************************************************
; *****************************************************************************
;
;		Name:		beep.asm
;		Purpose:	Simple Beeper
;		Created:	8th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;		Play synchronously a beep on channel 1, pitch R0, duration R1.
;
; *****************************************************************************

.OSXBeep
		push 	r0,r1
		stm 	r0,#sndTone1 				; start playing
		ldm 	r0,#hwTimer 				; read timer.
		add 	r1,r0,#0 					; this is when the beep should stop
._OSBPWait
		ldm 	r0,#hwTimer
		sub 	r0,r1,#0
		skp 	r0
		jmp		#_OSBPWait
		stm 	r14,#sndTone1
		pop 	r0,r1
		ret

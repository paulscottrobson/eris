; *****************************************************************************
; *****************************************************************************
;
;		Name:		beep.asm
;		Purpose:	Simple Beeper (DISABLED)
;		Created:	8th March 2020
;		Reviewed: 	16th March 2020
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
		ldm 	r0,#hwTimer 				; read timer at start.
		add 	r1,r0,#0 					; this is when the beep should stop
._OSBPWait
		ldm 	r0,#hwTimer 				; this avoids the timer being non incremental etc.
		sub 	r0,r1,#0
		skp 	r0
		jmp		#_OSBPWait
		stm 	r14,#sndTone1 				; turn sound off
		pop 	r0,r1
		ret

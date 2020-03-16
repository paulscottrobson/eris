; *****************************************************************************
; *****************************************************************************
;
;		Name:		readjoy.asm
;		Purpose:	Return the joystick status.
;		Created:	16th March 2020
;		Reviewed: 	16th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;		Get Joystick. R0 = Joystick# (even though only one is supported)
;	Returns set bits as per hardware in R0 (Left/Right/Up Down/Fire 1/Fire 2)
;
; *****************************************************************************

.OSXReadJoystick
		mov 	r0,#$10 				; read row on bit 4
		stm 	r0,#keyboardPort
._OSXRJDelay		 					; little delay time.
		dec 	r0
		skz 	r0
		jmp 	#_OSXRJDelay	
		ldm 	r0,#keyboardPort 		; read it back in
		and 	r0,#$003F 				; mask off bits
		ret
		
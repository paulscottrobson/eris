; *****************************************************************************
; *****************************************************************************
;
;		Name:		sndplay.asm
;		Purpose:	Add a sound command to the sound queue
;		Created:	28th March 2020
;		Reviewed: 	TODO
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;						Play a sound insert into sound queue
;
;		R0 	: 	Channel Number
; 		R1 	: 	Length of sound in 20th / second
;		R2 	: 	Base Pitch, or adjustment pitch/20th sec in unscaled form
;				(signed for adjustment, unsigned for base)
;		R3 	: 	0 if pitch stable, 1 if pitch varies.
;
;		R0 	: 	0 ok
; 				1 queue full
; 				2 bad parameter value (sound too long, bad channel)
;
; *****************************************************************************

.OSXSoundPlay
		push	r1,r2,r3,r4


		pop 	r1,r2,r3,r4
		ret

; *****************************************************************************
;
;								Sound updater
;
; *****************************************************************************

.OSIUpdateSound
		ret
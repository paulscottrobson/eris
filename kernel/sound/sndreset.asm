; *****************************************************************************
; *****************************************************************************
;
;		Name:		sndreset.asm
;		Purpose:	Reset all sounds, individual sound
;		Created:	28th March 2020
;		Reviewed: 	TODO
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;						   Reset all sound channels
;
; *****************************************************************************

.OSXResetAllChannels
		push 	r0,link
		mov 	r0,#sndChannels-1
._OSIRACLoop 								; reset each channel.
		jsr 	#OSSoundResetChannel
		dec 	r0
		skm 	r0
		jmp 	#_OSIRACLoop
		pop 	r0,link
		ret		
		
; *****************************************************************************
;
;							Reset sound channel R0
;
; *****************************************************************************

.OSXSoundResetChannel
		push 	r0,r1
		mov 	r1,r0,#0 					; make R1 point to hardware
		add 	r1,#sndChannelBase 			
		stm 	r14,r1,#0 					; turn sound off
		mult 	r0,#sndRecordSize 			; point R1 to the record
		ldm 	r1,#soundQueueBase 			
		add 	r1,r0,#0
		mov 	r0,#sndRecordSize 			; clear all values to zero
._OSXSRCLoop
		stm 	r14,r1,#0
		inc 	r1
		dec 	r0
		skz 	r0
		jmp 	#_OSXSRCLoop		
		pop 	r0,r1
		ret

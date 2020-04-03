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
; 		R1 	: 	Length of sound in 10th / second
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
		push	r1,r2,r3,r4,link

		mov 	r4,r0,#0 					; check the channel #
		sub 	r4,#sndChannels
		sklt
		jmp 	#_OSXSPFail2 					
		;
		mov 	r4,r1,#0					; check the /10th sec length. This fits
		sub 	r4,#32 						; into a 5 bit space, so must be 0-31. 
		sklt 
		jmp 	#_OSXSPFail2 					
		;
		ror 	r2,#6 						; divide the pitch divisor value by 64 unsigned.
		and 	r2,#$03FF 					; as we fit it into 10 bits.
		sknz 	r0 							; if channel zero
		mov 	r2,#15 						; ignore the pitch parameter as it doesn't work.
		;
		and 	r1,#31 						; throw anything else away.
		ror 	r1,#6 						; rotate the time right by 6 (left by 10)
		mov 	r4,r1,#0 					; add time (R1) to pitch (R2)
		add 	r4,r2,#0
		and 	r3,#1 						; put bit 0 of type in bit 15
		ror 	r3,#1
		add 	r4,r3,#0 					; add to it 
		;
		mult 	r0,#sndRecordSize			; now add to queue. R4 contains word to write
		ldm 	r1,#soundQueueBase
		add 	r0,r1,#0 					; R0 now points to the record as does R3
		;
		ldm 	r2,r0,#sndQueueTail 		; get tail into R2
		mov 	r3,r0,#sndQueueStart 		; R3 = start of queue
		add 	r3,r2,#0 					; add tail offset, R3 points to new queue entry
		stm 	r4,r3,#0 					; write word out.
		inc 	r2 							; bump tail and wrap round.
		and 	r2,#sndQueueSize-1 	
		ldm 	r3,r0,#sndQueueHead 		; reached the head
		xor 	r3,r2,#0
		sknz 	r3
		jmp 	#_OSXSPFail1 				; if so exit with error 1.
		stm 	r2,r0,#sndQueueTail 		; write it back.
		jsr 	#OSIUpdateSound 			; start it immediately.
		clr 	r0 							; return zero
		jmp 	#_OSXSPExit 					

._OSXSPFail1
		mov 	r0,#1
		sknz 	r0
._OSXSPFail2
		mov 	r0,#2
._OSXSPExit		
		pop 	r1,r2,r3,r4,link
		ret

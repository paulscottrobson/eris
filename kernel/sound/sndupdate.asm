; *****************************************************************************
; *****************************************************************************
;
;		Name:		sndupdate.asm
;		Purpose:	Update the sound system from the queues for all sounds
;		Created:	28th March 2020
;		Reviewed: 	TODO
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;								Sound updater
;
; *****************************************************************************

.OSIUpdateSound
		push 	r0,r1,r2,r3,r4,r5,link
		ldm 	r4,#soundQueueBase 			; it is done this way to make it quicker
		mov		r5,#sndNoise
		jsr 	#OSIUpdateOneChannel

		add 	r4,#sndRecordSize
		mov		r5,#sndTone1
		jsr 	#OSIUpdateOneChannel

		add 	r4,#sndRecordSize
		mov		r5,#sndTone2
		jsr 	#OSIUpdateOneChannel
		pop 	r0,r1,r2,r3,r4,r5,link		
		ret

; *****************************************************************************
;
;						Check update on sound channel
;					   (Closely tied to OSIUpdateSound)
;
; *****************************************************************************
		
.OSIUpdateOneChannel
		ldm 	r0,r4,#sndCompleteTime 		; something already playing ???
		skz 	r0 
		jmp 	#OSISoundCheckTime 			; if so, check if it is finished.
		;
		ldm 	r0,r4,#sndQueueTail			; if not check if there is something in the queue
		ldm 	r1,r4,#sndQueueHead
		xor 	r0,r1,#0 					; which there is if these are different
		sknz 	r0
		ret
		;
		;		Sound is not playing but there is something the queue. Tail offset in R1
		;		
		push 	r2

		mov 	r0,r1,#sndQueueStart 		; point R0 to the head of the queue.
		add 	r0,r4,#0 					
		ldm		r0,r0,#0 					; read the word.
		inc 	r1 							; update the head forward
		and 	r1,#sndQueueSize-1 			; wrap the head round.
		stm 	r1,r4,#sndQueueHead
		;
		mov 	r1,r0,#0 					; mask out the time from bits 14..10
		ror 	r1,#10
		and 	r1,#31 						; this is the time in 10ths of seconds
		mult 	r1,#10 						; convert it into 100th seconds.
		ldm 	r2,#hwTimer 				; add to the timer
		add 	r2,r1,#0
		sknz 	r2 							; if this is zero, which means no play, fudge to 1
		mov 	r2,#1 						; (a 0.01s error one time in 64k !)
		stm 	r2,r4,#sndCompleteTime
		;
		mov 	r2,r0,#0 					; save the word in R2
		;
		skp 	r2 							; two handlers, one if it is a slide, one a play
		jmp 	#_OSICreateSlide
		;
		and 	r0,#$03FF 					; this is the unscaled modifier
		ror 	r0,#10 						; now a scaled modifier.
		stm 	r0,r4,#sndPitch 			; this is the current pitch
		stm 	r14,r4,#sndSlide 			; clear the slide.
		jmp 	#_OSICreateExit

._OSICreateSlide
		and 	r0,#$03FF 					; this is the unscaled modifier
		ror 	r0,#10 						; now a scaled modifier.
		stm 	r0,r4,#sndSlide 			; otherwise set the slide, only, pitch is unchanged.

._OSICreateExit
		pop 	r2
		ret
		;
		;		A sound is playing, handle it.
		;
.OSISoundCheckTime
		ldm 	r0,#hwTimer 				; if timer - complete >= 0 sound ends.
		ldm 	r1,r4,#sndCompleteTime
		sub 	r0,r1,#0
		skp 	r0
		jmp 	#_OSISoundPlaying
	
		stm 	r14,r4,#sndCompleteTime 	; this means it's complete, it is zero.		
		stm 	r14,r5,#0 					; turn it off and exit
		ret

._OSISoundPlaying
		ldm 	r0,r4,#sndPitch 			; add slide to pitch
		ldm 	r1,r4,#sndSlide
		sub 	r0,r1,#0
		stm 	r0,r4,#sndPitch
		stm 	r0,r5,#0 					; and set the tone pitch out.
		ret


; *****************************************************************************
; *****************************************************************************
;
;		Name:		timer.asm
;		Purpose:	Event handling code
;		Created:	15th April 2020
;		Reviewed: 	TODO
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;								Reset Events
;
; *****************************************************************************

.EventReset
		push 	r0,r1,link
		stm 	r14,#eventSemaphore
		stm 	r14,#eventCheckTime
		mov 	r0,#eventTable
		mov 	r1,#evtCount * evtRecSize
._ERErase
		stm 	r14,r0,#0		
		inc 	r0
		dec 	r1
		skz 	r1
		jmp 	#_ERErase
		pop 	r0,r1,link
		ret

; *****************************************************************************
;
;		The event Check time has been reached , check if one is actually
;		due.
;
; *****************************************************************************

.EventCheck
		push 	link
		;
		ldm 	r0,#eventSemaphore 			; check the semaphore is clear
		skz 	r0
		jmp 	#_ECExit 					; if not keep waiting.
		;
		jsr 	#EventIdentify 				; check if there is an event actually due now.
		sknz 	r0
		jmp 	#_ECNoneDue 				; if not, then set timer to way in the future.
		;
		;		R0 is the best event
		;
		ldm 	r1,r0,#evtTime 				; check it is actually due.
		ldm 	r2,#hwTimer
		sub 	r2,r1,#0
		skp 	r2
		jmp 	#_ECExit 					; no ; we've already reset the timer.
		;
		;		Fire event R0
		;
		stm 	r15,#eventSemaphore 		; set the semaphore
		push 	r0
		ldm 	r2,r0,#evtCode 				; get the code call address -> R2
		jsr 	#StackPushPosition 			; save this position
		jsr 	#StackPushMarker
		word 	'E'							; push an event return marker.
		mov 	r11,r2,#0 					; put the call address in R2.
		jsr 	#Command_Call 				; call the procedure, saving the event timer address
		pop 	r0
		;
		ldm 	r1,r0,#evtTime 				; set timer for next 
		ldm 	r2,r0,#evtRate
		add 	r1,r2,#0
		stm 	r1,r0,#evtTime
		;
		ldm 	r1,r0,#evtRepeatCount 		; check repeat count zero
		sknz 	r1
		jmp 	#_ECSetTestAndExit 			; if so keep going
		dec 	r1
		stm 	r1,r0,#evtRepeatCount 		; decrement it, if it is non-zero refire
		skz 	r1
		jmp 	#_ECSetTestAndExit
		stm 	r14,r0,#evtCode 			; stop it running
		stm 	r14,r0,#evtRate
		stm 	r14,r0,#evtTime
._ECSetTestAndExit
		jsr 	#EventIdentify 				; reset the timer for the next one		
		jmp 	#_ECExit 					; and exit
		;
		;		Come here if no event is scheduled
		;
._ECNoneDue
		ldm 	r0,#hwTimer 				; set default next check way in the future
		add 	r0,#$8000
		stm 	r0,#eventCheckTime
._ECExit
		pop 	link
		ret

; *****************************************************************************
;
;		Find the next due event, put its record in R0. If there is no event
;		R0 is 0. If event found, then set the eventCheckTime to the current
;		time+event time. Breaks R1,R2,R3,R4
;
; *****************************************************************************

.EventIdentify				
		clr 	r0
		mov 	r1,#$FFFF 					; best time till fired 
		mov	 	r2,#eventTable
._EILoop
		ldm 	r3,r2,#evtCode 				; event is on ?
		sknz 	r3
		jmp 	#_EINext
		ldm 	r3,r2,#evtTime 				; calculate event time - timer
		ldm 	r4,#hwTimer
		sub 	r3,r4,#0
		add 	r3,#$8000 					; signed comparison
		sub 	r3,r1,#0 					; compare against best so far
		sklt
		jmp 	#_EINext
		add 	r3,r1,#0 					; get back and update best so far -> R1
		mov		r1,r3,#0 				
		mov 	r0,r2,#0 					; update best so far reference in R0
		ldm 	r3,r2,#evtTime 				; get event time, write as next check time
		stm 	r3,#eventCheckTime
._EINext
		add 	r2,#evtRecSize 				; next event
		mov 	r3,r2,#0
		xor 	r3,#eventTable+evtCount*evtRecSize
		skz 	r3
		jmp 	#_EILoop
		ret

; *****************************************************************************
;
;								After/Every handler
;
; *****************************************************************************

.Command_After 	;; [after]
		mov 	r0,#1 						; do it once.
		sknz 	r0
.Command_Every  ;; [every]
		clr 	r0 							; do it many times .... many, many times.
		push 	link
		mov 	r2,r0,#0 					; save repeat count in R2
		;
		jsr 	#EvaluateInteger 			; integer which is time elapsed
		skp 	r0 							; must be +ve
		jmp 	#BadNumberError
		mov 	r1,r0,#0 					; save timer time in R1
		jsr 	#CheckComma
		;
		jsr 	#EvaluateInteger 			; get timer # -> R3
		mov 	r3,r0,#0
		sub 	r0,#evtCount 				; check its range
		sklt
		jmp 	#BadNumberError
		;
		mult 	r3,#evtRecSize 				; make R3 point to the actual record
		add 	r3,#eventTable
		;
		ldm 	r0,r11,#0 					; check followed by call
		xor 	r0,#TOK_CALL
		skz 	r0
		jmp 	#SyntaxError 
		inc 	r11
		;
		stm 	r11,r3,#evtCode 			; save address of the call word.
		ldm 	r0,#hwTimer
		add 	r0,r1,#0 					; put fire time in evtTime
		stm 	r0,r3,#evtTime
		stm 	r1,r3,#evtRate 				; the refire rate
		stm 	r2,r3,#evtRepeatCount 		; how many times to repeat
		;
		jsr 	#EventIdentify 				; find out what happens next, which sets the timer.
		;
._EACmdSkip
		ldm 	r0,r11,#0 					; skip over the identifier
		inc 	r11
		ror 	r0,#14 						
		skm		r0
		jmp 	#_EACmdSkip
		jsr 	#CheckRightBracket 			; parenthesis should follow.
		pop 	link
		ret


; *****************************************************************************
;
;								Cancel handler
;
; *****************************************************************************

.Command_Cancel ;; [cancel]
		push 	link
		jsr 	#EvaluateInteger 			; get timer # -> R3
		mov 	r3,r0,#0
		sub 	r0,#evtCount 				; check its range
		sklt
		jmp 	#BadNumberError
		;
		mult 	r3,#evtRecSize 				; make R3 point to the actual record
		add 	r3,#eventTable
		;
		stm 	r14,r3,#evtCode 			; save address of the call word.
		stm 	r14,r3,#evtTime
		stm 	r14,r3,#evtRate 			; the refire rate
		stm 	r14,r3,#evtRepeatCount 		; how many times to repeat
		;
		jsr 	#EventIdentify 				; find out what happens next, which sets the timer.
		pop 	link
		ret

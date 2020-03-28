; *****************************************************************************
; *****************************************************************************
;
;		Name:		sound.asm
;		Purpose:	Sound/Slide commands
;		Created:	28rd March 2020
;		Reviewed: 	TODO
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;								Sound and Slide. 
;
; *****************************************************************************

.Command_Sound 	;; [sound]
		clr 	r3
		skz 	r3
.Command_Slide	;; [slide]
		mov 	r3,#1
		push 	link

		jsr 	#EvaluateInteger 			; channel -> R4
		mov 	r4,r0,#0
		sub 	r0,#sndChannels 
		sklt
		jmp 	#BadNumberError

		jsr 	#CheckComma 				; length in deciseconds
		jsr 	#EvaluateInteger
		mov 	r1,r0,#0

		jsr 	#CheckComma 				; pitch or change
		jsr 	#EvaluateInteger
		mov 	r2,r0,#0

		mov 	r0,r4,#0 					; get channel back
		jsr 	#OSSoundPlay				; call sound routine.
		dec 	r0 
		sknz 	r0 							; 1 is queue space
		jmp 	#SoundQueueError
		dec 	r0 							; 2 is bad number, probably length.
		sknz 	r0
		jmp 	#BadNumberError
		pop 	link
		ret

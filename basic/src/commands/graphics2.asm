; *****************************************************************************
; *****************************************************************************
;
;		Name:		graphics2.asm
;		Purpose:	More Simple Graphics keywords
;		Created:	25th March 2020
;		Reviewed: 	TODO
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;			These get two coordinates and then call the OS Routine
;
; *****************************************************************************

.Command_Move 	;; [move]
		push 	link
		jsr 	#GetCoordinatePair	
		jsr 	#OSGraphicsMove
		pop 	link
		ret

.Command_Plot 	;; [plot]
		push 	link
		jsr 	#GetCoordinatePair	
		jsr 	#OSPlotPixel
		pop 	link
		ret

.Command_Line 	;; [line]
		push 	link
		jsr 	#GetCoordinatePair	
		jsr 	#OSDrawLine
		pop 	link
		ret

.Command_Rect 	;; [rect]
		push 	link
		jsr 	#GetCoordinatePair	
		jsr 	#OSFillRectangle
		pop 	link
		ret

.Command_Frame 	;; [frame]
		push 	link
		jsr 	#GetCoordinatePair	
		jsr 	#OSDrawRectangle
		pop 	link
		ret

; *****************************************************************************
;
;					  	Get a coordinate pair in R0,R1
;							also handles x,y TO x,y
;
; *****************************************************************************

.GetCoordinatePair
		push 	r2,link
		jsr 	#EvaluateInteger			; get and check X -> R2
		mov 	r2,r0,#0
		sub 	r0,#PixelWidth
		sklt
		jmp 	#BadNumberError
		jsr 	#CheckComma
		jsr 	#EvaluateInteger			; get and check Y -> R1
		mov 	r1,r0,#0
		sub 	r0,#PixelHeight
		sklt
		jmp 	#BadNumberError
		mov 	r0,r2,#0 					; X -> R0

		ldm 	r2,r11,#0 					; what follows ?
		xor 	r2,#TOK_TO	 				; if TO
		skz 	r2
		jmp 	#_GCPExit
		stm 	r0,#xGraphic 				; save current as actual position
		stm 	r1,#yGraphic
		inc 	r11 						; skip TO
		jsr 	#GetCoordinatePair 			; get a second pair into R0,R1
._GCPExit		
		pop 	r2,link
		ret
		
; *****************************************************************************
; *****************************************************************************
;
;		Name:		kernel.asm
;		Purpose:	Kernel Startup.
;		Created:	8th March 2020
;		Reviewed: 	20th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

;
;		This comes first, then vectors.asm.
;
.OSReset
		brl 	r15,r15,#0 					; jump to boot code. 
		word 	bootCode 	
	
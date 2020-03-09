; *****************************************************************************
; *****************************************************************************
;
;		Name:		vectors.asm
;		Purpose:	Vector Routines
;		Created:	8th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

.OSWaitBlitter
		jmp 	#OSXWaitBlitter

.OSPrintCharacter
		jmp 	#OSXPrintCharacter

.OSPrintInline
		jmp 	#OSXPrintInline

.OSPrintString
		jmp 	#OSXPrintString

.OSGetKeyboard
		jmp 	#OSXGetKeyboard
		
.OSDrawCharacter		
		jmp 	#OSXDrawCharacter		

.OSDrawSolidCharacter
		jmp 	#OSXDrawSolidCharacter
		
.OSCursorGet		
		jmp 	#OSXCursorGet
		
.OSLineInput
		jmp 	#OSXLineInput		
		
.OSUDivide16		
		jmp 	#OSXUDivide16	

.OSSDivide16		
		jmp 	#OSXSDivide16			

.OSRandom16		
		jmp 	#OSXRandom16

.OSStrToInt		
		jmp 	#OSXStrToInt		

.OSIntToStr
		jmp 	#OSXIntToStr

.OSUpperCase
		jmp 	#OSXUpperCase
				
.OSLowerCase
		jmp 	#OSXLowerCase

.OSWordLength
		jmp 	#OSXWordLength
		
.OSManager
		ret
		
.OSBeep		
		jmp 	#OSXBeep


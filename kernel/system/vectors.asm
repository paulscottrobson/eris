; *****************************************************************************
; *****************************************************************************
;
;		Name:		vectors.asm
;		Purpose:	Vector Routines
;		Created:	24th February 2020
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

.OSDrawLine
		jmp 	#OSXDrawLine

.OSDrawRectangle
		jmp 	#OSXDrawRectangle
		
.OSGetKeyboard
		jmp 	#OSXGetKeyboard
		
.OSCursorGet		
		jmp 	#OSXCursorGet

.OSLineInput
		jmp 	#OSXLineInput		

.OSCheckBreak		
		jmp 	#OSXCheckBreak
		
.OSDrawCharacter		
		jmp 	#OSXDrawCharacter		

.OSFillScreen
		jmp 	#OSXFillScreen

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


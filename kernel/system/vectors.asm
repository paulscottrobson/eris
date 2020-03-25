; *****************************************************************************
; *****************************************************************************
;
;		Name:		vectors.asm
;		Purpose:	Vector Routines
;		Created:	8th March 2020
;		Reviewed: 	20th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;					"Fast" group which have 1 byte calls
;
; *****************************************************************************

.OSWaitBlitter
		jmp 	#OSXWaitBlitter

.OSPrintCharacter
		jmp 	#OSXPrintCharacter

.OSPrintInline
		jmp 	#OSXPrintInline

.OSPrintString
		jmp 	#OSXPrintString

; *****************************************************************************
;
;								Input Group
;
; *****************************************************************************

.OSGetKeyboard
		jmp 	#OSXGetKeyboard

.OSCursorGet
		jmp 	#OSXCursorGet

.OSLineInput
		jmp 	#OSXLineInput

.OSInputLimit
		jmp 	#OSXInputLimit

.OSReadJoystick
		jmp 	#OSXReadJoystick
		
; *****************************************************************************
;
;								Text Group
;
; *****************************************************************************

.OSGetTextPos
		jmp 	#OSXGetTextPos

; *****************************************************************************
;
;								Graphic Group
;
; *****************************************************************************

.OSSetPlanes
		jmp		#OSXSetPlanes

.OSSetBackPlanePalette
		jmp 	#OSXSetBackPlanePalette

.OSSetFrontPlanePalette
		jmp 	#OSXSetFrontPlanePalette

.OSDrawCharacter
		jmp 	#OSXDrawCharacter

.OSDrawSolidCharacter
		jmp 	#OSXDrawSolidCharacter

.OSGraphicsMove
		jmp 	#OSXGraphicsMove

.OSDrawLine
		jmp 	#OSXDrawLine

.OSFillRectangle
		jmp 	#OSXFillRectangle
		
; *****************************************************************************
;
;								Sound group
;
; *****************************************************************************

.OSBeep
		jmp 	#OSXBeep

; *****************************************************************************
;
;								Utility Group
;
; *****************************************************************************

.OSReadSystemVariable
		jmp 	#OSXReadSystemVariable
		
.OSFileOperation
		jmp 	#OSXFileOperation

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

.OSSystemManager
		jmp 	#OSXSystemManager

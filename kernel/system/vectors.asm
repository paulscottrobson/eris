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

.OSSpriteSelect
		jmp 	#OSXSpriteSelect
		
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
	
.OSDefineFKey
		jmp 	#OSXDefineFKey		
		
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

.OSPlotPixel
		jmp 	#OSXPlotPixel

.OSDrawLine
		jmp 	#OSXDrawLine

.OSDrawRectangle
		jmp 	#OSXDrawRectangle
		
.OSFillRectangle
		jmp 	#OSXFillRectangle
		
.OSDrawEllipse
		jmp 	#OSXDrawEllipse

.OSFillEllipse
		jmp 	#OSXFillEllipse

; *****************************************************************************
;
;								Sprite Group
;
; *****************************************************************************

.OSSpriteReset		
		jmp 	#OSXSpriteReset

.OSSpriteUpdate
		jmp 	#OSXSpriteUpdate
		
.OSSpriteMove
		jmp 	#OSXSpriteMove

.OSSpriteSetImage
		jmp 	#OSXSpriteSetImage

.OSSpriteSetColour
		jmp 	#OSXSpriteSetColour

.OSSpriteSetOrientation
		jmp 	#OSXSpriteSetOrientation

.OSSpriteSetSize
		jmp 	#OSXSpriteSetSize

.OSSpriteCollision
		jmp 	#OSXSpriteCollision	

.OSDrawTileMap
		jmp 	#OSXDrawTileMap
		
; *****************************************************************************
;
;								Sound group
;
; *****************************************************************************

.OSResetAllChannels
		jmp 	#OSXResetAllChannels

.OSSoundResetChannel
		jmp 	#OSXSoundResetChannel

.OSSoundPlay
		jmp 	#OSXSoundPlay

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

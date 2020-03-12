; *****************************************************************************
; *****************************************************************************
;
;		Name:		boot.asm
;		Purpose:	Boot code
;		Created:	8th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

.bootPrompt
	string "[10,0F,16,0C]*** Eris RetroComputer ***[0D,0D,13]Written by Paul Robson 2020[0D,0D]"
.kernelPrompt
	string "Kernel[3A] 0.01[0D]"

; *****************************************************************************
;
;							Kernel Boot code comes here
;
; *****************************************************************************
.bootCode
		clr		r14 						; default value for R14
;
;		Clear the OS Data area
;		
		mov 	r0,#initialisedStart 		
		mov 	r1,r15,#0
		word 	initialisedEnd-initialisedStart
._bcClear
		stm 	r14,r0,#0
		inc 	r0
		dec 	r1
		skz 	r1
		jmp 	#_bcClear
;
;		Non destructive memory test.
;
		mov 	r0,#$4000  					; non destructive memory test.
._bcCheckMemory:
		ldm 	r1,r0,#0 					; read the byte in memory already there
		mov 	r2,#$AAAA 					; value being checked.
._bcCheck2:
		stm 	r2,r0,#0 					; write to memory
		ldm 	r3,r0,#0 					; read it back
		skeq 	r2,r3,#0 					; if different then found non memory.
		jmp		#_bcFoundEnd
		xor 	r2,#$FFFF 					; toggle the bit pattern
		sksn 	r2,r14,#0 					; until its -ve e.g. do AAAA then 5555
		jmp 	#_bcCheck2
		stm 	r1,r0,#0 					; write value back
		add 	r0,#$100 					; next 1/4 on.
		jmp 	#_bcCheckMemory

;
;		Save that, allocate memory for the screen mirror and initialise the stack & PRNG
;
._bcFoundEnd		
		stm 	r0,#highMemory 				; save high memory
		sub 	r0,#(charWidth*charHeight)	; allocate text screen space
		stm 	r0,#textMemory
		dec 	r0 							; put a $0000 word before screen text so the 
		stm 	r14,r0,#0  					; scanner won't go up further on line input.
		mov 	sp,r0,#0 					; initialise Stack Pointer.
		stm 	r0,#randomSeed 				; initialise the random number generator
;
;		Erase the whole display using colour 0 mask $FF
;		
		mov 	r0,#$FF00
		jsr 	#OSIFillScreen
;
;		Initialise the colour mask
;
		mov 	r0,#15
		stm 	r0,#colourMask
;
;		Reset the palette
;
		clr 	r0 							; R0 is palette-write
._bcWritePalette
		mov 	r1,r0,#0 					; get the colour out of the table
		ror 	r1,#8
		and 	r1,#7
		add 	r1,#paletteTable
		ldm 	r1,r1,#0 	
		add 	r1,r0,#0 					; build the word
		stm 	r1,#paletteRegister 		; write to palette register
		add 	r0,#$100
		skz 	r0
		jmp 	#_bcWritePalette
;
;		Show the boot prompt
;		
		mov 	r0,#bootPrompt 				; display boot prompt.		
		jsr 	#OSPrintString
		ldm 	r0,#highMemory 				; calculate free memory.
		sub 	r0,#ramStart
		mov 	r1,#10 						; convert to base 10.
		jsr 	#OSIntToStr
		jsr 	#OSPrintString
		jsr 	#OSPrintInline
		string	" words RAM[0D,0D,12]"
		mov 	r0,#kernelPrompt
		jsr 	#OSPrintString
;
;		Turn the audio off.
;
._bcSilence
		stm 	r14,#sndNoise 				; turn sound off.
		stm 	r14,#sndTone1
		stm 	r14,#sndTone2
;
;		Sound the startup beep
;
		mov 	r0,#22726 	
		mov 	r1,#50
;		jsr 	#OSBeep
		ror 	r0,#1
		ror 	r1,#1
;		jsr 	#OSBeep

		jmp 	#KernelEnd
;
;		Palette table all colours 0-255 are set to this based on the lower
;		three bits of the palette number.
;		
.paletteTable
		word 	0*16+0*4+0
		word 	0*16+0*4+3
		word 	0*16+3*4+0
		word 	0*16+3*4+3
		word 	3*16+0*4+0
		word 	3*16+0*4+3
		word 	3*16+3*4+0
		word 	3*16+3*4+3


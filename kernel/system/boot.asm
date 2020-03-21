; *****************************************************************************
; *****************************************************************************
;
;		Name:		boot.asm
;		Purpose:	Boot code
;		Created:	8th March 2020
;		Reviewed: 	20th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

.bootPrompt
	string "[10,0F,16,0C]*** Eris RetroComputer ***[0D,0D,13]Written by Paul Robson 2020[0D,0D]"
.kernelPrompt
	string "Kernel[3A] 0.2[0D]"

; *****************************************************************************
;
;							Kernel Boot code comes here
;
; *****************************************************************************
.bootCode
		clr		r14 						; default value for R14. Zero throughout
;
;		Clear the OS Data area
;
		mov 	r0,#initialisedStart 		; this blobk is defined in data.asm
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
		mov 	r0,#ramStart 				; non destructive memory test.
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
;		Save memory end, allocate memory for the sprite images, screen mirror and initialise the stack & PRNG
;
._bcFoundEnd
		stm 	r0,#highMemory 				; save high memory
		sub 	r0,#spriteDefaultImageCount * 16 ; allow space for sprites
		and 	r0,#$FFF0 					; put on 16 word boundary
		stm 	r0,#spriteImageMemory
		;
		sub 	r0,#(charWidth*charHeight)	; allocate text screen space
		stm 	r0,#textMemory
		dec 	r0 							; put a $0000 word before screen text so the
		stm 	r14,r0,#0  					; scanner won't go up further on line input.
		;
		mov 	sp,r0,#0 					; initialise Stack Pointer.
		stm 	r0,#randomSeed 				; initialise the random number generator
;
;		Initialise other system variables
;
		mov 	r1,#systemVariables 		; initialise other system variables
		mov 	r0,#ramStart 			
		stm 	r0,r1,#0
		mov 	r0,#charWidth
		stm 	r0,r1,#5
		mov 	r0,#charHeight
		stm 	r0,r1,#6
		mov 	r0,#spriteDefaultImageCount
		stm 	r0,r1,#4	
		mov		r0,#fontDataDefault
		stm 	r0,r1,#7
;
;		Reset the next time event
;
		ldm 	r0,#hwTimer
		stm 	r0,#nextManagerEvent		
;
;		Initialise the plane usage/clear screen
;
		mov 	r0,#$0004					; 4 backplanes no sprite plane
		jsr 	#OSSetPlanes
;
;		Show the boot prompt, free memory and kernel version
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
		mov 	r0,#kernelPrompt			; display kernel version
		jsr 	#OSPrintString
;
;		Turn the audio off.
;
._bcSilence
		stm 	r14,#sndNoise 				; turn sound off.
		stm 	r14,#sndTone1
		stm 	r14,#sndTone2
;
;		Initialise file I/O
;
		clr 	r0 							; send command 0.
		jsr 	#OSFileOperation
;
;		Sound the startup beep
;
		mov 	r0,#22726 					; play A4 for 0.5s
		mov 	r1,#50
;		jsr 	#OSBeep
		ror 	r0,#1 						; halve it e.g. A3 for 0.25s
		ror 	r1,#1
;		jsr 	#OSBeep

		jmp 	#KernelEnd 					; this is the end of the "kernel ROM"

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
	string "Kernel[3A] 0.80[0D]"

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
;		Save memory end, allocate memory for :
;			(1) sprite / blit images
;			(2) sprite objects
;			(3) sound queues
;			(4) the text screen
;
._bcFoundEnd
		stm 	r0,#highMemory 				; save high memory
		sub 	r0,#spriteDefaultImageCount * 16 ; allow space for sprites
		and 	r0,#$FFF0 					; put on 16 word boundary
		stm 	r0,#spriteImageMemory
		;
		sub 	r0,#spriteObjectCount *spriteRecordSize
		stm 	r0,#spriteAddress 			; allocate memory for sprites
		;
		sub 	r0,#sndRecordSize * sndChannels
		stm 	r0,#soundQueueBase 			; allocate sound queue memory
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
		mov 	r0,#spriteObjectCount
		stm 	r0,r1,#15
;
;		Reset the next time event
;
		ldm 	r0,#hwTimer
		stm 	r0,#nextManagerEvent		
;
;		Initialise the plane usage/clear screen/reset sprites
;
		mov 	r0,#$0103					; 3 backplanes 1 sprite plane
		jsr 	#OSSetPlanes
		jsr 	#OSSpriteReset
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
		jsr 	#OSResetAllChannels
;
;		Initialise file I/O
;
		clr 	r0 							; send command 0.
		jsr 	#OSFileOperation
;
;		Sound the startup beep
;
		mov 	r0,#1 						; channel # 1
		mov 	r1,#6 						; play for 6/10th seconds.
		mov 	r2,#22726 					; play A4
		clr 	r3 							; static value
		jsr 	#OSSoundPlay
		mov 	r0,#1 						; channel # 1 (OSSoundPlay returns error in R0)
		mov 	r1,#3						; play for half as long.
		ror 	r2,#1 						; double pitch by halving divisor
		jsr 	#OSSoundPlay 				; and play A5
;
;		Boot the main ROM.
;	
		jmp 	#KernelEnd 					; this is the end of the "kernel ROM"

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
;		Initialise the colour mask
;
		mov 	r0,#15
		stm 	r0,#colourMask

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
;
;		Turn the audio off.
;
._bcSilence
		stm 	r14,#sndNoise 				; turn sound off.
		stm 	r14,#sndTone1
		stm 	r14,#sndTone2

		mov 	r0,#22726 					; sort of BBC Microish startup beep
		mov 	r1,#50
;		jsr 	#OSBeep
		ror 	r0,#1
		ror 	r1,#1
;		jsr 	#OSBeep

		jmp 	#KernelEnd
		
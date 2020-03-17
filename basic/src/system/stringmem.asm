; *****************************************************************************
; *****************************************************************************
;
;		Name:		stringmem.asm
;		Purpose:	String memory handler.
;		Created:	2nd March 2020
;		Reviewed: 	17th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************
;
;		Temporary memory is allocated from the top of memory down. A gap is
;		left above it so a string can be "concreted" - fixed in memory.
;	
;		Temporary memory which is used for things like intermediate string
;		values is just allocated as used, and lost again at the start of each
;		new instruction (tempStringAlloc is zeroed)
;
; *****************************************************************************
;
;					Allocate R0 bytes of memory for temp usage
;						 (reset each instruction executed)
;
; *****************************************************************************

.AllocateTempMemory
		push 	r1
		ldm 	r1,#tempStringAlloc			; read temp string pointer
		skz 	r1 							; if zero, it needs setting up.
		jmp 	#_ATMNoInitialise
		ldm 	r1,#memAllocTop 			; to top of allocated memory - space ....
		sub 	r1,#maxStringSize			; allowing enough space for concreting x 2
._ATMNoInitialise
		sub 	r1,r0,#0 					; allocate space as required.
		stm 	r1,#tempStringAlloc 		; write allocated memory address back.
		;
		ldm 	r0,#memAllocBottom 			; check bottom < top e.g. we haven't underflowed
		sub 	r0,r1,#0
		sklt 	r0
		jmp 	#MemoryError
		;
		mov 	r0,r1,#0 					; return in R0
		pop 	r1
		ret
		
;*****************************************************************************
;
;					Write string at R0 to addres R1
;					This *concretes* it if required
;
;	Concreted strings (e.g. those above memAllocTop) have a maximum length 
;	word before the normal length word, allowing expansion.
;
; *****************************************************************************

.StringAssign
		push 	r0,r1,r2,r3,r4,link
		;
		;		Work out how many words are needed.
		;
		mov 	r2,r0,#0 					; save string address in R2, (target in R1)
		jsr 	#OSWordLength 				; get how many words are required for this
		;
		;		If this is not a concreted string, then it must be concreted
		;
		ldm 	r3,#memAllocTop 			; lowest address for concreted strings
											; (all concreted strings are above this)

		ldm	 	r4,r1,#0 					; get the current assigned address for this string
		sub 	r4,r3,#0			
		skge 								; current assigned < lowest then we must concrete it
		jmp 	#_SSAConcrete 				; because it's in temporary or program space.
		;
		;		Already concreted, check if it will fit.
		;
		ldm 	r4,r1,#0 					; get the address of the string again
		dec 	r4 							; get the maximum size from the previous word
		ldm 	r3,r4,#0 					; get maximum words available.
		dec 	r3 							; one fewer actually usable.
		sub 	r3,r0,#0 					; if available >= length then we can reuse it.
		sklt 	
		jmp 	#_SSAUseCurrent 			
		;
		;		"Concrete" the string, e.g. put it in high memory with a word marker
		;		before it.
		;
._SSAConcrete
		mov 	r4,r0,#1+extraStringAlloc 	; amount to actually allocate, add a bit more for expansion
		ldm 	r3,#memAllocTop 			; make memory available
		sub 	r3,r4,#0 					; enough for string as calculated
		stm 	r3,#memAllocTop
		stm 	r4,r3,#0 					; save the length available
		inc 	r3 							; word after the length where the string actually is
		stm 	r3,r1,#0 					; overwrite the target address - the actual reference
		ldm 	r4,#memAllocBottom 			; check out of memory
		add 	r4,#256 					; allow a gap
		sub 	r4,r3,#0
		sklt 								; if bottom >= top .... out of memory
		jmp 	#MemoryError
		;
		;		Copy the string at R2 to [R1]
		;
._SSAUseCurrent
		ldm 	r3,r1,#0 					; get target address, this is where it goes.
._SSACopy
		ldm 	r4,r2,#0 					; copy a word
		stm 	r4,r3,#0		
		inc 	r2 							; bump pointers
		inc 	r3
		dec 	r0 							; until whole string copied including length.
		skm 	r0 							; hence we do one extra copy, counting till -ve
		jmp 	#_SSACopy
		pop 	r0,r1,r2,r3,r4,link
		ret

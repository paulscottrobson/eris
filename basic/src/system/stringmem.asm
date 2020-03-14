; *****************************************************************************
; *****************************************************************************
;
;		Name:		stringmem.asm
;		Purpose:	String memory handler.
;		Created:	2nd March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;					Allocate R0 bytes of memory for temp usage
;						 (reset each instruction executed)
;
; *****************************************************************************

.AllocateTempMemory
		push 	r1
		ldm 	r1,#tempStringAlloc			; read temp pointer
		skz 	r1 							; if zero, needs setting up.
		jmp 	#_ATMNoInitialise
		ldm 	r1,#memAllocTop 			; to top of allocated memory - 256
		sub 	r1,#(maxStringSize>>1)+1	; allowing enough space for concreting.
._ATMNoInitialise
		sub 	r1,r0,#0 					; allocate space.
		stm 	r1,#tempStringAlloc 		; write address back.
		;
		ldm 	r0,#memAllocBottom 			; check bottom < top
		sub 	r0,r1,#0
		sklt 	r0
		jmp 	#MemoryError
		;
		mov 	r0,r1,#0 					; return in R0
		pop 	r1
		ret
		
; *****************************************************************************
;
;						Write string at R0 to address R1
;
; *****************************************************************************

.StringAssign
		push 	r0,r1,r2,r3,r4,link
		;
		;		Work out how many words are needed.
		;
		mov 	r2,r0,#0 					; save string address in R2, target in R1
		jsr 	#OSWordLength 				; how many words are required for this ?
		;
		;		If this is not a concreted string, then it must be concrete
		;
		ldm 	r3,#memAllocTop 			; lowest address for concreted strings
		ldm	 	r4,r1,#0 					; get the current assigned address
		sub 	r4,r3,#0			
		skge 								; current assigned < lowest then we must concrete it
		jmp 	#_SSAConcrete
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
		mov 	r4,r0,#1+extraStringAlloc 	; amount to actually allocate, add a bit more.
		ldm 	r3,#memAllocTop 			; make memory available
		sub 	r3,r4,#0 					; enough for string as calculated
		stm 	r3,#memAllocTop
		stm 	r4,r3,#0 					; save the length available
		inc 	r3 							; word after the length
		stm 	r3,r1,#0 					; overwrite the target address
		ldm 	r4,#memAllocBottom 			; check out of memory
		add 	r4,#256 					; allow a gap
		sub 	r4,r3,#0
		sklt 								; if bottom >= top ....
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
		skm 	r0 							; hence we do one extra copy
		jmp 	#_SSACopy
		pop 	r0,r1,r2,r3,r4,link
		ret

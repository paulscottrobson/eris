; *****************************************************************************
; *****************************************************************************
;
;		Name:		complexvar.asm
;		Purpose:	Hashtable long identifier variable handler
;		Created:	3rd March 2020
;		Reviewed: 	TODO
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;				Get variable reference @R11 to stack @R10
;
; *****************************************************************************

.GetVariableReference
		ldm 	r0,r11,#0 					; get keyword which is an identifier.
		sub 	r0,#$6000					; 01xx plus must be last character.
		sub 	r0,#26+1 					; check range 1..26 ($6000 cannot happen)
		sklt 	r0
		jmp 	#_GVRNotFixedVariable
		;
		;		Fixed location A-Z variables.
		;
		mov 	r1,#fixedVariables+26		; put fixed variable address in R1 (A = $6001)
		add 	r1,r0,#0
		stm 	r1,r10,#esValue1 			; save address
		stm 	r15,r10,#esReference1 		; and it is a reference.
		stm 	r14,r10,#esType1 			; and a reference to an integer
		;
		inc 	r11 						; step over keyword
		ret
		;
		;		It's not an A-Z variable reference, check it is an identifier 
		;
._GVRNotFixedVariable
		push 	r0,r1,r2,r3,r4,r5,r6,link 	; push registers on the stack
		;
		jsr 	#FindVariable				; try to find variable.
		skz 	r0 							; failed.
		jmp 	#_GVRHaveVariable 			; variable record in R0, access it.
		;
		;		The variable does not exist. Create stand alone variables but not
		;		arrays. R6 still points to its hash table header.
		;
		;		First check if this is an array, which we can't autocreate.
		;
._GVRNotFound		
		ldm 	r0,r11,#0 					; get keyword token again.
		ror 	r0,#12 						; index bit in R0
		skp 	r0
		jmp 	#ArrayAutoError 			; if set, can't autocreate arrays.
		;
		;		Create a new record and put its address in R0.
		;
		mov 	r0,#3						; 3 words required for default variable.
		jsr 	#CreateVariableRecord 		; create the variable.
		;
		;		We now have accessed the variable in R0. 
		;		Do the array lookup if required.
		;
._GVRHaveVariable		
		ldm 	r1,r11,#0 					; advance the identifier pointer past the identifier
		mov 	r2,r1,#0 					; save for typing in R2
		inc 	r11
		ror 	r1,#14
		skm 	r1
		jmp 	#_GVRHaveVariable
		;
		ror 	r1,#14 						; shift the index bit back into sign bit
		skp 	r1 							; if array, do indexing
		jsr 	#IndexArray
		skm 	r1 							; if not array ....
		add 	r0,#2 						; convert to data pointer.
		;
		;		Set the reference in the evaluation stack.
		;
		stm 	r0,r10,#esValue1 			; set the address in the stack
		stm 	r15,r10,#esReference1 		; it's a referenece
		and 	r2,#$1000 					; save the type bit as the type from the name
		stm 	r2,r10,#esType1

		pop 	r0,r1,r2,r3,r4,r5,r6,link 	; push registers on the stack
		ret

._GVRNullString
		word 	0		

; *****************************************************************************
;
;		Find variable at R11. Check it actually is a variable. Return pointer to the
;		record, or 0 if not found in R0. R6 contains the hash table header pointer
;		on exit. Breaks R1,R2,R3,R4
;
; *****************************************************************************

.FindVariable
		ldm 	r0,r11,#0 					; get keyword token again.
		and 	r0,#$C000					; check it is 4000-7FFF
		xor 	r0,#$4000
		skz 	r0
		jmp 	#SyntaxError
		;
		;		Calculate hashtable link entry address for this, put this in R6.
		;
		ldm 	r6,r11,#0 					; get keyword token.
		mov 	r0,r6,#0 					; make a hash value out of the first word.
		ror 	r0,#6
		add 	r6,r0,#0
		and 	r6,#hashTableSize-1 		; put into range 0-15, the entry in the table
		;
		;clr 	R6 							; force 1 List !
		;
		ldm 	r0,r11,#0 					; get keyword token again
		and 	r0,#$1800 					; mask out the type bits
		ror 	r0,#11-hashTablePower 		; shift right to 0-1, then multiply by hash table size.
		add 	r6,r0,#0 					; add this to the 0-15 hash table value
		;
		add 	r6,#variableHashTable		; make R6 point to the actual entry in the hash table.
		;
		;		Now see if this variable @R11 already exists in the linked list.
		;
		mov 	r0,r6,#0 					; address of first pointer
._FVRSearch
		ldm		r0,r0,#0 					; follow the link
		sknz 	r0 							; if link is zero, then it is not found.
		jmp 	#_FVRExit 					; and exit with 0.
		;
		ldm 	r1,r0,#1 					; get address of the name this round
		mov 	r2,r11,#0 					; this is the address in the code to compare it against
		;
._FVRCompare
		ldm 	r3,r1,#0 					; get the two identifiers being compared
		ldm 	r4,r2,#0
		xor 	r3,r4,#0 					; do they match
		skz 	r3
		jmp 	#_FVRSearch 				; no, try the next link on.
		inc 	r1 							; advance to next identifier name
		inc 	r2
		ror 	r4,#14 						; is the end of identifier bit set ?
		skm 	r4
		jmp 	#_FVRCompare 				; keep going
._FVRExit		
		ret

; *****************************************************************************
;
;		Create a variable record from identifier at R11. Returns record
;		in R0. Assumes R6 points to hash table. Record size in R0.
;	
;		Sets variable defaults e.g. +0 link +1 name +2 data
;		
;		Breaks R1,R2,R3
;
; *****************************************************************************

.CreateVariableRecord
		push 	r11,link

		mov 	r3,r11,#0 					; check if identifier in token buffer
		sub 	r3,#tokenBufferEnd
		skge
		jsr 	#DuplicateReference
		ldm 	r1,#memAllocBottom 			; point R1 to free memory.
		;
		ldm 	r2,r6,#0 					; read head of linked list
		stm 	r2,r1,#0 					; write into new record
		stm 	r11,r1,#1 					; save name address

		ldm 	r3,r11,#0 					; get keyword token again.
		ror 	r3,#13 						; type bit in R0.
		clr 	r2 							; zero for integer, null string for string
		skp 	r3
		mov 	r2,#_GVRNullString 			
		stm 	r2,r1,#2 				

		mov 	r2,r1,#0 					; update mem alloc bottom
		add 	r2,r0,#0 					; allocate words
		sknc 	 							; if overflows too much memory
		jmp 	#MemoryError
		stm 	r2,#memAllocBottom
		ldm 	r3,#memAllocTop 			; check out of memory
		sub 	r3,#256 					; allow a gap
		sub 	r2,r3,#0
		sklt
		jmp 	#MemoryError
		;
		stm 	r1,r6,#0 					; patch into linked list.
		mov 	r0,r1,#0 					; address in R0
		pop 	r11,link
		ret


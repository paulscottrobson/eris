;
;		Test code. Displays the palette
;
highmem = $C000

.start
		mov		sp,#highmem
		clr		r14
		mov 	r1,#15
		push 	r0,r2,r4
		pop 	r4,r2,r0
.loop
		jsr 	#doOne
		dec 	r1
		skm 	r1
		jmp 	#loop
.h1 	jmp 	#h1		

.data
		word 	$FFFF		

._label

.doOne
		clr 	r0
		stm 	r0,#$FF11
		mov 	r0,r1,#0
		ror 	r0,#12
		stm 	r0,#$FF10		
		mov 	r0,#data
		stm 	r0,#$FF12
		mov 	r0,r1,#0
		add 	r0,#$4000
		stm	 	r0,#$FF13
		ret

progMem = alloc(256)
print progMem
for pass = 0 to 1 
	code progMem,pass

		mov 	r5,#100
	.loop3		
		mov 	r1,r5,#0
		and 	r1,#15
		clr 	r1
		mov 	r2,r5,#0
		;ror 	r2,#4
		and 	r2,#31
		mov 	r4,r2,#0
	.loop2
		mov		r3,r1,#0
	.loop1
		stm 	r3,#&FF20:stm r4,#&FF21
		mov 	r0,#sysvar(3):stm r0,#&FF22
		mov 	r0,r3,#0:and r0,#3:add r0,#&0F01:stm r0,#&FF23
		mov 	r0,#&1010:stm r0,#&FF24
		add 	r3,#16
		mov 	r0,r3,#0:sub r0,#300:skge:jmp #loop1
		add 	r4,#16
		mov 	r0,r4,#0:sub r0,#200:skge:jmp #loop2
		sub r5,#1:skz r5:jmp #loop3
		ret

next pass
sprite load "sprites.dat"
t1 = !&FF30:sys progMem:print !&FF30-t1
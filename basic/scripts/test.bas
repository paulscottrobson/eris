count = 42
for i = 1 to 3 step 2
code &6000,i
.start
	mov  1,14,#0
	skeq 1,14,#0
	skne 1,14,#0
	skse 1,14,#0
	sksn 1,14,#0

	clr		r1
	skz 	r1
	sknz 	r1
	skp 	r1
	skm 	r1
.forward
next i

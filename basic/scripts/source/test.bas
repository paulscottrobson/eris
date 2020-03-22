count = 42:link = 13
for i = 1 to 3 step 2
code &6000,i
.start
	push 	0,1,8,link
	mov 	0,0,#0
	pop 	0,1,8,link
.forward
next i

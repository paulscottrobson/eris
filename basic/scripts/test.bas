count = 42
for i = 1 to 3 step 2
code &6000,i
.start
add 1,2,#4
sub 2,#5
ldm 3,#32766
mov 0,#start
mov 1,#forward
xor 1,1,#0
.forward
next i

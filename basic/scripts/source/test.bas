screen 2,2
load "sprites.dat",sysvar(3)
sp = sysvar(14):sp2 = sp+6:sp3 = sp+12

sp!5 = &300
sp2!5 = &202
sp3!5 = &101:sp3!3 = 50:sp3!4 = 30
repeat
	for i = 1 to 320
		t1 = !&FF30:repeat:until !&FF30<>t1
		sp!3 = i:sp!4 = 38
		sp2!3 = i+32:sp2!4 = i
	next i
until false


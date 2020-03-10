d = 3
while d >= 0
	c = 4
	while c >= 0
		print chr$(17+d+c);d,c
		c = c - 1
		repeat:until 1
	wend
d = d - 1
wend
stop
cls
ink 4
ellipse 0,0 to 230,230
for i = 0 to 115
	ink random(1,7)
	curve 115-i,115-i to 115+i,115+i
next i

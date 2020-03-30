cls
ink 4
scale = 13
ellipse 0,0 to 230*scale/10,230
xc = 230*scale/10/2
for i = 0 to 115
	ink random(1,7)
	curve xc-i*scale/10,115-i to xc+i*scale/10,115+i
next i

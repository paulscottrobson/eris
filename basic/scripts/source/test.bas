screen 2,2
sprite load "sprites.dat"

sp = sysvar(14):sp2 = sp+6:sp3 = sp+12
sprite 0 ink 3:sprite 0 draw 0
sprite 1 ink 2 draw 2
sprite 2 draw 1:sprite 2 ink 1
sprite 2 to 50,30

repeat
	for i = 1 to 320
		wait 1
		sprite 0 to i,38
		sprite 1 to i,(i mod 240)
		sprite 1 flip i and 2 ink random(1,3)
	next i
until false


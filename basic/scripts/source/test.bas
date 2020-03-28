cls:screen 2,2
sprite load "sprites.dat"
sprite 0 to 10,10 ink 1 draw 1
sprite 1 to 310,10 ink 2 draw 1
for i = 0 to 200 step 4
	wait 1
	sprite 0 to i+10,10
	sprite 1 to 310-i,10
	if hit(0,1) then stop
next i

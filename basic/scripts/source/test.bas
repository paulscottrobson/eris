screen 2,2
sprite load "aticatac.spr"
for xi = 1 to 3
sprite xi to xi*50,xi*50 draw 8 ink xi:wait 1	
next xi

a$ = "X10"
sprite 2 run a$+""

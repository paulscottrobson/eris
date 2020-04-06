cls
sprite load "dodge.spr"
p = 20
sprite 0 to p,20 ink 1 draw 0 dim 2
speed = 1:stepx = 2
wait 100
print "Starting"
while not event(evt2,100):wend
print "Timed out"
t1 = timer()
while p < 320
	if event(evt1,speed) then p = p + stepx:sprite 0 to p,20
wend
print timer()-t1
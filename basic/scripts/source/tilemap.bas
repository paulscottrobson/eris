cls
count = 0
start = timer()
'
'	Create a demo tile map
'	
xSize = 40
ySize = 30
map = alloc(xSize*ySize+5)
!map = &ABCD
map!1 = 16
map!2 = xSize
map!3 = ySize
map!4 = 4
for x = 0 to xSize-1
	for y = 0 to ySize-1
		map!(x+y*xSize+5) = (x mod 7)*256+random(0,2)
	next y
next x
'
'	Load images and scroll it back and forth.
'
sprite load "sprites.dat"
m = 1:t1 = timer()
for i = 1 to 100
	tile 0,0,i*2,i,20,15,map
next i:cls:print timer()-t1:end

cls
xSize = 12
ySize = 8
map = alloc(xSize*ySize+4)

!map = &ABCD
map!1 = 16
map!2 = xSize
map!3 = ySize
for x = 0 to xSize-1
	for y = 0 to ySize-1
		map!(x+y*xSize+4) = (x mod 3)+x/3*256
	next y
next x
print str$(map,16)
tile 32,32,0,0,6,4,map
ink 5
frame 32,32 to 32+6*16,32+4*16
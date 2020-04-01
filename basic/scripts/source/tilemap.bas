cls
palette 1,1,5
count = 0
start = timer()
'
'	Create a demo tile map
'	
xSize = 12
ySize = 8
map = alloc(xSize*ySize+5)
!map = &ABCD
map!1 = 16
map!2 = xSize
map!3 = ySize
map!4 = 4
for x = 0 to xSize-1
	for y = 0 to ySize-1
		map!(x+y*xSize+5) = (x mod 3)+(x+y)/3*256
	next y
next x
print str$(map,16)
'
'	Blit two solid bars to the sprite layer, to cover up the tilemap overflow
'
block = alloc(1):!block = -1
call drawbars(8)
'
'	Load images and scroll it back and forth.
'
sprite load "sprites.dat"
m = 1
repeat
	for i = -210 to 210
		tile 32,32,i*m,0*i*m,13,9,map
		ink 7:frame 32,32 to 32+13*16,32+9*16
		count = count + 1
	next i
	m = -m
	cursor 12,0:print count,timer()-start

until false
'
'	Draw bars
'
proc drawbars(c)
blit 16,0,block,&0800+c,&80F0
blit 32+13*16,0,block,&0800+c,&80F0
endproc
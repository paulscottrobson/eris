screen 4,0:cls
dim bits(16)
bit = &8000:xCursor = 1:yCursor = 1
block = alloc(8):for i = 0 to 7:block!i = &FF00:next i
cursor = alloc(8):for i = 0 to 7:cursor!i = &8100:next i:cursor!0 = &FF00:cursor!7=&FF00
for i = 0 to 15:bits(i) = bit:bit = (bit/2) and &7FFF:next i
graphic.data = sysvar(4)
graphic.count = sysvar(3)



for y = 0 to 15
	data = random():call line
next y
end

proc line
	for x = 0 to 15
		if (data and bits(x)) <> 0 col = 1 else col = 4 endif
		blit 320-136+x*8,y*8+8,block,&F00+col,8
		if x = xCursor and y = yCursor then blit 320-136+x*8,y*8+8,cursor,&F03,8
	next x
endproc

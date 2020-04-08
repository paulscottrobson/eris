#
#		Convert Maze Layout to Data
#
src = [x.upper().strip() for x in open("maze.def").readlines() if not x.startswith(";")]
src = [x + (x[::-1][1:]) for x in src]

xSize = len(src[0])-2
ySize = len(src)-2
used = [ 0 ] * 16
print(xSize,"x",ySize," cells")

data = [0xABCD,16,32,16,0]



for y in range(1,ySize+1):
	row = []
	for x in range(1,xSize+1):
		bits = 0
		bits = (bits + 1) if src[y-1][x] == '.' else bits
		bits = (bits + 2) if src[y][x+1] == '.' else bits
		bits = (bits + 4) if src[y+1][x] == '.' else bits
		bits = (bits + 8) if src[y][x-1] == '.' else bits
		bits = bits ^ 15
		used[bits] += 1
		pattern = bits + 0x110 
		pattern = pattern if pattern != 0x110 else 0x010
		row.append(pattern)
	while len(row) != 32:
		row.append(0)
	data += row
while len(data) != 32*16+5:
	data.append(0)

if True:
	cList = []
	for y in range(0,ySize-1):
		for x in range(0,xSize-1):
			cp = 5 + x + y * 32
			if (data[cp] & 2) != 0 and (data[cp+1] & 8) != 0:
				cList.append(cp)
				cList.append(cp+1)
			if (data[cp] & 4) != 0 and (data[cp+32] & 1) != 0:
				cList.append(cp)
				cList.append(cp+32)
	for c in cList:
		data[c] = 0x00F

	for y in range(0,ySize-1):
		for x in range(0,xSize-1):
			cp = 5 + x + y * 32

for y in range(0,ySize-1):
	for x in range(0,xSize-1):
		cp = 5 + x + y * 32

print(bits,used)
print("\n".join(src))
h = open("pacman.dat","wb")
h.write(bytes([0,0]))
for d in data:
	h.write(bytes([d & 0xFF]))
	h.write(bytes([d >> 8]))
h.close()
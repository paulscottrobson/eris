' **************************************************************************************************
'
'									Simple Maze Game
'
' **************************************************************************************************

cls
call createMaze(7,7)
call drawMaze(10)
end




proc createMaze(w,h)
	local x,y,goEast
	maze.width = w:maze.height = h
	dim maze(w,h): rem "bit 0,n bit 1,e bit 2,s bit 3,w"
	for x = 1 to w:for y = 1 to h:maze(x,y) = 15:next y:next x
	for x = 1 to w:for y = 1 to h
		goEast = random(0,1)
		if x = w then goEast = 0
		if y = h then goEast = 1
		if goEast <> 0 and x < w
			maze(x,y) = maze(x,y)-2:maze(x+1,y) = maze(x+1,y)-8
		endif
		if goEast = 0
			maze(x,y) = maze(x,y)-4:maze(x,y+1) = maze(x,y+1)-1
		endif
	next y:next x
endproc

proc drawMaze(size)
	local xc,yc,x,y
	for xc = 1 to maze.width
		x = (xc - 1) * (size+1)
		for yc = 1 to maze.height
			y = (yc - 1) * (size+1)
			if maze(xc,yc) and 1 then ink 1:line x,y to x+size,y
			if maze(xc,yc) and 2 then ink 2:line x+size,y to x+size,y+size
			if maze(xc,yc) and 4 then ink 3:line x,y+size to x+size,y+size
			if maze(xc,yc) and 8 then ink 6:line x,y to x,y+size
		next yc
	next xc
endproc




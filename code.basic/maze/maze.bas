' **************************************************************************************************
'
'									Simple Maze Game
'
' **************************************************************************************************

cls
call initialise.Maze(20,20)
call create.Maze()
call draw.Maze(10)
end

proc initialise.Maze(w,h)
	maze.width = w:maze.height = h
	dim maze(w+1,h+1):dim maze.dir(4,3)
endproc
'
'		Create a new maze
'
proc create.Maze()
	local x,y
	rem "set all to not visited"
	for x = 1 to maze.width:for y = 1 to maze.height
		maze(x,y) = -1
	next y:next x
	maze.not.visited = maze.width * maze.height
	call maze.walk(maze.width/2,maze.height/2)
	while maze.not.visited > 0
		call maze.hunt()
	wend
endproc
'
'		Do a hunt
'
proc maze.hunt()
	local x1,y1,n
	for x1 = 1 to maze.width
		for y1 = 1 to maze.height
			if maze(x1,y1) > 0
				call maze.get.exits(x1,y1)
				if maze.exit.count > 0				
					n = random(1,maze.exit.count)
					x = x1:y = y1:call maze.open.exit(n)
					call maze.walk(x,y)
				endif
			endif
		next y1
	next x1
endproc
'
'		Do a walk
'
proc maze.walk(x,y)
	local n:cls:print x,y,maze.not.visited
	call maze.get.exits(x,y)
	if maze(x,y) < 0 then maze.not.visited = maze.not.visited-1
	maze(x,y) = maze(x,y) and 15
	while maze.exit.count > 0
		n = random(1,maze.exit.count)
		call maze.open.exit(n)
		call maze.get.exits(x,y)
	wend
endproc
'
'		Open exit n in the current square
'
proc maze.open.exit(n)
	maze(x,y) = maze(x,y) - (1 << maze.dir(n,3))
	x = maze.dir(n,1):y = maze.dir(n,2)
	maze(x,y) = 15-(1 << (maze.dir(n,3) xor 2))
	maze.not.visited = maze.not.visited-1
endproc
'
'		Get potential maze exits.
'
proc maze.get.exits(x,y)
	local n = 1
	if x > 1 and maze(x-1,y) < 0 then maze.dir(n,1) = x-1:maze.dir(n,2) = y:maze.dir(n,3) = 3:n = n + 1
	if x < maze.width and maze(x+1,y) < 0 then maze.dir(n,1) = x+1:maze.dir(n,2) = y:maze.dir(n,3) = 1:n = n + 1
	rem
	if y > 1 and maze(x,y-1) < 0 then maze.dir(n,1) = x:maze.dir(n,2) = y-1:maze.dir(n,3) = 0:n = n + 1
	if y < maze.height and maze(x,y+1) < 0 then maze.dir(n,1) = x:maze.dir(n,2) = y+1:maze.dir(n,3) = 2:n = n + 1
	maze.exit.count = n-1
endproc
'
'		Simple maze drawer
'
proc draw.Maze(size)
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




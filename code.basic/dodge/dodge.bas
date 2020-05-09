' **************************************************************************************************
'
'					Dodge 'Em - based on the Atari 2600 Version
'
' **************************************************************************************************

cls:screen 3,1
call centretext(60,3,4,"Dodge'Em")
call centretext(180,2,1,"1 for One Chaser, 2 for Two chasers")
repeat
	a$ = get$()
until a$ = "1" or a$ = "2"
screen 2,2:sprite load "dodge.spr"
palette 1,0,5:palette 2,0,3:palette 3,0,1
palette 1,1,3:palette 2,1,6
call createGameData(val(a$))
call resetGame()
call resetCarData(game.cars)

repeat
	life.lost = false
	repeat
		call moveCars()
	until life.lost or grid.count = 0
	if life.lost 
		call explosion(car.x(0),car.y(0))
		call resetCarData(game.cars):game.lives = game.lives - 1:call refreshScore()
	endif
	if grid.count = 0 then call resetGame():call resetCarData(game.cars)
	if game.lives > 0 then wait 200
until game.lives = 0
end
'
'		Create game data
'
proc createGameData(chaserCount)
	local x,y
	grid.size = 9:grid.cellSize = 20:grid.lanes = 4
	x = 160-(grid.size-1)*grid.cellSize/2
	y = 120-(grid.size-1)*grid.cellSize/2+10
	dim grid(grid.size,grid.size):rem "bit 0 dot, bit 1 switch, bit 2 corner"
	dim xc(grid.size),yc(grid.size):rem "coordinates of grid centre"
	for i = 0 to grid.size
		xc(i) = i * grid.cellSize+x
	next i
	for i = 0 to grid.size
		yc(i) = i * grid.cellSize+y
	next i
	rem
	dim car.x(4),car.y(4),car.xi(4),car.yi(4),car.distance(4),car.level(4)
	car.speed = 3
	game.score = 0
	game.lives = 3
	game.cars = chaserCount+1
endproc
'
'		Move all cars.
'
proc moveCars()
	local n,d,x,y,c
	if event(car.event,4)
		for n = 0 to car.count-1
			d = car.speed:if n = 0 and joyb(1) <> 0 then d = d * 2
			if d > car.distance(n) then d = car.distance(n)
			car.x(n) = car.x(n) + car.xi(n) * d
			car.y(n) = car.y(n) + car.yi(n) * d
			car.distance(n) = car.distance(n) - d
			call drawCar(n)
			if car.distance(n) = 0				
				x = (car.x(n)-xc(0)) / grid.cellSize
				y = (car.y(n)-yc(0)) / grid.cellSize
				if grid(x,y) <> 0
					if grid(x,y) and 4 
						c = 1:if n > 0 then c = -1
						d = car.xi(n):car.xi(n) = car.yi(n)*c:car.yi(n) = -d*c
					endif
					if n = 0
						call hitCellPlayer(n,x,y,grid(x,y))
					else
						call hitCellChaser(n,x,y,grid(x,y))
					endif						
				endif
				car.distance(n) = grid.cellSize
			endif
			if n > 0 then if hit(0,n) then life.lost = true
		next n
	endif
endproc
'
'		Player hit element
'
proc hitCellPlayer(n,x,y,e)
	if e and 1
		game.score = game.score + 1:call refreshScore():sound 1,3333,1
		ink 0:draw xc(x)-8,yc(y)-8,12
		grid(x,y) = grid(x,y) - 1
		grid.count = grid.count - 1
	endif
	if e and 2
		if car.xi(n) <> 0
			call shiftCarLevel(n,car.level(n)-joyy()*car.xi(n))
		else
			call shiftCarLevel(n,car.level(n)+joyx()*car.yi(n))
		endif
	endif
endproc
'
'		Chaser hit element
'
proc hitCellChaser(n,x,y,e)
	local mv
	if (e and 2) <> 0 then call shiftCarLevel(n,car.level(n)+(random(0,1)*2-1))
endproc
'
'		Move car n to level 
'
proc shiftCarLevel(n,level)
	local t
	if level >= 0 and level < grid.lanes and level <> car.level(n)
		if car.xi(n) <> 0
			t = car.y(n)
			car.y(n) = yc(level):if t >= yc(grid.size/2) then car.y(n) = yc(grid.size-1-level)
		endif
		if car.yi(n) <> 0
			t = car.x(n)
			car.x(n) = xc(level):if t >= xc(grid.size/2) then car.x(n) = xc(grid.size-1-level)
		endif
		car.level(n) = level
	endif
endproc
'
'		Reset car data
'
proc resetCarData(n)
	car.count = n
	for i = 0 to n-1
		car.x(i) = xc(grid.size/2):car.y(i) = yc(i)
		car.xi(i) = (sgn(i)*2-1):car.yi(i) = 0
		car.distance(i) = grid.cellSize
		car.level(i) = i
		call drawCar(i)
	next i
	car.event = 0
endproc
'
'		Repaint sprite
'
proc drawCar(i)
	local col = 2:if i = 0 then col = 1
	local gfx = 11:if car.xi(i) = 0 then gfx=10
	sprite i to car.x(i),car.y(i) draw gfx ink col
endproc
'
'		Reset game data
'
proc resetGame()
	local x,y,t,xsw,ysw,w
	cls:grid.count = 0
	xsw = grid.size/2:ysw = grid.size/2
	for x = 0 to grid.size-1
		for y = 0 to grid.size-1
			grid(x,y) = 0
			if x < grid.lanes or y < grid.lanes or x >= grid.size-grid.lanes or y >= grid.size-grid.lanes
				if x <> xsw and y <> ysw			
					grid(x,y) = 1:ink 3:draw xc(x)-8,yc(y)-8,12:grid.count = grid.count + 1
					if x = y or x = grid.size-1-y then grid(x,y) = 5
					grid.count = grid.count + 1
				else
					grid(x,y) = 2
				endif
			endif
		next y
	next x
	for t = 0 to grid.lanes-1
		ink 2:w = grid.cellSize/2
		frame xc(t)-w,yc(t)-w to xc(grid.size-t-1)+w,yc(grid.size-t-1)+w
	next t
	ink 0:rect xc(xsw)-w,0 to xc(xsw)+w,239:rect 0,yc(ysw)-w to 319,yc(ysw)+w
	t = grid.lanes:ink 2:frame xc(t)+w,yc(t)+w to xc(grid.size-t-1)-w,yc(grid.size-t-1)-w
	call refreshScore()
endproc
'
'		Reset display
'
proc refreshScore()
	call drawDigit(120,game.lives,1)
	call drawDigit(180,game.score/100,2)
	call drawDigit(205,game.score/10 mod 10,2)
	call drawDigit(230,game.score mod 10,2)
endproc
'
proc drawDigit(x,digit,colour)
	blit x,0,digit,&0300+colour,&1810
endproc
'
'				Centre print
'
proc centreText(y,colour,size,text$)
	ink colour
	text 160-len(text$)*3*size,y,text$,size
endproc	
'
'				Explosion
'
proc explosion(x,y)
	t1 = timer()+50:draw on 1
	while timer() < t1
		ink random(0,7):draw x-8,y-8,random(256,1024)
	wend
	ink 0:rect x-8,y-8 to x+8,y+8
	draw on 0
endproc
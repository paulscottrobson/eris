' **************************************************************************************************
'
'					Dodge 'Em - based on the Atari 2600 Version
'
' **************************************************************************************************

screen 2,2:sprite load "dodge.spr"
palette 1,0,5:palette 2,0,3:palette 3,0,1
palette 1,1,3:palette 2,1,6
call createCoordinates()
call createVehicles()
call resetDraw()
call resetVehicles(3)
life.lost = false
repeat
	call MoveVehicles()
until life.lost
end


'
'		Create arrays and grid positions
'
proc createCoordinates()
	local x,y
	map.hSize = 10:map.vSize = 10
	map.xSpacing = 24:map.ySpacing = 20
	dim xc(map.hSize),yc(map.vSize): rem "coordinates of grid array where corners/dots are"
	dim grid(map.hSize,map.vSize): rem "map of grid : bit 0 = dot, bit 1 = corner"
	for x = 1 to map.hSize
		xc(x) = 160 - (map.hSize-1)*map.xSpacing/2 + (x-1) * map.xSpacing
	next x
	for y = 1 to map.vSize
		yc(y) = 120 + 10 - (map.vSize-1)*map.ySpacing/2 + (y-1) * map.ySpacing
	next y
endproc			
'
'		Create vehicles
'
proc createVehicles()
	dim car.x(4),car.y(4):rem "car positions in pixels"
	dim car.onPoint(4):rem "Car on a dot/corner last time"
	dim car.switch(4):rem "Car switches lane this time"
	dim car.dir(4):rem "current movement - 0 = N, 1 = E, 2 = S 3 = W"
	dim car.clock(4):rem "+1 clockwise, -1 anticlockwise"
	dim car.ring(4):rem "ring 1..4"
endproc
'
'		Reset the vehicles to their starting positions
'
proc resetVehicles(total)
	car.total = total
	for i = 1 to total
		car.x(i) = xc(7):car.y(i) = yc(i):car.onPoint(i) = false
		if i > 1 
			car.dir(i) = 1:car.clock(i) = 1
		else
			car.dir(i) = 3:car.clock(i) = 3
		endif
		car.switch(i) = -1
		car.ring(i) = i
		call drawVehicle(i)
	next i
endproc
'
'		Move vehicles
'
proc moveVehicles()
	local i,mstep
	local d,xi,yi,x1,y1,onPoint
	if event(car.move,6) 
		for i = 1 to car.total
			mstep = 4:xi = 0:yi = 0
			if i = 1 and joyb(1) then mstep = mstep * 2
			if car.dir(i) = 0 then yi = -mstep
			if car.dir(i) = 1 then xi = mstep
			if car.dir(i) = 2 then yi = mstep
			if car.dir(i) = 3 then xi = -mstep
			car.x(i) = car.x(i)+xi:car.y(i) = car.y(i)+yi
			x1 = (car.x(i)-xc(1))/map.xSpacing+1
			y1 = (car.y(i)-yc(1))/map.ySpacing+1
			onPoint = (abs(car.x(i)-xc(x1))+abs(car.y(i)-yc(y1))) <= mstep*2 
			if onPoint and not car.onPoint(i) 
				if i = 1 and (grid(x1,y1) and 1)
					game.score = game.score + 1
					map.count = map.count - 1
					grid(x1,y1) = grid(x1,y1)-1
					ink 0:draw xc(x1)-8,yc(y1)-8,12
					call refreshScore()
				endif
				if grid(x1,y1) and 2
					car.x(i) = xc(x1):car.y(i) = yc(y1)
					car.dir(i) = (car.dir(i)+car.clock(i)) and 3
					car.switch(i) = -1
					if random(0,2) = 0 then car.switch(i) = random(5,6)
				endif
				if x1 = car.switch(i) or y1 = car.switch(i)
					call switchLane(i)
				endif
			endif
			car.onPoint(i) = onPoint
			call drawVehicle(i)
			if i <> 1 and hit(1,i) then life.lost = true
		next i
	endif
endproc
'
'		Switch lanes
'
proc switchLane(i)
	local mv
	repeat
		mv = random(0,1)*2-1
	until mv+car.ring(i) >= 1 and mv+car.ring(i) <= 4
	if car.dir(i) = 0 or car.dir(i) = 2
		car.x(i) = car.x(i)-sgn(car.x(i)-160)*mv*map.xSpacing
	else
		car.y(i) = car.y(i)-sgn(car.y(i)-130)*mv*map.ySpacing
	endif
	car.ring(i) = car.ring(i)+mv
	car.switch(i) = -1
endproc				

'
'		Refresh vehicle n.
'
proc drawVehicle(n)
	local gfx = 10:if (car.dir(n) and 1) then gfx = 11
	local col = 2:if n = 1 then col = 1
	sprite n to car.x(n),car.y(n) draw gfx ink col
endproc
'
'		Reset and draw map and score
'
proc resetDraw()
	local x,y,accept,o
	cls:map.count = 0
	for i = 0 to 3
		ink 3
		frame xc(i+1)-map.xSpacing/2,yc(i+1)-map.ySpacing/2 to xc(map.hSize-i)+map.xSpacing/2,yc(map.vSize-i)+map.ySpacing/2
	next i
	ink 0
	rect xc(5)-map.xSpacing/2,0 to xc(6)+map.xSpacing/2,239
	rect 0,yc(5)-map.ySpacing/2 to 319,yc(6)+map.ySpacing/2
	ink 3
	frame xc(5)-map.xSpacing/2,yc(5)-map.ySpacing/2 to xc(6)+map.xSpacing/2,yc(6)+map.ySpacing/2
	for x = 1 to map.hSize
		for y = 1 to map.vSize
			grid(x,y) = 0
			accept = x <> 5 and y <> 5 and x <> 6 and y <> 6
			if accept
				grid(x,y) = 1:ink 3
				if x = y or x = map.hSize+1-y then grid(x,y) = 3
				draw xc(x)-8,yc(y)-8,12
				map.count = map.count + 1
			endif
		next y
	next x
	grid(1,1) = 3:grid(1,map.vSize) = 3
	grid(map.hSize,1) = 3:grid(map.hSize,map.vSize) = 3
	game.score = 0:game.lives = 3
	call refreshLives()
	call refreshScore()
endproc
'
'		Refresh lives
'
proc refreshLives()
	ink 0:rect 100,0 to 130,28
	ink 1:draw 100,0,game.lives dim 2
endproc
'
'		Refresh score
'
proc refreshScore()
	local x = 200
	ink 0:rect 200,0 to 290,28
	ink 2
	draw x,0,game.score/100 dim 2
	draw x+24,0,game.score/10 mod 10 dim 2
	draw x+48,0,game.score mod 10 dim 2
endproc


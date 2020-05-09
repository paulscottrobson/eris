' **************************************************************************************************
'
'					Breakout - based on the Atari Video Pinball version
'
' **************************************************************************************************

cls:screen 3,1:palette 4,0,6:palette 1,1,7
call centretext(60,3,4,"Breakout")
call centretext(180,2,1,"Press 1 for Breakout, 2 for Breakthru")
repeat
	a$ = get$()
until a$ = "1" or a$ = "2"
sprite load "breakout.spr"
dim brick(13,5),yPos(5),xPos(13):brick.width = 310/14:brick.height = 8
dim bat.width(3):bat.width(0) = 20:bat.width(1) = 32:bat.width(2) = 8:bat.width(3) = 16
call game(7,1,a$ = "2")
screen 3,1:end
'
'					Play one Game
'
proc game(balls,batInitWidth,isBreakthru)
	score = 0
	cls:call drawScore(score):call resetWall(isBreakthru)
	bat.x = 160:bat.y = 235:bat.size = batInitWidth:bat.radius = bat.width(bat.size)/2
	sprite 0 draw bat.size+10 ink 1 dim 2 to bat.x,bat.y
	repeat
		call resetBall():call drawBalls(balls)
		wait 100
		repeat
			call moveBat()
			call moveBall()
		until ball.y >= 240 or brick.count = 0
		if ball.y >= 240 
			balls = balls - 1
		else
			call resetWall(isBreakthru)
		endif
	until balls = 0
endproc
'
'		Reset the ball
'
proc resetBall()
	ball.x = random(40,280):ball.y = yPos(5)+32:ball.speed = 2
	ball.xi = 0:ball.yi = ball.speed
	ball.hitBackWall = false:ball.hitGreen = false
	sprite 1 draw 14 ink 1 to ball.x,ball.y
endproc
'
'		Move the bat
'
proc moveBat()
	local offset
	bat.x = bat.x + joyx()*4
	if bat.x < bat.radius+5 then bat.x = bat.radius+5
	if bat.x >= 316-bat.radius then bat.x = 316-bat.radius
	sprite 0 to bat.x,bat.y
endproc
'
'		Move the ball
'
proc moveBall()
	local x,y

	ball.x = ball.x + ball.xi:ball.y = ball.y + ball.yi
	if ball.x < 8 then ball.x = 8:ball.xi = abs(ball.xi):sound 1,5555,1
	if ball.x >= 312 then ball.x = 312:ball.xi = -abs(ball.xi):sound 1,5555,1
	if ball.y > bat.y 
		offset = ball.x-bat.x
		if abs(offset) <= bat.radius
			ball.xi = abs(offset*2/bat.radius)+1
			if ball.x < bat.x then ball.xi = -ball.xi
			ball.yi = -ball.yi
			sound 1,5555,1
		endif
	endif

	if ball.y < 0 
		ball.y = ball.y-ball.yi:ball.yi = -ball.yi
		if ball.hitBackWall = false
			bat.size = bat.size + 2
			bat.radius = bat.width(bat.size)/2
			sprite 0 draw bat.size+10
			ball.hitBackWall = true
		endif
		sound 1,5555,1
	endif
	if ball.y >= yPos(0) and ball.y < yPos(5)+brick.height-1
		y = (ball.y - yPos(0)) / brick.height
		x = (ball.x - xPos(0)) / brick.width:if x > 13 then x = 13
		if brick(x,y) <> 0
			score = score + (5-y) * 2 + 1:call drawScore(score)
			if brick(x,y) <= 2 and ball.hitGreen = 0
				ball.hitGreen = true:ball.speed = ball.speed + 1
			endif
			brick(x,y) = 0:call drawBrick(x,y)
			ball.yi = -ball.yi
			brick.count = brick.count - 1
			sound 1,15555,1
		endif
	endif
	sprite 1 to ball.x,ball.y
endproc
'
'			  Reset and redraw the wall
'
proc resetWall(isBreakthru)
	local x,y
	draw on 1:ink 1
	rect 0,0 to 4,239:rect 316,0 to 319,239
	draw on 0
	brick.count = 0
	for y = 0 to 5
		yPos(y) = 32+y*brick.height
		for x = 0 to 13
			if y = 0 then xPos(x) = 5+x*brick.width
			brick(x,y) = y/2+1
			if isBreakthru<>0 and (y = 2 or y = 3) then brick(x,y) = 0
			if brick(x,y) <> 0 then call drawBrick(x,y):brick.count = brick.count + 1
		next x
	next y
endproc
'
'				   Draw the score
'
proc drawScore(score)
	if score > 99 then call drawDigit(32,score/100)
	if score > 9  then call drawDigit(52,score/10 mod 10)
	call drawDigit(72,score mod 10)
endproc
'
'				Draw the number of balls
'
proc drawBalls(balls)
	call drawDigit(268,balls)
endproc
'
'				Draw a single digit.
'
proc drawDigit(x,digit)
	blit x,0,digit,&0704,&1810:draw on 0
endproc
'
'				Draw a brick
'
proc drawBrick(x,y)
	ink brick(x,y)
	x = xPos(x):y = yPos(y):rect x+2,y to x+brick.width-2,y+brick.height-4
endproc
'
'				Centre print
'
proc centreText(y,colour,size,text$)
	ink colour
	text 160-len(text$)*3*size,y,text$,size
endproc	
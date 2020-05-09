'
'			Simple Squash Game. *Very* rough and ready, more testing than anything.
'
cls:screen 2,2
'
'			Manually create sprites by poking image memory. Not good practice normally :)
'
batSprite = sysvar(3):ballSprite = sysvar(3)+16
for i = 0 to 15:batSprite!i = &0300:ballSprite!i = 0:next i
for i = 6 to 11:ballSprite!i = &07E0:next i
'
'			Create sprites and draw frame
'
palette 3,1,6
sprite 0 to 100,100 draw 0 ink 1 dim 2
sprite 1 to 200,100 draw 1 ink 3

ink 2:rect 0,0 to 319,3:rect 0,236 to 319,239:Rect 316,0 to 319,239
'
'			Set everything up
'
score = 0
ball.x = 40:ball.y = random(20,220):ball.xi = 2:ball.yi = random(0,1)*4-2:ball.radius = 3
bat.x = 20:bat.y = 120:bat.size = 32:bat.speed = 4
cursor 4,2:ink 3:print "Score ";score;
'
'			Main loop
'
while ball.x >= 0
	wait 1
	newY = bat.y + bat.speed*joyy()
	if newY > bat.size/2 and newY < 239-bat.size/2
		bat.y = newY
		sprite 0 to bat.x,bat.y
	endif
	reject = False
	newX = ball.x + ball.xi
	newY = ball.y + ball.yi
	if newX < bat.x and abs(ball.y-bat.y) <= bat.size
		ball.xi = abs(ball.xi)
		diff = ball.y-bat.y
		ball.yi = (abs(diff*4/bat.size)+1)*sgn(diff)
		if ball.yi = 0 then ball.yi = random(0,1)*2-1
		score = score + 1
		cursor 4,2:ink 3:print "Score ";score;
		sound 1,28888,1
		reject = True
	endif
	if newX > 319-ball.radius then reject = True:ball.xi = -ball.xi
	if newY < ball.radius+4 then reject = True:ball.yi = -ball.yi
	if newY > 239-ball.radius-4 then reject = True:ball.yi = -ball.yi
	if reject = 0 
		ball.x = newX:ball.y = newY:sprite 1 to ball.x,ball.y
	else
		sound 1,14444,1
	endif
wend


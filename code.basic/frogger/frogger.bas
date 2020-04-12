' **************************************************************************************************
'
'											Frogger
'
' **************************************************************************************************
'
'	TODO: Use the scrolling to define the timer and switch depending on sync.
'
screen 3,1
!&FFFD = true:call create.Tilemaps():!&FFFD = false
p = 0:e.shiftSet = 0

c = 0:t1 = timer()

while timer()-t1 < 500
	if p < 15
		p = p + 1:d = map(p)
		if d <> 0
			n = (!d+(d!1)) and &1FFF:!d = n
			if ((d!2 xor n) and &FFC0) then d!2 = n:tile 0,p*16,n>>4,0,64,1,d+3
		endif
	else
		if event(e.shiftSet,12) then p = 0:c = c + 1
	endif
wend

cls:print timer()-t1,c
end


'
'		Create tilemaps for the lanes.
'
proc create.tilemaps()
	local t,a,i,n
	sprite load "frogger.spr":game.hiScore = 1000
	' Frame part
	ink 3:cursor 24,0:print "HI-SCORE":cursor 12,0:print "1-UP";
	ink 1:cursor 11,1:print "000000";:cursor 25,1:print "001000";
	for i = 0 to 304 step 16
		ink 2:draw i,16,16:draw i,32,15
		ink 5:draw i,128,15:draw i,224,15
	next i
	' Home spaces
	dim home.x(5),home.used(5):n = 60:home.width = 24
	for i = 1 to 5
		home.x(i) = 160+n*(i-1)-2*n
		ink 0:rect home.x(i)-home.width/2,2*16 to home.x(i)+home.width/2,2*16+15
	next i:ink 1
	' Tilemaps for road / river
	dim map(15):rem "addresses +0 pos.16 +1 speed.16 +2 last.16 +3 tilemap as per spec 64 x 1"
	map.table = alloc(16)
	dim turtle.addr(32),turtle.size(32):turtle.count = 0
	for i = 0 to 15:map(i) = 0:map.table!i = 0:next i
	for i = 3 to 13
		if i <> 8
			a = alloc(72):map(i) = a:map.table!i = 0
			a!0 = random(0,31*16*16-1):a!1 = 0:a!2 = -1
			t = a + 3
			t!0=&ABCD:t!1=16:t!2=64:t!3=1:t!4 = 0
			for n = 5 to 31+5:t!n=0:next n
			if i = 13 then call generate.lane(t+5,10,7,4,6,&4000):speed = -1
			if i = 12 then call generate.lane(t+5,11,6,3,8,0):speed = 1
			if i = 11 then call generate.lane(t+5,12,5,3,6,&4000):speed = -2
			if i = 10 then call generate.lane(t+5,10,3,3,8,0):speed = 2
			if i = 9 then call generate.lane(t+5,14,7,5,8,&4000):speed = -1

			if i = 7 then call generate.river(t+5,7,1,3,2,4,0):speed = 1
			if i = 6 then call generate.river(t+5,4,3,3,2,4,0):speed = -1
			if i = 5 then call generate.river(t+5,4,3,2,2,4,0):speed = 2
			if i = 4 then call generate.river(t+5,7,1,2,3,4,&4000):speed = -2
			if i = 3 then call generate.river(t+5,4,3,2,2,4,0):speed = 3

			a!1 = -speed * 16
			tile 0,i*16,(a!0)>>4,0,64,1,t

			a = t + 32
			for n = 5 to 36:a!n = t!n:next n
		endif
	next i
endproc
'
proc generate.lane(map,graphic,col,n1,n2,bits)
	local c = 0
	while c < 32
		map!c = graphic+col*256+bits:if graphic = 14 then map!(c+1) = (map!c)-1
		c = c + random(n1,n2)
	wend
endproc
'
proc generate.river(map,graphic,col,size,n1,n2,bits)
	local c = 0:local i
	while c < 32-size
		if graphic = 7
			turtle.count = turtle.count + 1
			turtle.addr(turtle.count) = map+c
			turtle.size(turtle.count) = size
		endif
		for i = 1 to size
			if graphic = 7 
				map!c = graphic+col*256+bits
			else
				g = graphic:if i > 1 then g = g+1:if i = size then g = g+1
				map!c = g+col*256+bits				
			endif
			c =c+1
			next i
		c = c + random(n1,n2)
	wend
endproc

room.size = 32:x.scale = 2:y.scale = 2
call draw.room(1)
sprite load "aticatac.spr"
for i = 0 to 3
	call draw.door(i,3,i mod 3+1)
next i
end


;
;		Draw a room in current scale and givn style
;
proc draw.room(isCave)
	local x.scale1 = x.scale*10:if x.scale1 = 10 then x.scale1 = 13
	local y.scale1 = y.scale*10:if y.scale1 = 10 then y.scale1 = 13
	ink 0:rect 0,0 to 255,239:palette 3,0,7
		local cx,cy:cx = 128:cy = 120+58*y.scale:ink 3
	if isCave
		cy = 128+52*y.scale
		call line(12,56):call line(24,49):call line(40,57)
		call line(52,52):call line(47,35):call line(55,15)
		call line(50,0)
	else
		call line(45,58):call line(58,45):call line(58,0)
	endif
	ink 0:rect 128-room.size*x.scale,120-room.size*y.scale to 128+room.size*x.scale,120+room.size*y.scale
	ink 3:frame 128-room.size*x.scale,120-room.size*y.scale to 128+room.size*x.scale,120+room.size*y.scale
endproc
;
;		Draw one door
;
proc draw.door(door,gfx,col)
	local x = 128-16:local y = 120-16:local bflip = 0
	if door = 0 then y = y - room.size*y.Scale-16
	if door = 1 then x = room.size*x.Scale+128:gfx = gfx+8
	if door = 2 then y = room.size*y.Scale+120:bflip = &6000
	if door = 3 then x = x - room.size*x.scale-16:gfx = gfx+8:bflip = &6000
	blit x,y,sysvar(3)+gfx*16,&0300+col,&1010+bflip
endproc
;
;		Line drawer, support routine for room draw, draws in four quadrants
;
proc line(x,y)
	local x1,y1:x1 = x*x.scale1/10+128:y1 = y*y.scale1/10+120
	if y <> 0
		line 128,120 to x1,y1:line 128,120 to 256-x1,y1
		line 128,239-120 to x1,239-y1:line 128,239-120 to 256-x1,239-y1
	endif
	line cx,cy to x1,y1:line 256-cx,cy to 256-x1,y1
	line cx,239-cy to x1,239-y1:line 256-cx,239-cy to 256-x1,239-y1
	cx = x1:cy = y1
endproc

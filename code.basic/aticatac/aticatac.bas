call draw.room(2,2,1,32)
sprite load "aticatac.spr"
ink 2
for i = 0 to 15
	draw i mod 8*34,i/8*34,i dim 2
next i
end



proc draw.room(xs,ys,isCave,floor)
	ink 0:rect 0,0 to 255,239:palette 3,0,7
		local cx,cy:cx = 128:cy = 120+58*ys:ink 3
	if isCave
		cy = 128+47*ys
		call line(12,56):call line(24,49):call line(40,57)
		call line(52,52):call line(47,35):call line(55,12)
		call line(50,0)
	else
		call line(58,58):call line(58,0)
	endif
	ink 0:rect 128-floor*xs,120-floor*ys to 128+floor*xs,120+floor*ys
	ink 3:frame 128-floor*xs,120-floor*ys to 128+floor*xs,120+floor*ys
endproc

proc line(x,y)
	local x1,y1:x1 = x*xs+128:y1 = y*ys+120
	if y <> 0
		line 128,120 to x1,y1:line 128,120 to 256-x1,y1
		line 128,239-120 to x1,239-y1:line 128,239-120 to 256-x1,239-y1
	endif
	line cx,cy to x1,y1:line 256-cx,cy to 256-x1,y1
	line cx,239-cy to x1,239-y1:line 256-cx,239-cy to 256-x1,239-y1
	cx = x1:cy = y1
endproc
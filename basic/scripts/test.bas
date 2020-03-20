cls
gfx = sysvar(3)+16
for i = 0 to 15
if i mod 2 = 0 gfx!i=&AAAA else gfx!i=&5555 endif
gfx!i = gfx!i or &8001
next i
gfx!0=-1:gfx!15=-1
for j = 0 to 3
for i = 0 to 16
blit i*18+2,j*18+2,1,&0F00+i,16
next i
next j


code alloc(256),0
a$ = "EE-Hub-S6sd/Jane1970"
test = rpl(#a$ 8 2 &0010 sys . cr)
sys test
a$ = "eris.data"
test2 = rpl(#a$ 9 2 &0010 sys . cr)
sys test2
dir
load "www.prg"
end

repeat
for i= 32 to 126
!&FFFC = i
next i
until false

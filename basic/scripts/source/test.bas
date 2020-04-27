code alloc(256),0
a$ = "http://github.com/demo;EE-Hub-S6sd;Jane1970"
test = rpl(#a$ 8 2 &0010 sys . cr)
sys test
dir
end

repeat
for i= 32 to 126
!&FFFC = i
next i
until false

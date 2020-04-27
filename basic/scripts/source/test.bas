code alloc(256),0
f$ = "testfile"
a$ = "http://www.studio2.org.uk/studio2.org.uk/paulscottrobson/"+f$+";EE-Hub-S6sdx;Jane1970"
test = rpl(#a$ 8 2 &0010 sys . cr)
sys test
test = rpl(#f$ 7 2 &0010 sys . cr)
sys test
dir
end

repeat
for i= 32 to 126
!&FFFC = i
next i
until false

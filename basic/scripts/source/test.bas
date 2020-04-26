

;code alloc(256),0
;a$ = "EE-Hub-S6sd/Jane1970"
;test = rpl(#a$ 8 2 &0054 sys . cr)
;sys test
;a$ = "testfile"
;test2 = rpl(#a$ 9 2 &0054 sys . cr)
;sys test2

repeat
for i= 32 to 126
!&FFFC = i
next i
until false

;print exists("sed")
;print exists("see")
;print exists("maze.spr")
;print exists("autoexec.prg")
;load "autoexec.prg",&6000
code alloc(256),0
a$ = "autoexec.prg"
a$ = "sed"
print exists(a$)
test = rpl(#a$ 6 2 &0054 sys . cr)
sys test
test2 = rpl(#a$ 7 2 &0054 sys . cr)
sys test2

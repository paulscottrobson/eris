mem = &6666:test = 42
code mem,0
do.star = rpl(42 emit)
do.at = rpl(64 emit)
;demo = rpl(5 for i . next cr)
;demo = rpl(5 repeat star dup . 1 - dup 0< until cr . . cr)

demo = rpl(10 for i . i 3 mod if do.star else do.at then cr next . cr)
sys demo
print "Test - ",test
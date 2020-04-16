mem = &6666:test = 42
code mem,0
star = rpl(42 emit)
;demo = rpl(5 for idx . next cr)
demo = rpl(5 repeat star dup . 1 - dup 0< until cr . . cr)
sys demo
print "Test - ",test
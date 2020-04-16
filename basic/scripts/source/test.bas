mem = &6666:test = 42
code mem,0
star = rpl(42 emit)
demo = rpl(star star cr #test . 23456 ^test cr)
sys demo
print "Test - ",test
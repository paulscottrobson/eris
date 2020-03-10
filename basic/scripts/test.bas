10 dim axxx$(4),t2$(2,3)
15 bz = 32700
18 print bz

19 axxx$(1) = "Test"
20 axxx$(3) = "Hello"
25 print axxx$(1)
30 print axxx$(3)
40 t2$(1,2) = "Demo"
45 print t2$(1,2)

 dim t(2,3)
t(2,1) = 12222
t(0,0) = 100
t(0,1) = 101
t(0,2) = 102
t(0,3) = 103 
t(1,0) = 110
t(1,1) = 111
t(1,2) = 112
t(1,3) = 113 
t(2,0) = 120
t(2,1) = 121
t(2,2) = 42
t(2,3) = 1123 

print t(0,0)
print t(0,1)
print t(0,2)
print t(0,3)
print t(1,0)
print t(1,1)
print t(1,2)
print t(1,3)
print t(2,0)
print t(2,1)
print t(2,2)
print t(2,3)
print asc("*")
print len("hello")
print str$(-42)

11111 print "hello "+"world":goto 11111
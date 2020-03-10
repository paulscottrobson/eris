100 gosub 1000:gosub 1000
110 end

1000 print "Line 1000"
1005 gosub 2000:gosub 2000
1010 return

2000 print "  Line 2000",n
2005 n = n + 1
2010 return
a$ = ",,,xbcdef,xx"
print "Parts:",sub.count(a$,",")
for i = 1 to 5
	print i,"<";sub.get$(a$,",",i);">"
next i

'
'		File system basic soak test.
'
count = 24:iteration = 0
store = alloc(4200)
dim filename$(count),dstart(count),dstep(count),dsize(count)
repeat
	iteration = iteration+1
	for i = 1 to count
		filename$(i) = "file"+str$(i)+".test"
		dstart(i) = random(0,65535)
		dstep(i) = random(0,65535)
		dsize(i) = random(10,4000)
		print filename$(i),dstart(i),dstep(i),dsize(i)
	next i

	for i = 1 to count
		print "Creating ",i
		call create(i)
		print "Saving as "+fileName$(i)
		save fileName$(i),store,dsize(i)
	next i

	total = 0
	for i = 1 to count * 3
		n = random(1,count)
		total = total + 1
		cls:print iteration,total,"Checking ",n,filename$(n)
		load filename$(n),store
		print "    Loaded, verifying ..."
		call verify(n)
	next i
until false
end

proc create(n)
	local i
	value = dstart(n)
	for i = 0 to dsize(n)-1
		store!i = value
		value = value + dstep(n)
	next i
endproc	

proc verify(n)
	local i
	value = dstart(n)
	for i = 0 to dsize(n)-1
		if value <> store!i then stop
		value = value + dstep(n)
	next i
endproc	


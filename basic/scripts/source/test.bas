every 50,0 call action.1() 
every 70,1 call action.2()
after 145,2 call action.3()
repeat
until false
end

proc action.1()
	print "Action #1"
endproc

proc action.2()
	print "Action #2"
endproc

proc action.3()
	print "Action #3"
	cancel 1
endproc
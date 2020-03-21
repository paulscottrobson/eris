zx = -42:test.var = -1:a$ = "Hello"
print ,zx,test.var,a$
call test()
print ,zx,test.var,a$
end

proc test()
local zx,test.var:zx = 93:test.var = 42
local a$:a$ = "End of Days"
print">",zx,test.var,a$
call test2()
print">",zx,test.var,a$
endproc

proc test2()
	local zx,a$:zx = 32222:a$="test2"
	print ">>",zx,test.var,a$
endproc
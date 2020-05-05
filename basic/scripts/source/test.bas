x2 = 42
print x2
local x3=-1
print x3
call test(x2)
end

proc test(n1)
	n1 = n1 * 2
	local b = 4
	print b,n1,x2,x3
endproc
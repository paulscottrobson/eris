zx = -42:test.var = -1:a$ = "Hello"
print ,zx,test.var,a$
call test()
print ,zx,test.var,a$
end

proc test()
local zx,test.var:zx = 93:test.var = 42
print">>",zx,test.var,a$
endproc
zx = -42:test.var = -1:a$ = "Hello"
c$ = "CString"
print ,zx,test.var,a$,p1,c$
call test(42,a$)
print ,zx,test.var,a$,p1,c$
call print.message("Hello",42)
print "Ended"
end

proc test(p1,new$)
local zx,test.var:zx = 93:test.var = 42
local a$:a$ = "End of Days"
print">",zx,test.var,a$,p1,"]",new$
call test2("hi !")
print">",zx,test.var,a$,p1,"]",new$
endproc

proc test2(new$)
	local zx,a$:zx = 32222:a$="test2"
	print ">>",zx,test.var,a$,new$
endproc
				
Proc print.message(msg$,n)
Print msg$+"World  x "+str$(n)
Endproc

rem "first" 
xa = 42:a = -2
poke &7000,xa
sys &24	
call test2:call test2:call test1
end

proc test1
	print "test1",xa
endproc

proc test2
	print "test2",xa,
	xa = xa + 1
	call test3
endproc

proc test3
	print "test3"
endproc

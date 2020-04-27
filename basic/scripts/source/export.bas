'
'		Export data through serial port
'
!&FFFD=1
;
;		Allocate workspace
;
work.size = 12000
work = alloc(work.size)
;
;		Call OS to read directory and copy into array
;
sys 16,4,work
dim dir$(128)
p = 0:dir.count = 0
while work!p <> 0
	a$ = ""
	while work!p > 32:a$ = a$+chr$(work!p):p = p + 1:wend
	if work!p = 32 then p = p + 1
	dir.count = dir.count + 1:dir$(dir.count) = a$
wend
;
;		Export each file to the transfer port
;
for i = 1 to dir.count
	f$ = dir$(i)
	;	#N: <name>
	call transmit("#N:"+f$)
	; 	#L: <load address>
	load.addr = sys(&10,6,@f$)
	call transmit("#L:"+to.string$(load.addr,16))
	; 	#S: <File size words>
	size = sys(&10,7,@f$)
	call transmit("#S:"+to.string$(size,16))
	;	Check it fits and load it in
	assert size <= work.size
	print i;"/";dir.count;" Sending "+f$+" ("+str$(size)+" words)"
	load f$,work
	; 	#D: Send in 16 word chunks with a 15 bit checksum.
	p = work
	while size > 0
		words = min(16,size)
		checksum = 0
		a$ = "#D:"
		for j = 0 to words-1
			a$ = a$ + right$("0000"+to.string$(!p,16),4)
			checksum = checksum+!p:p = p + 1
		next j:a$ = a$ + "." + right$("0000"+to.string$(checksum and &7FFF,16),4)
		call transmit(a$)
		size = size - words
	wend
	; 	#E: End of data
	call transmit("#E:")
next i
end
'
'		Send a string to the serial port ending with CR/LF
'
proc transmit(a$)
local i
for i = 1 to len(a$):!&FFFC = asc(mid$(a$,i,1)):next i
!&FFFC=13:!&FFFC = 10
endproc


screen 2,2:cls
print "Hello world !!!!"
'
'	Location of character set.
'
defaultFont = sysvar(7)
'
'	Size (8 words x 96 chars)
'
fontMemSize = 96 * 8
'
'	Allocate memory for new font and copy old one in.
'
newFont = alloc(fontMemSize)
for i = 0 to fontMemSize-1
	newFont!i = defaultFont!i
next i
'
'	Set the new font instead (effectively this is POKE &4007,newFont)
'
!(sysvar(-1)+7) = newFont
print "Hello world !!!!"
'
'	Now Redefine char 33 to be a solid block (5x8). The +8 is because
'	the char set starts at 32 (8 words/character), though you can't redefine
' 	space.
'
for i = 0 to 7
	!(newFont+i+8) = &7C00
next i
print "Hello world !!!!"
'
'	Now define 'o' to be a box.
'
oChar = (asc("o")-32)*8+newFont
!oChar = &FC00:oChar!1 = &8400:oChar!2 = &8400:oChar!3 = &8400
oChar!4 = &8400:oChar!5 = &8400:oChar!6 = &8400:oChar!7 = &FC00
print "Hello world !!!!"

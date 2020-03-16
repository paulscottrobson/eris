# *****************************************************************************
# *****************************************************************************
#
#		Name:		ctrlkeys.py
#		Purpose:	Show keys generating specific codes
#		Created:	9th March 2020
#		Reviewed: 	TODO
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# *****************************************************************************
# *****************************************************************************

keys = []
for i in range(0,32):
	keys.append([])
for c in range(32,126):
	keys[c & 0x1F].append(chr(c))

for i in range(0,32):
	print("{0:2} ${0:02x} : {1}".format(i," ".join('"'+c+'"' for c in keys[i])))
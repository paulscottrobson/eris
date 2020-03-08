# *****************************************************************************
# *****************************************************************************
#
#		Name:		keyconv.py
#		Purpose:	Convert keyboard file to keyboard data
#		Created:	26th February 2020
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# *****************************************************************************
# *****************************************************************************

import re,os,sys
#
#		Decode a line
#
def decode(s):
	return [_decode(x) for x in s.strip().split() if x.strip() != ""]
def _decode(c):
	if c == "[]":
		return 0
	if c.startswith("[") and c.endswith("]"):
		return int(c[1:-1])
	assert len(c) == 1,"Bad entry "+c
	return ord(c.lower())
#
#		Keyboard map file to build with.
#
keyMapFile = "uk.keyboard"
#
#		Create data structures.
#
bits = [ ]  														# create keys for bits 0..4
for i in range(0,5):												# initially all empty.
	bits.append([ 0 ] * 16)								
shiftMap = {}														# map chars to shift chars (not A-Z)	
#
#		Read in source.
#
src = [x.upper().strip().replace("\t"," ") for x in open(keyMapFile).readlines()]
src = [x for x in src if x != "" and not x.startswith(";")]
p = 0
#
#		Now scan it.
#
while p < len(src):
	m = re.match("^\\[BIT\\s*(\\d)\\]$",src[p])
	assert m is not None,"Bad line "+p
	wBits = int(m.group(1))
	shiftLine = decode(src[p+1])
	unshiftLine = decode(src[p+2])
	for i in range(0,len(unshiftLine)):
		if unshiftLine[i] != 0:
			bits[wBits][i] = unshiftLine[i]
	for i in range(0,len(shiftLine)):
		if shiftLine[i] != 0:
			n = unshiftLine[i]
			if n == 0 or (n >= 97 and n <= 122):
				assert False,"Can't shift "+chr(shiftLine[i])
			assert n not in shiftMap
			shiftMap[n] = shiftLine[i]
	p = p + 3
#
#		Output result
#
h = open("keyboard.inc","w")
h.write(";\n;\tAutomatically generated.\n;\n")
h.write(".KeyboardMapping\n")
for b in range(0,5):
	h.write("\tbyte {0:50} ; Bit {1}\n".format(",".join([str(x) for x in bits[b]]),b))
h.write("\n")

keys = [x for x in shiftMap.keys()]	
keys.sort()
h.write(".ShiftTable\n")
for k in keys:
	h.write("\tbyte\t{1:3},{0:3} ; {2} -> {3}\n".format(k,shiftMap[k],chr(k),chr(shiftMap[k])))
h.write("\tbyte\t 0,0\n\n")
h.close()	

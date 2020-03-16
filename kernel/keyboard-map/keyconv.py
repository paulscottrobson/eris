# *****************************************************************************
# *****************************************************************************
#
#		Name:		keyconv.py
#		Purpose:	Convert keyboard file to keyboard data
#		Created:	8th March 2020
#		Reviewed: 	20th March 2020
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# *****************************************************************************
# *****************************************************************************

import re,os,sys
#
#		Decode a line of space seperated keyboard data
#
def decode(s):
	return [_decode(x) for x in s.strip().split() if x.strip() != ""]
#
#		Decode one item in the line
#
def _decode(c):
	if c == "[]":													# keyboard no ascii value
		return 0
	if c.startswith("[") and c.endswith("]"):						# [n] integer ascii value
		return int(c[1:-1])
	assert len(c) == 1,"Bad entry "+c 								# single character
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
src = [x for x in src if x != "" and not x.startswith(";")] 		# remove black and comments
#
#		Now scan it.
#
p = 0
while p < len(src):
	m = re.match("^\\[BIT\\s*(\\d)\\]$",src[p]) 					# new section
	assert m is not None,"Bad line "+p
	wBits = int(m.group(1))											# row bits
	shiftLine = decode(src[p+1]) 									# get and decode shift/unshift codes
	unshiftLine = decode(src[p+2])
	for i in range(0,len(unshiftLine)): 							# fill in unshifted line used bits
		if unshiftLine[i] != 0:										# table
			bits[wBits][i] = unshiftLine[i]
	for i in range(0,len(shiftLine)):								# repeat for shifted line
		if shiftLine[i] != 0:
			n = unshiftLine[i]
			if n == 0 or (n >= 97 and n <= 122):					# create the shift map
				assert False,"Can't shift "+chr(shiftLine[i])		# this is all the characters that
			assert n not in shiftMap								# don't classically shift
			shiftMap[n] = shiftLine[i] 								# Shift-1, Shift-. etc.
	p = p + 3
#
#		Output result
#
h = open("keyboard.inc","w")
h.write(";\n;\tAutomatically generated.\n;\n")
h.write(".KeyboardMapping\n")
for b in range(0,5):												# copy out our bits information
	h.write("\tbyte {0:50} ; Bit {1}\n".format(",".join([str(x) for x in bits[b]]),b))
h.write("\n")

keys = [x for x in shiftMap.keys()]									# write out the shift table
keys.sort()
h.write(".ShiftTable\n")
for k in keys:
	h.write("\tbyte\t{1:3},{0:3} ; {2} -> {3}\n".format(k,shiftMap[k],chr(k),chr(shiftMap[k])))
h.write("\tbyte\t 0,0\n\n")
h.close()	

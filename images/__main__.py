# *****************************************************************************
# *****************************************************************************
#
#		Name:		__main__.py
#		Purpose:	Simple CLI converter.
#		Created:	23rd September 2020
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# *****************************************************************************
# *****************************************************************************

from imwrapper import *
from imconvert import *
import sys

if len(sys.argv) != 3:
	print("python imec.zip <input graphic> <output graphic>")
	sys.exit(0)

image = SourceImageStripped(sys.argv[1])
eImage = ErisImage(image)
words = eImage.render()
print("Image : {0} to {1} ({2} words)".format(sys.argv[1],sys.argv[2],len(words)))
h = open(sys.argv[2],"wb")
h.write(bytes([0]))							# 0000 load address stops loading direct
h.write(bytes([0]))
for w in words:
	h.write(bytes([w & 0xFF]))
	h.write(bytes([w >> 8]))
h.close()


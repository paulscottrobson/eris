# *****************************************************************************
# *****************************************************************************
#
#       Name:       font.py
#       Purpose:    Font Conversion
#       Created:    8th March 2020
#       Author:     Paul Robson (paul@robsons.org.uk)
#
# *****************************************************************************
# *****************************************************************************
#
#       $7E     is cursor
#       $7F     solid block
#
import os
fName = "alt1"
fnt = [x for x in open(fName+".fnt","rb").read(-1)]
fnt = fnt[:512]+fnt[768:]
for i in range(0,8):
	fnt[(126-32)*8+i] = 170 if (i & 1) else 84
	fnt[(127-32)*8+i] = 0xFF
h = open("font.inc","w")
h.write(".FontData:\n")
h.write("\tword {0}\n\n".format(",".join([str(x << 8) for x in fnt])))
h.close()
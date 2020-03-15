# *****************************************************************************
# *****************************************************************************
#
#		Name:		msgconv.py
#		Purpose:	Convert messages file for internationalisation
#		Created:	15th March 2020
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# *****************************************************************************
# *****************************************************************************

import os,sys

msgFile = "messages.uk"

def process(x):
	if x.startswith('"') and x.endswith('"'):
		return "\tjsr\t#GenErrorHandler\n\tstring\t"+x
	else:
		return "."+x	

src = [x.strip() for x in open(msgFile).readlines() if not x.startswith(";")]
src = [process(x) for x in src if x != ""]
src = "\n".join(src)
h = open(".."+os.sep+"generated"+os.sep+"error_intl.inc","w")
h.write(";\n;\tAutomatically generated\n;\n")
h.write(src)
h.close()



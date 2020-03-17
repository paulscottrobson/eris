# *****************************************************************************
# *****************************************************************************
#
#		Name:		msgconv.py
#		Purpose:	Convert messages file for internationalisation
#		Created:	15th March 2020
#		Reviewed: 	16th March 2020
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# *****************************************************************************
# *****************************************************************************

import os,sys
#
#		This is the message file to use
#
msgFile = "messages.uk"


#
#		Convert non blank/comment line to label or string.
#
def process(x):
	if x.startswith('"') and x.endswith('"'):
		return "\tjsr\t#GenErrorHandler\n\tstring\t"+x
	else:
		return "."+x	

#
#		Read and pre-process
#
src = [x.strip() for x in open(msgFile).readlines() if not x.startswith(";")]
src = [process(x) for x in src if x != ""]
src = "\n".join(src)
#
#		Write out code
#
h = open(".."+os.sep+"generated"+os.sep+"error_intl.inc","w")
h.write(";\n;\tAutomatically generated\n;\n")
h.write(src)
h.close()



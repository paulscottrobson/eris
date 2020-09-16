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
language = sys.argv[1] if len(sys.argv) == 2 else "uk"
#
#		This is the message file to use
#
msgFile = language.strip().lower()+".messages"

h = open("error_intl.inc","w")
h.write(";\n;\tAutomatically generated\n;\n")
#
#		Read and process
#
for x in [x.strip() for x in open(msgFile).readlines() if not x.startswith(";")]:
	if x.startswith('"'):
		h.write('\tstring {0}\n'.format(x))
	else:
		h.write(".{0}\njsr\t#GenErrorHandler\n.{0}Text\n".format(x))

h.write(".BasicLanguage\n")
h.write('\tstring "-{0}[0D,0D,12]"\n'.format(language))		
h.close()



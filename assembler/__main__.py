# *****************************************************************************
# *****************************************************************************
#
#		Name:		__main__.py
#		Purpose:	Macro Assembler main program
#		Created:	8th March 2020
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# *****************************************************************************
# *****************************************************************************

import re,sys,os
from assembler import *

if __name__ == "__main__":
	srcFiles = [x.strip() for x in open("asm.project").readlines() if x.strip() != "" and not x.startswith(";")]
	asm = Assembler()
	print("EAS : Eris Assembler (08-03-2020)")
	for passNumber in [1,2]:
		h = None if passNumber == 1 else open("bin"+os.sep+"listing.eas","w")
		asm.startPass(passNumber,h)
		for f in srcFiles:
			src = open(f).readlines()
			try:				
				asm.assemble(f,src)
			except Exception as e:
				err = "\t{0} ({1}:{2})".format(str(e),AssemblerException.FILE,AssemblerException.LINE)
				print(err)
				sys.exit(1)
		if h is not None:
			h.close()
	asm.complete()
	sys.exit(0)

# *****************************************************************************
# *****************************************************************************
#
#		Name:		asmexception.py
#		Purpose:	Assembler Exception
#		Created:	8th March 2020
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# *****************************************************************************
# *****************************************************************************

import re

# *****************************************************************************
#
#								Exception Class
#
# *****************************************************************************

class AssemblerException(Exception):
	pass

AssemblerException.LINE = 0
AssemblerException.FILE = ""

if __name__ == "__main__":
	raise AssemblerException("Hello world !")
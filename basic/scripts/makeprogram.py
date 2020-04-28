# *****************************************************************************
# *****************************************************************************
#
#		Name:		makeprogram.py
#		Purpose:	Convert ASCII to tokenised BASIC
#		Created:	3rd March 2020
#		Reviewed: 	17th March 2020
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# *****************************************************************************
# *****************************************************************************

import os,re,sys
from convert import *

# *****************************************************************************
#
#							Basic Program class
#
# *****************************************************************************

class Program(object):
	def __init__(self):
		self.tokeniser = Tokeniser()
		self.code = []
		self.nextLine = 1000
		self.lastLine = -1
	#
	#		Import a file
	#
	def append(self,srcFile):
		for s in open(srcFile).readlines():
			s = s.strip()
			if not s.startswith(";") and s != "":							# ignore comments and blanks
				self.addLine(s)												# (not rem ' comments')
	#
	#		Append a line
	#
	def addLine(self,s):
		lineNumber = self.nextLine 											# default line #
		m = re.match("^(\\d+)\\s+(.*)$",s)									# do we have a line number.
		if m is not None:
			lineNumber = int(m.group(1))									# get it
			assert lineNumber > self.lastLine,"Lines out of sequence"		# check order.
			s = m.group(2).strip()											# line body.
		assert lineNumber >= 0 and lineNumber < 65536,"Bad line number" 		# must be 1-32767
		self.lastLine = lineNumber 											# update state
		self.nextLine = lineNumber+10
		#
		code = self.tokeniser.tokenise(s)									# convert line to code.
		code.append(0)														# add end of line marker.
		code.insert(0,lineNumber)											# add line number
		code.insert(0,len(code)+1)											# add offset.
		assert code[0] == len(code)										
		self.code += code
	#
	#		Output .prg file tokenised BASIC
	#
	def write(self,tgtFile,label = None,forceAddress = None):
		h = open(tgtFile,"wb")												# output as a .PRG
		h.write(bytes([0])) 												# note hard coded $4200 address here
		h.write(bytes([0x43]))
		for i in self.code:													# program words LSB first
			h.write(bytes([i & 0xFF]))
			h.write(bytes([i >> 8]))
		h.write(bytes([0])) 												# trailing NULL.
		h.write(bytes([0]))
		h.close()

if __name__ == "__main__":	
	program = Program()
	print("Converted {0} to {1}".format(sys.argv[1],sys.argv[2]))
	program.append(sys.argv[1])		
	program.write(sys.argv[2],None)

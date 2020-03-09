# *****************************************************************************
# *****************************************************************************
#
#		Name:		test.py
#		Purpose:	Test classes
#		Created:	5th March 2020
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# *****************************************************************************
# *****************************************************************************

import os,re,random
from program import *

# *****************************************************************************
#
#							Base Test Class
#
# *****************************************************************************

class TestProgram(Program):
	def __init__(self,debug=False,count = 100):
		Program.__init__(self)
		random.seed()
		self.debug = debug
		self.seed = random.randint(0,10000)
		print("Test #",self.seed,"of",self.__class__.__name__)
		self.count = count
		self.varChars = [x for x in "ABCDEFGHIJKLMNOPQRSTUVWXYZ.0123456789"]
		self.preTest()
		for i in range(0,self.count):
			self.index = i
			line = self.createTest()
			self.add(line)
		self.postTest()
		self.addLine("stop")
		self.write(".."+os.sep+"generated"+os.sep+"test_program.inc","basicProgram",None)
	#
	def add(self,line):
		if line != "":
			if self.debug:
				print(line)
			self.addLine(line)
	#
	def preTest(self):
		pass
	#
	def createTest(self):
		return ""
	#
	def postTest(self):
		pass
	#
	def select(self,ilist):
		ilist = [x for x in ilist]
		return ilist[random.randint(0,len(ilist)-1)]
	#
	def createVariableName(self,isString = None):
		isString = (random.randint(0,1) == 0) if isString is None else isString
		s = chr(random.randint(65,90))
		s = s+"".join(["."+self.select(self.varChars) for x in range(0,random.randint(0,3))])
		return s+"$" if isString else s
	#
	def varCharacter(self):
		return ""
	#
	def randomConstant(self):
		return random.randint(-32768,32767) if random.randint(0,10) > 0 else 0
	#
	def randomString(self):
		s = "".join([chr(random.randint(65,90)) for x in range(0,random.randint(1,32))])
		return '"'+s+'"'  if random.randint(0,10) > 0 else '""'

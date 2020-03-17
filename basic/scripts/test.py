# *****************************************************************************
# *****************************************************************************
#
#		Name:		test.py
#		Purpose:	Test classes
#		Created:	5th March 2020
#		Reviewed: 	17th March 2020
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# *****************************************************************************
# *****************************************************************************

import os,re,random
from program import *

# *****************************************************************************
#
#							Abstract Base Test Class
#
# *****************************************************************************

class TestProgram(Program):
	def __init__(self,debug=False,count = 100):
		Program.__init__(self)
		random.seed()														# Actual randoms seed
		self.debug = debug
		self.seed = random.randint(0,10000)									# the test seed
		random.seed(self.seed)												# seed it.
		print("Test #",self.seed,"of",self.__class__.__name__)
		self.count = count 													# # of tests
		self.varChars = [x for x in "ABCDEFGHIJKLMNOPQRSTUVWXYZ.0123456789"]# variable characters
		self.preTest()														# set up
		for i in range(0,self.count):										# create tests
			self.index = i
			line = self.createTest()
			self.add(line)
		self.postTest()														# check any results
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
	#		Randomly choose from a list
	#
	def select(self,ilist):
		ilist = [x for x in ilist]
		return ilist[random.randint(0,len(ilist)-1)]
	#
	#		Create variable names. Every other is a '.' so tokens aren't generated.
	#
	def createVariableName(self,currentList = None,isString = None):
		isString = (random.randint(0,1) == 0) if isString is None else isString
		s = chr(random.randint(65,90))
		s = s+"".join(["."+self.select(self.varChars) for x in range(0,random.randint(0,3))])
		vName = s+"$" if isString else s
		if currentList is not None and vName in currentList:
			return self.createVariableName(currentList,isString)
		return vName
	#
	#		Random constant value
	#
	def randomConstant(self):
		return random.randint(-32768,32767) if random.randint(0,10) > 0 else 0
	#
	#		Random string value
	#
	def randomString(self):
		s = "".join([chr(random.randint(65,90)) for x in range(0,random.randint(1,32))])
		return '"'+s+'"'  if random.randint(0,10) > 0 else '""'

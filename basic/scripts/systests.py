# *****************************************************************************
# *****************************************************************************
#
#		Name:		systest.py
#		Purpose:	Test classes
#		Created:	6th March 2020
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# *****************************************************************************
# *****************************************************************************

import os,sys,re,random,importlib

from program import *
from test import *
from complextest import *

# *****************************************************************************
#
#							Simple variable test class
#
# *****************************************************************************

class SimpleVariable(TestProgram):
	#
	def preTest(self):
		self.variables = {}		
		for i in range(0,self.count >> 1):
			v = self.createVariableName(self.variables)
			self.variables[v] = '""' if v.endswith("$") else 0
	#
	def createTest(self):
		v = self.select(self.variables.keys())
		if v.endswith("$"):
			new = self.randomString()
		else:
			new = self.randomConstant()
		self.variables[v] = new
		self.add("{0} = {1}".format(v,new))
		return ""
	#
	def postTest(self):
		for v in self.variables.keys():
			self.add("assert {0} = {1}".format(v,self.variables[v]))

		#self.add("print chr$(42);:goto 1000")

# *****************************************************************************
#
#							Comparison test class
#
# *****************************************************************************

class Comparison(TestProgram):
	def createTest(self):
		useString = self.select([True,False])
		if useString:
			v1 = self.randomString()
			v2 = self.randomString()
		else:
			v1 = str(self.randomConstant())
			v2 = str(self.randomConstant())
		v2 = v2 if random.randint(0,6) > 0 else v1
		operator = self.select(">,<,>=,<=,=,<>".split(","))
		pythonOp = operator
		if pythonOp == "=":
			pythonOp = "=="
		if pythonOp == "<>":
			pythonOp = "!="
		result = -1 if eval(v1+pythonOp+v2) else 0	
		return "assert {0} {1} {2} = {3}".format(v1,operator,v2,result)

if __name__ == "__main__":	
	if len(sys.argv) > 1 and sys.argv[1] in globals():
		newClass = globals()[sys.argv[1]]
		newClass(False,400)
	else:
		assert False,"Test not generated "+sys.argv[1]

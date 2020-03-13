# *****************************************************************************
# *****************************************************************************
#
#		Name:		complexvar.py
#		Purpose:	Test classes - complex variables
#		Created:	6th March 2020
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# *****************************************************************************
# *****************************************************************************

import os,sys,re,random,importlib

from test import *

# *****************************************************************************
#
#						Complex variable test class
#
# *****************************************************************************

class ComplexVariable(TestProgram):
	#
	def preTest(self):
		self.variables = {}		
		for i in range(0,(self.count >> 3)+1):
			v = self.createVariableName(self.variables)
			defValue = '""' if v.endswith("$") else 0
			if random.randint(0,2) != 0:
				self.variables[v] = { "name":v, "value": defValue,"type":"single" }
			else:
				size = [random.randint(2,4)]				
				if random.randint(0,1) == 0:
					size.append(random.randint(2,4))
				self.variables[v] = { "name":v, "value":self.makeValue(size,defValue),"type":"array","size":size }
				self.add("dim {0}({1})".format(v,",".join([str(x) for x in size])))				
	#
	def makeValue(self,size,default):				
		if len(size) == 0:
			return default
		clist = []
		for i in range(0,size[0]+1):
			clist.append(self.makeValue(size[1:],default))
		return clist
	#
	def createTest(self):
		v = self.variables[self.select(self.variables.keys())]
		if v["name"].endswith("$"):
			new = self.randomString()
		else:
			new = self.randomConstant()
		if v["type"] == "single":
			v["value"] = new
			self.add("{0} = {1}".format(v["name"],new))
		else:
			element = [random.randint(0,x) for x in v["size"]]
			if len(element) == 1:
				v["value"][element[0]] = new
			else:
				v["value"][element[0]][element[1]] = new
			self.add("{0}({1}) = {2}".format(v["name"],",".join([str(x) for x in element]),new))
		return ""
	#
	def postTest(self):
		for vk in self.variables.keys():
			v = self.variables[vk]
			if v["type"] == "single":
				self.add("assert {0} = {1}".format(v["name"],v["value"]))
			else:
				if len(v["size"]) == 1:
					for i in range(0,v["size"][0]+1):
						self.validate(v,str(i),v["value"][i])
				else:
					for i in range(0,v["size"][0]+1):
						for j in range(0,v["size"][1]+1):
							self.validate(v,str(i)+","+str(j),v["value"][i][j])
	def validate(self,rec,index,val):
		self.add("assert {0}({1}) = {2}".format(rec["name"],index,val))
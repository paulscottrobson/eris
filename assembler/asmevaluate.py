# *****************************************************************************
# *****************************************************************************
#
#		Name:		asmevaluate.py
#		Purpose:	Assembler Evaluation module
#		Created:	8th March 2020
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# *****************************************************************************
# *****************************************************************************

import re
from asmexception import *

# *****************************************************************************
#
#							Assembler Evaluate Class
#
# *****************************************************************************

class AssemblerEvaluator(object):
	def __init__(self):
		self.identifiers = { "LINK":13,"SP":12,"DEF":14,"PC":15 }
		for i in range(0,16):
			self.define("R"+str(i),i)
		self.defaultIdentifiers = {}
		for id in self.identifiers:
			self.defaultIdentifiers[id] = id
	#
	#		Define an identifier.
	#
	def define(self,identifier,value):
		identifier = identifier.upper().strip()
		if identifier in self.identifiers and self.identifiers[identifier] != value:
			raise AssemblerException(identifier+" redefined")
		self.identifiers[identifier] = value & 0xFFFF
	#
	#		Evaluate comma seperated operands
	#
	def evaluateOperands(self,operands,reportUndefined):
		operands = [self.evaluate(x,reportUndefined) for x in operands]
		return operands
	#
	#		Evaluate an expression, special fixes for 'x' and $2A7
	#
	def evaluate(self,expression,reportUndefined):
		if expression.find("[") >= 0:
			raise AssemblerException("Expression contains []")
		parts = re.split("(\\'.?\\')",expression)
		for i in range(0,len(parts)):
			if parts[i].startswith("'") and parts[i].endswith("'") and len(parts[i]) == 3:
				parts[i] = str(ord(parts[i][1]))
		expression = "".join(parts)
		#
		#	The reason for this is that undefined expressions will return 32. This is a valid
		#	byte or word, but if used as a constant will mandate the use of the longer format
		#	of the operation.
		#
		n = 32
		try:														# Try to evaluate
			n = eval(expression.replace("$","0x").upper().strip(),self.identifiers) & 0xFFFF
		except NameError as e:										# Possibly raise undefined errors
			errName = re.search("\'(.*?)\'",str(e)).group(1).lower()+" is undefined"
			if reportUndefined:
				raise AssemblerException(errName) from e
		except ZeroDivisionError as e:								# Divide by zero 
			raise AssemblerException("Division by zero") from e
		except SyntaxError as e:									# Syntactic error
			raise AssemblerException("Syntax error") from e
		return n
	#
	#		Dump labels to stream
	#
	def dumpLabels(self,handle):
		for k in self.identifiers.keys():
			if k not in self.defaultIdentifiers and not k.startswith("_"):
				handle.write("{0}=${1:04x}\n".format(k,self.identifiers[k]))

if __name__ == "__main__":
	w = AssemblerEvaluator()
	print(w.evaluate("2+3*4",True))
	print(w.evaluate("$2A",True))
	print(w.evaluate("2+3*PC",True))
	print(w.evaluate("1+'*'+1",True))
	print(w.evaluateOperands(["PC","42+3","-9*9"],True))

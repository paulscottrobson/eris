# *****************************************************************************
# *****************************************************************************
#
#		Name:		asmworker.py
#		Purpose:	Assembler Worker Module
#		Created:	20th February 2020
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# *****************************************************************************
# *****************************************************************************

import re
from asmexception import *
from asmevaluate import *

# *****************************************************************************
#
#							Assembler Worker Class
#
# *****************************************************************************

class AssemblerWorker(object):
	def __init__(self):
		self.evaluator = AssemblerEvaluator()
		self.mnemonics = [ 	"mov","ldm","stm","add","adc","sub","and","xor",
							"mult","ror","brl","skeq","skne","skse","sksn","skcm" ]
		self.macros = {}														# standard macros
		self.macros["jmp"] = "brl r15,*"							
		self.macros["jsr"] = "brl r13,*"
		self.macros["ret"] = "brl r15,r13,#0"
		self.macros["inc"] = "add *,r14,#1"
		self.macros["dec"] = "sub *,r14,#1"
		self.macros["clr"] = "xor *,*,#0"
		self.macros["skz"] = "skeq *,r14,#0"
		self.macros["sknz"] = "skne *,r14,#0"
		self.macros["skp"] = "skse *,r14,#0"
		self.macros["skm"] = "sksn *,r14,#0"
		self.macros["sknc"] = "skcm r15,r14,#0"
		self.macros["skc"] = "skcm r15,r14,#1"
		self.macros["skge"] = self.macros["skc"]
		self.macros["sklt"] = self.macros["sknc"]
		self.macros["break"] = "mov 0,0,#0"
	#
	#		Define an identifier.
	#
	def define(self,identifier,value):
		self.evaluator.define(identifier,value)
	#
	#		Evaluate an expression, must be valid (for things like origin and padding)
	#
	def evaluate(self,expression):
		return self.evaluator.evaluate(expression,True)
	#
	#		Assemble a single instruction or psuedo-operation into words.
	#
	def assemble(self,instruction,reportUndefined):
		self.orgInstruction = instruction
		instruction = instruction.strip().lower()
		#
		s = self.processMacro(instruction,reportUndefined)						# Macro types and
		if s is None: 															# Pseudo operations
			s = self.processPseudoOperations(instruction,reportUndefined)
		if s is not None:
			return s
		#
		m = re.match("^([a-z]+)\\s+(.*?),(.*?),\\#(.*?)\\s*$",instruction)		# standard format.
		if m is not None:
			return [ self.buildInstruction(m.groups(),reportUndefined) ]
		#
		m = re.match("^([a-z]+)\\s+(.*?),\\#(.*?)\\s*$",instruction)			# short or long format
		if m is not None:
			newInst = [x for x in m.groups()]									# create it.
			newInst.insert(2,"14")												# add default r14 param
			const = self.evaluator.evaluate(newInst[3],reportUndefined)			# value of constant
			if const >= 0 and const <= 15:										# short format
				return [ self.buildInstruction(newInst,reportUndefined)]		# use short constant
			newInst[2] = "15" 													# fix up instruction
			newInst[3] = "0" 													# for long
			if const < -32768 or const > 65535:									# signed or unsigned
				raise AssemblerException("Long constant out of range")
			return [ self.buildInstruction(newInst,reportUndefined),const & 0xFFFF ]

		raise AssemblerException("Syntax Error")
	#
	#		Build a valid instruction from mnemonic, registers and constant in a list
	#
	def buildInstruction(self,comp,reportUndefined):
		if comp[0] not in self.mnemonics:
			raise AssemblerException("Unknown mnemonic "+comp[0])
		operands = self.evaluator.evaluateOperands(comp[1:],reportUndefined)
		if operands[0] < 0 or operands[0] > 15 or operands[1] < 0 or operands[1] > 15:
			raise AssemblerException("Bad Register in "+self.orgInstruction)
		if operands[2] < 0 or operands[2] > 15:
			raise AssemblerException("Bad constant "+comp[2])
		return (self.mnemonics.index(comp[0]) << 12) + (operands[0] << 8) + (operands[1] << 4) + operands[2]
	#
	#		Process macro types
	#
	def processMacro(self,instruction,reportUndefined):
		parts = re.match("^([a-z]*)(.*)$",instruction)							# split bits
		if parts.group(1) in self.macros:										# expand it if known
			code = self.macros[parts.group(1)]
			code = code.replace("*",parts.group(2).strip().lower())
			return self.assemble(code,reportUndefined)
		return None
	#
	#		Process pseudo operations
	#
	def processPseudoOperations(self,instruction,reportUndefined):
		parts = re.match("^([a-z]*)\\s*(.*)\\s*$",instruction)					# split bits
		#
		if parts.group(1) == "byte" or parts.group(1) == "word":				# data
			data = self.evaluator.evaluateOperands(parts.group(2).strip().split(","),reportUndefined)
			if parts.group(1) == "byte":
				return self.convertBytesToWords(data,None)
			else:
				return [x & 0xFFFF for x in data]
		#
		if parts.group(1) == "text" or parts.group(1) == "string":				# text string
			m = re.match('^[a-z]+\\s*\\"(.*)\\"\\s*',self.orgInstruction)		# get the actual text
			if m is None:
				raise AssemblerException("Text syntax error")
			s = self.textProcess(m.group(1)) 									# convert controls
			data = [ord(c) for c in s]											# character codes
			data = self.convertBytesToWords(data,0)								# convert to word
			if parts.group(1) == "string":										# add length prefix
				data.insert(0,len(s))
			return data
		#
		if parts.group(1) == "push" or parts.group(1) == "pop":					# push/pop macros.
			isPush = parts.group(1) == "push"		
			rList = self.evaluator.evaluateOperands(parts.group(2).strip().split(","),True)
			rList.sort()
			code = []
			if isPush:															# make space
				code = code + self.assemble("sub sp,r14,#{0}".format(len(rList)),True)
			for i in range(0,len(rList)):										# read/write in frame
				cmd = "stm" if isPush else "ldm"
				code = code + self.assemble("{0} {1},sp,#{2}".format(cmd,rList[i],i),True)
			if not isPush:														# restore sp
				code = code + self.assemble("add sp,r14,#{0}".format(len(rList)),True)
			return code
		#	
		return None
	#
	#		Convert text to actual ASCII text
	#
	def textProcess(self,s):
		parts = re.split("(\\[[0-9\\,A-Fa-f]+\\])",s)
		for i in range(0,len(parts)):
			if parts[i].startswith("[") and parts[i].endswith("]"):
				parts[i] = "".join([chr(int(x,16)) for x in parts[i][1:-1].split(",")])
		return "".join(parts)
	#
	#		Convert a bytes array to a word array. Can be error if padding required
	#
	def convertBytesToWords(self,data,padding):
		data = [self._byteValidate(x) for x in data]
		if len(data) % 2 != 0:
			if padding is None:
				raise AssemblerException("Byte data is not even aligned")
			data.append(self._byteValidate(padding))
		words = []
		for i in range(0,len(data),2):
			words.append(data[i] + (data[i+1] << 8))
		return words
	#
	def _byteValidate(self,n):
		if n > 255:
			raise AssemblerException("Out of byte range")
		return n & 0xFF
	#
	#		Dump labels to stream
	#
	def dumpLabels(self,handle):
		self.evaluator.dumpLabels(handle)
		
if __name__ == "__main__":
	w = AssemblerWorker()
	print(" ".join(["{0:04x}".format(c) for c in w.assemble("add r2,r1,#14",True)]))
	print(" ".join(["{0:04x}".format(c) for c in w.assemble("sub r2,#11",True)]))
	print(" ".join(["{0:04x}".format(c) for c in w.assemble("xor r2,#32768",True)]))
	print(" ".join(["{0:04x}".format(c) for c in w.assemble("jsr #32768",True)]))
	print(" ".join(["{0:04x}".format(c) for c in w.assemble("word 432,-12,19,18",True)]))
	print(" ".join(["{0:04x}".format(c) for c in w.assemble("byte 32,'*',19,18",True)]))
	print(" ".join(["{0:04x}".format(c) for c in w.assemble('text "hello"',True)]))
	print(" ".join(["{0:04x}".format(c) for c in w.assemble('string "hello"',True)]))
	print(" ".join(["{0:04x}".format(c) for c in w.assemble('push r0,r1,link',True)]))
	print(" ".join(["{0:04x}".format(c) for c in w.assemble('pop r0,r4,r2',True)]))
	print(" ".join(["{0:04x}".format(c) for c in w.assemble('string "ab[2a,fd]cd"',True)]))

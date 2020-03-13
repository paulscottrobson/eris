# *****************************************************************************
# *****************************************************************************
#
#		Name:		gentokentest.py
#		Purpose:	Generate test routines for tokeniser
#		Created:	12th March 2020
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# *****************************************************************************
# *****************************************************************************

import os,re,random
from convert import *
from tokens import *

class Generator(object):
	def __init__(self):
		random.seed()
		self.seed = random.randint(0,10000)
		print("Test ",self.seed)
		random.seed(self.seed)
		self.tokeniser = Tokeniser()
		self.chars = "abcdefghijklmnopqrstuvwxyz0123456789."
	#
	def create(self):
		self.code = ""
		for i in range(0,16):
			n = random.randint(0,3)
			if n == 0:
				s = self.identifier()
			if n == 1:
				s = self.constant()
			if n == 2:
				s = self.qstring()
			if n == 3:
				s = self.token()
			self.code = self.code + s+" "
		print(self.code)
	#
	def getCode(self):
		code = [ord(x) for x in self.code]
		code.append(0)
		code = [x + (random.randint(0,255) << 8) for x in code]
		return code
	#
	def getTokens(self):
		t = self.tokeniser.tokenise(self.code)	
		t.append(0)
		return t
	#
	def constant(self):
		n = random.randint(0,65535)
		n1 = random.randint(0,3)
		if n1 == 0:
			return "&{0:x}".format(n)
		if n1 == 1:
			return "%{0:b}".format(n)
		return str(n)
	#
	def token(self):
		t = Tokens().getList()
		t = t[random.randint(0,len(t)-1)]
		t = t.lower() if random.randint(0,1) == 0 else t.upper()
		return self.token() if t == "&" or t == "%" or t.startswith("|") else t
	#
	def qstring(self):
		return '"'+"".join([chr(random.randint(48,125)) for x in range(0,random.randint(0,9))])+'"'
	#
	def identifier(self):
		s = chr(random.randint(65,90))
		return s + "".join([self.chars[random.randint(0,len(self.chars)-1)] for x in range(0,random.randint(0,4))])

#inp = "  42 32767 32769 &2A &802A %101010"
#inp = "* >= > = <> : |"
#inp = "2+3>=9"
#inp = '"ABC""" "ABCD" "A" "AB"'
#inp = "az09."		# 4411 45bb 6025
#inp = "az09.q"		# 4411 45bb 62CD
gen = Generator()
gen.create()

h = open(".."+os.sep+"generated"+os.sep+"token_test.inc","w")
h.write(".TestTokeniserRoutine\n")
h.write("\tmov r0,#TokenTest\n")
h.write("\tjsr #TokeniseString\n")
h.write("\tadd r0,#2\n")
h.write("\tmov r1,#TestResults\n")
h.write("\tjsr #CompareR0R1\n")
h.write("\tjmp #$FFFF\n")
h.write(".TokenTest\n")
h.write("\tword {0}\n".format(",".join(["${0:04x}".format(c) for c in gen.getCode()])))
h.write(".TestResults\n")
h.write("\tword {0}\n".format(",".join(["${0:04x}".format(c) for c in gen.getTokens()])))
h.close()


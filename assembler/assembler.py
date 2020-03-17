# *****************************************************************************
# *****************************************************************************
#
#		Name:		assembler.py
#		Purpose:	Assembler Module
#		Created:	8th March 2020
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# *****************************************************************************
# *****************************************************************************

import re,os,sys
from asmexception import *
from asmworker import *

# *****************************************************************************
#
#							   Assembler Class
#
# *****************************************************************************

class Assembler(object):
	def __init__(self):
		self.worker = AssemblerWorker()									# assembler worker
	#
	#		Start a new pass
	#
	def startPass(self,passNumber,listing = None):
		self.listing = listing 											# remember listing handle
		self.asmPass = passNumber 										# remember pass
		self.codePtr = 0 												# current origin
		self.lowWord = 0xFFFF 											# lowest address written to
		self.highWord = 0x0000 											# highest address written to
		self.binary = [ 0 ] * 0xFF00 									# binary storage
	#
	#		Assemble a collection of strings
	#
	def assemble(self,sourceName,code):
		AssemblerException.FILE = sourceName							# set file name
		for l in range(0,len(code)):									# do each line one at a time.
			AssemblerException.LINE = l+1
			self.assembleLine(code[l])
	#
	#		Assemble a single line
	#
	def assembleLine(self,l):
		l = l if l.find(";") < 0 else l[:l.find(";")]					# remove comments
		l = l.replace("\t"," ").strip()									# some preprocessing
		for c in [x.strip() for x in l.split(":") if x.strip() != ""]:	# look at parts
			self.assembleCommand(c)
	#
	#		Assemble a single command
	#
	def assembleCommand(self,c):
		self.orgCommand = c
		c = c.strip()
		if self.checkOperation(c):										# check a pseudo operation
			return
		if c.startswith("."):											# label check.
			m = re.match("^\\.([A-Za-z0-9\\_]+)\\s*(.*)$",c)			# extract label
			if m is None:
				raise AssemblerException("Bad Label Syntax")
			c = m.group(2).strip()
			self.worker.define(m.group(1),self.codePtr)
		#
		m = re.match("^([A-Za-z0-9\\_]+)\\s*\\=\\s*(.*)$",c)			# check for equate
		if m is not None:
			self.worker.define(m.group(1),self.worker.evaluate(m.group(2).strip()))
			c = ""
		#
		code = []														# nothing produced
		if c != "":														# normal instruction.
			code = self.worker.assemble(c,self.asmPass == 2)
		if self.listing is not None: 									# listing
			hexCode = " ".join(["{0:04x}".format(c) for c in code])
			self.listing.write("{0:04x} : {1:24}      {2}\n".format(self.codePtr,hexCode[:24],self.orgCommand.lower()[:50]))
		for c in code:													# write out.
			self.writeWord(self.codePtr,c)
			self.codePtr += 1
	#
	#		Pseudo Operation
	#
	def checkOperation(self,cmd):
		cmd = cmd.strip().lower()
		if cmd.startswith("org") or cmd.startswith("fill"):
			offset = self.worker.evaluate(cmd[(cmd+" ").find(" "):].strip())
			self.codePtr = offset if cmd.startswith("org") else (offset+self.codePtr)
			return True	
		return False
	#
	#		Write a word out.
	#
	def writeWord(self,address,word):
		if address < 0 or address >= 0xFF00:							# out of range
			raise AssemblerException("Code pointer out of range")
		self.binary[address] = word 
		self.lowWord = min(self.lowWord,address)
		self.highWord = max(self.highWord,address)
	#
	#		Complete file.
	#
	def complete(self):
		tgt = "bin"+os.sep

		h = open(tgt+"a.out","wb")										# Simple binary dump
		for w in self.binary[0:self.highWord+1]:
			h.write(bytes([w & 0xFF]))
			h.write(bytes([w >> 8]))
		h.close()

		h = open(tgt+"a.prg","wb")										# Load address binary dump
		h.write(bytes([self.lowWord & 0xFF,self.lowWord >> 8]))			# load address first
		for w in self.binary[self.lowWord:self.highWord+1]:				# then data
			h.write(bytes([w & 0xFF]))
			h.write(bytes([w >> 8]))
		h.close()

		h = open(tgt+"_binary.h","w")									# Simple hexadecimal dump
		h.write("{0},\n".format(",".join(["0x{0:04x}".format(c) for c in self.binary[self.lowWord:self.highWord+1]])))
		h.close()	

		h = open(tgt+"a.lbl","w")
		self.worker.dumpLabels(h)
		h.close()		

if __name__ == "__main__":
	code = """	
	;
	;		Test code.
	;
	highmem = $FF00
	.start
			mov		sp,#highmem
			jmp 	#routine
			jmp 	#forward
			clr 	def 			; line comment.
			stm 	r10,#$8000
	.bump	inc 	r2:dec 	r3
			clr 	r0
			org 	$18
	.forward 
			clr 	r0
			fill 	4
			clr 	r1

			routine = $ABCD
""".split("\n")
	asm = Assembler()
	for p in range(1,3):
		asm.startPass(p,sys.stdout)
		asm.assemble("Test",code)
		asm.complete()

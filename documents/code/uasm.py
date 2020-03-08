# *****************************************************************************
# *****************************************************************************
#
#		Name:		uasm.py
#		Purpose:	Ultra-Basic LC3 assembler
#		Created:	8th March 2020
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# *****************************************************************************
# *****************************************************************************

import os,sys,re

# *****************************************************************************
#
#					Very simple assembler, testing only.
#
# *****************************************************************************

class MicroAssembler(object):
	def __init__(self):
		self.opcodes = [ "mov","ldm","stm","add","adc","sub","and","xor","mult","ror","brl","skeq","skne","skse","sksn","skcm"]
		self.byteCode = []
		self.wordCode = []
	#
	#							Assemble a source
	#
	def assemble(self,s):
		for c in [x.replace("\t"," ").strip().lower() for x in s.split("\n") if x.strip() != ""]:
			self.assembleCommand(c)
		return self
	#
	def assembleCommand(self,c):
		m = re.match("^(.*?)\\s+r(\\d+)\\,r(\\d+)\\,\\#(\\-?\\d+)\\s*$",c)
		if m is not None:
			cmd = self.opcodes.index(m.group(1))
			ra = int(m.group(2))
			rb = int(m.group(3))
			const = int(m.group(4))
			assert cmd >= 0 and ra < 16 and rb < 15 and const >= 0 and const <= 15,"Bad code "+c
			self.writeWord(const+(cmd << 12)+(rb << 4)+(ra << 8))
			return
		m = re.match("^(.*?)\\s+r(\\d+)\\,\\#(\\-?\\d+)\\s*$",c)
		if m is not None:
			cmd = self.opcodes.index(m.group(1))
			ra = int(m.group(2))
			const = int(m.group(3))
			assert cmd >= 0 and ra < 16,"Bad code "+c
			self.writeWord((cmd << 12)+(ra << 8)+0x00F0)
			self.writeWord(const & 0xFFFF)
			return
		print("Error "+c)
		return self
	#
	def writeWord(self,w):
		print("{1:04x} : {0:04x}".format(w,len(self.wordCode)))
		self.wordCode.append(w & 0xFFFF)
		self.byteCode.append(w & 0xFF)
		self.byteCode.append((w >> 8) & 0xFF)
	#
	#						Write out binary a.out and include _binary.h
	#
	def write(self):
		h = open("a.out","wb")
		h.write(bytes(self.byteCode))
		h.close()
		h = open("_binary.h","w")
		h.write(",".join([str(x) for x in self.wordCode]))
		h.write("\n")
		h.close()

ma = MicroAssembler()
ma.assemble("""

	mov 	r11,r11,#0
	mov 	r14,r14,#0
	mov 	r10,r10,#0

	stm 	r11,#32768
	ror 	r12,r14,#8
	brl 	r13,#14
	skeq 	r10,r14,#0
	brl 	r15,#3
	add 	r11,r14,#1
	brl 	r13,#3

	add 	r10,r14,#1
	brl 	r15,r13,#0
""").write()		
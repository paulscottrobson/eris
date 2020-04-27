# ****************************************************************************
# ****************************************************************************
#
#		Name:		decode.py
#		Purpose:	Decode saved file
#		Created:	27th April 2020
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# ****************************************************************************
# ****************************************************************************

import os,re,sys

# ****************************************************************************
#
#								Single imported file
#
# ****************************************************************************

class ErisFile(object):
	def __init__(self,fileName):
		self.fileName = fileName.lower()
		self.loadAddress = None
		self.size = None
		self.data = []
	#
	def setLoadAddress(self,addr):
		assert self.loadAddress is None
		assert len(self.data) == 0
		self.loadAddress = addr
		self.data.append(addr & 0xFF)
		self.data.append(addr >> 8)
	#
	def setSize(self,size):
		assert self.size is None
		self.size = size
	#
	def addData(self,data,checkSumResult):
		checkSum = 0
		while data != "":
			n = int(data[:4],16)
			data = data[4:]
			checkSum = (checkSum+n) & 0x7FFF
			self.data.append(n & 0xFF)
			self.data.append(n >> 8)
		assert checkSum == checkSumResult,"Checksum failed in "+self.fileName
	#
	def complete(self):
		assert self.size*2+2 == len(self.data),"Data wrong in "+self.fileName
	#
	def validate(self,compareFileName):
		fData = [x for x in open(compareFileName,"rb").read(-1)]
		if len(fData) != len(self.data):
			print("\tFile "+compareFileName+" different lengths")
		else:
			reported = False
			for i in range(0,len(self.data)):
				if fData[i] != self.data[i] and not reported:
					print("\t\tFile {0} has different data at {1}".format(compareFileName,i))
					reported = True
	#
	def write(self,targetFile):
		h = open(targetFile,"wb")
		h.write(bytes(self.data))
		h.close()

# ****************************************************************************
#
#								Complete file system
#
# ****************************************************************************

class FileSystem(object):
	#
	def __init__(self,fileName):
		self.files = []
		for s in [x.strip().lower() for x in open(fileName).readlines()]:
			if s.startswith("#n:"):
				self.files.append(ErisFile(s[3:]))
			elif s.startswith("#l:"):
				self.files[-1].setLoadAddress(int(s[3:],16))
			elif s.startswith("#s:"):
				self.files[-1].setSize(int(s[3:],16))
			elif s.startswith("#d:"):
				self.files[-1].addData(s[3:-5],int(s[-4:],16))
			elif s.startswith("#e:"):
				self.files[-1].complete()
			else:
				assert False,"Bad Line "+s
	#
	def validate(self,validateDir):
		print("Validating against "+validateDir)
		for f in self.files:
			f.validate(validateDir+os.sep+f.fileName)
	#
	def write(self,targetDir):
		print("Writing files to "+targetDir)
		for f in self.files:
			f.write(targetDir+os.sep+f.fileName)

fs = FileSystem("storage.test")		
fs.validate(".."+os.sep+"storage")
fs.write("temp")






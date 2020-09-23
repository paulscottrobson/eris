# *****************************************************************************
# *****************************************************************************
#
#		Name:		imconvert.py
#		Purpose:	Wrapper conversion
#		Created:	23rd September 2020
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# *****************************************************************************
# *****************************************************************************

from imwrapper import *

# *****************************************************************************
#
#							General Pixel Image Band
#
# *****************************************************************************

class ErisPixelImageBand(object):
	def __init__(self,src,options,xStart):
		self.bandYOffset = 0
		self.bandHeight = src.getHeight()
		self.control = 0
		self.bitData = [ 0 ] * self.bandHeight
		for y in range(0,self.bandHeight):
			for x in range(0,16):
				pixel = src.get(x+xStart,y)
				if self.isShown(pixel):
					self.bitData[y] |= (0x8000 >> x)
			#print("{0} {1:04x}".format(y,self.bitData[y]))
	#
	def render(self):
		return [ self.control,self.getColourMask(),self.bandYOffset,self.bandHeight ] + self.bitData
	#
	def isUsed(self):
		return sum(self.bitData) > 0

# *****************************************************************************
#
#						Pixel Image Band for background
#
# *****************************************************************************

class ErisPixelImageBandBackground(ErisPixelImageBand):
	def isShown(self,colour):
		return colour >= 0
	def getColourMask(self):
		return 0x0700

# *****************************************************************************
#
#			Pixel Image Band for a single colour, setting all bits
#
# *****************************************************************************

class ErisPixelImageBandColour(ErisPixelImageBand):
	def __init__(self,src,options,xStart,monoColour):
		self.monoColour = monoColour
		ErisPixelImageBand.__init__(self,src,options,xStart)

	def isShown(self,colour):
		return colour == self.monoColour
	def getColourMask(self):
		return 0x700 | self.monoColour

# *****************************************************************************
#
#			Pixel Image Band for a single colour bit,setting that bit
#
# *****************************************************************************

class ErisPixelImageBandBit(ErisPixelImageBand):
	def __init__(self,src,options,xStart,bitMask):
		self.bitMask = bitMask
		ErisPixelImageBand.__init__(self,src,options,xStart)

	def isShown(self,colour):
		return colour >= 0 and (colour & self.bitMask) != 0
	def getColourMask(self):
		return (self.bitMask << 8) | self.bitMask

# *****************************************************************************
#
#					Represents one 16 pixel wide band. multicolour.
#
# *****************************************************************************

class ErisImageBand(object):
	def __init__(self,src,options,xStart):
		self.pixelBandCount = 0
		self.pixelBands = []
		self.analyseUsage(src,xStart)
		#
		#		If one colour only used, then just do it with that colour.
		#
		if self.coloursUsed == 1:
			pBand = ErisPixelImageBandColour(src,options,xStart,self.lastColourFound)
			assert pBand.isUsed()
			self.pixelBandCount += 1
			self.pixelBands.append(pBand)
		#
		#		Otherwise, first draw the background which is a whole or of all the pixels
		# 		effectively.
		#
		else:
			background = ErisPixelImageBandBackground(src,options,xStart)
			if background.isUsed():
				self.pixelBandCount += 1
				self.pixelBands.append(background)

			for b in range(0,3):
				bitMask = 1 << b
				pBand = ErisPixelImageBandBit(src,options,xStart,bitMask)
				if pBand.isUsed():
					self.pixelBandCount += 1
					self.pixelBands.append(pBand)
	#
	def render(self):
		data = [self.pixelBandCount]
		for b in self.pixelBands:
			data += b.render()
		return data 
	#
	#		Get if each colour is used, and how many are used in total.
	#
	def analyseUsage(self,src,xStart):
		self.colourUsage = [ 0 ] * 8
		for y in range(0,src.getHeight()):
			for x in range(xStart,xStart+16):
				pixel = src.get(x,y)
				if pixel >= 0:
					self.colourUsage[pixel] = 1
					self.lastColourFound = pixel
		self.coloursUsed = len([x for x in self.colourUsage if x > 0])

# *****************************************************************************
#
#							Eris Image Class
#
# *****************************************************************************

class ErisImage(object):
	def __init__(self,src,options = {}):
		self.width = src.getWidth()
		self.height = src.getHeight()
		self.bandCount = (self.width + 15) >> 4
		self.bands = []
		for b in range(0,self.bandCount):
			self.bands.append(ErisImageBand(src,options,b*16))
	#
	def render(self):
		data = [ (ord("E")<<8)+ord("I"),self.width,self.height,self.bandCount]
		for b in self.bands:
			data += b.render()
		return data


if __name__ == "__main__":	
	image = SourceImageStripped("test/j.png")
	print("Width :  ",image.getWidth())
	print("Height : ",image.getHeight())
#	for y in range(0,image.getHeight()):
#		l = [image.get(x,y) for x in range(0,image.getWidth())]
#		print("".join(["{0:3} ".format(c) for c in l]))
	newImg = ErisImage(image)
	render = newImg.render()
	print(" ".join(["{0:x}".format(n) for n in render]))
	print(len(render))

# successfully decode small
# successfully decode 10h/jpg and 10hx.png
# strip top and bottom (the bandYOffset/bandHeight)
# check all
# compress.


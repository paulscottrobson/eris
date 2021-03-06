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
from imdecode import *

# *****************************************************************************
#
#							General Pixel Image Band
#
# *****************************************************************************

class ErisPixelImageBand(object):
	def __init__(self,src,options,xStart):
		self.bitData = [ 0 ] * src.getHeight()
		for y in range(0,src.getHeight()):
			for x in range(0,16):
				pixel = src.get(x+xStart,y)
				if self.isShown(pixel):
					self.bitData[y] |= (0x8000 >> x)
			#print("{0} {1:04x}".format(y,self.bitData[y]))
		#self.noCompress()
		self.compress()
	#
	#		Convert to word stream
	#
	def render(self):
		return [(ord("P")<<8)+ord("0"),self.getColourMask()] + self.bitData
	#
	#		Check any write bits are set - without it there is no point drawing it.
	#
	def isUsed(self):
		return sum(self.bitData) > 0
	#
	#		Output without compression - prefix with $02xx and end with $0000
	#
	def noCompress(self):
		self.bitData.insert(0,0x0200+len(self.bitData))
		self.bitData.append(0)
	#
	#		Output with compression
	#
	def compress(self):
		sd = [x for x in self.bitData]					# copy bit data as is.
		sd.append(0x123456)								# terminates any repeat at the end.
		sd.append(0x123457) 							# stop overflow.
		sd.append(0x123458)
		self.bitData = []								# clear the input.
		while sd[0] < 0x10000:							# while not reached the end.
			p = 0 										# scan forward for three in a row.
			while sd[p] < 0x10000 and not ((sd[p] == sd[p+1]) and (sd[p+1] == sd[p+2])):				
				p+=1
			self.bitData.append(0x200+p)				# output data to here.
			self.bitData += sd[:p]						# as non-repeat so far.
			sd = sd[p:]
			if sd[0] < 0x10000:							# repeat stopped the loop ?
				p = 0 									# count the repeats
				while sd[0] == sd[p]:
					p += 1
				self.bitData.append(0x100+p) 			# repeat p times
				self.bitData.append(sd[0])				# whatever the data was.
				sd = sd[p:]								# chuck the repeats.
		self.bitData.append(0)							# end marker

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
			#
			#	Do all three bits which may or may not need redrawing.
			#
			for b in range(0,3):
				bitMask = 1 << b
				pBand = ErisPixelImageBandBit(src,options,xStart,bitMask)
				if pBand.isUsed():
					self.pixelBandCount += 1
					self.pixelBands.append(pBand)
	#
	#		Render image band
	#
	def render(self):
		data = [(ord("B")<<8)+ord("0"),self.pixelBandCount]
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
		data = [ (ord("I")<<8)+ord("0"),self.width,self.height,self.bandCount]
		for b in self.bands:
			data += b.render()
		return data


if __name__ == "__main__":	
	image = SourceImageStripped("test/tux2.png")
	print("Width :  ",image.getWidth())
	print("Height : ",image.getHeight())
	newImg = ErisImage(image)
	render = newImg.render()
	#print(" ".join(["{0:x}".format(n) for n in render]))
	print("Words:",len(render))
	#
	decImg = ImageDecoder(render)
	decImg.save()
	


# *****************************************************************************
# *****************************************************************************
#
#		Name:		imdecode.py
#		Purpose:	Image Decoder Class
#		Created:	23rd September 2020
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# *****************************************************************************
# *****************************************************************************

from PIL import Image

# *****************************************************************************
#
#								Eris Image Decoder
#
# *****************************************************************************

class ImageDecoder(object):
	def __init__(self,imgData):
		self.width = imgData[1]
		self.height = imgData[2]
		self.img = imgData
		assert self.img[0] == (ord('I')<<8)+ord('0')
		self.graphic = []
		for y in range(0,self.width):
			self.graphic.append([-1]*self.height)
		p = 4
		for b in range(0,imgData[3]):
			p = self.decodeBand(p,b*16)
		#print(self.graphic)
	#
	def decodeBand(self,p,x):
		assert self.img[p] == (ord('B')<<8)+ord('0')
		pbCount = self.img[p+1]
		p = p + 2
		for i in range(0,pbCount):
			p = self.decodePixelBand(p,x)
		return p
	#
	def decodePixelBand(self,p,x):
		assert self.img[p] == (ord('P')<<8)+ord('0')
		cMask = self.img[p+1]
		p = p + 2 
		y = 0
		while self.img[p] != 0:
			cmd = self.img[p]
			p = p + 1
			if (cmd >> 8) == 0x02:
				for i in range(0,cmd & 0xFF):
					self.plotLine(x,y,self.img[p],cMask)
					p = p + 1
					y = y + 1
			elif (cmd >> 8) == 0x01:
				for i in range(0,cmd & 0xFF):
					self.plotLine(x,y,self.img[p],cMask)
					y = y + 1			
				p = p + 1
			else:
				assert False,"Bad command"
		return p+1
	#
	def plotLine(self,x,y,bitData,colourMask):
		while bitData != 0:
			if (bitData & 0x8000) != 0:
					oldData = self.graphic[x][y]
					oldData = 0 if oldData < 0 else oldData
					oldMask = (colourMask >> 8)
					oldData = oldData & (~oldMask)
					oldData = oldData | (colourMask & 0xFF)
					self.graphic[x][y] = oldData
			x = x + 1
			bitData = (bitData << 1) & 0xFFFF
	#
	def save(self,tgtFile = "recreate.png"):
		img = Image.new('RGBA',(self.width,self.height),(255,128,0,255))
		for x in range(0,self.width):
			for y in range(0,self.height):
				img.putpixel((x,y),(0,0,0,0))
				c = self.graphic[x][y]
				if c >= 0:
					img.putpixel((x,y),(0 if (c & 1) == 0 else 255,0 if (c & 2) == 0 else 255,0 if (c & 4) == 0 else 255))
		img.save(tgtFile,"PNG")

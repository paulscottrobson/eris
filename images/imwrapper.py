# *****************************************************************************
# *****************************************************************************
#
#		Name:		imwrapper.py
#		Purpose:	Image wrapper, PIL
#		Created:	23rd September 2020
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# *****************************************************************************
# *****************************************************************************

from PIL import Image

# *****************************************************************************
#
#						Basic source image class
#
# *****************************************************************************

class SourceImage(object):
	def __init__(self,source,level = 0):
		self.image = Image.open(source)
		self.level = level if level > 0 else 160
	#
	def getWidth(self):
		return self.image.size[0]
	def getHeight(self):
		return self.image.size[1]
	#
	def get(self,x,y):
		if x < 0 or y < 0 or x >= self.getWidth() or y >= self.getHeight():
			return -1	
		return self._get(x,y)
	#
	def _get(self,x,y):
		rgb = self.image.getpixel((x,y))					# get rgb/rgba
		if len(rgb) == 4:									# does it have alpha
			if rgb[3] < self.level:							# alpha low return -1 (transparent)
				return -1
		return 	(1 if rgb[0] >= self.level else 0) + \
				(2 if rgb[1] >= self.level else 0) + \
				(4 if rgb[2] >= self.level else 0)

# *****************************************************************************
#
#						Source image stripped of border
#
# *****************************************************************************

class SourceImageStripped(SourceImage):
	def __init__(self,source,level = 0):
		SourceImage.__init__(self,source,level)
		self.xStart = 0
		self.yStart = 0
		self.width = SourceImage.getWidth(self)
		self.height = SourceImage.getHeight(self)
		while self.width > 0 and self.isBlankColumn(self.xStart):
			self.xStart += 1
			self.width -= 1
		while self.width > 0 and self.isBlankColumn(self.xStart+self.width-1):
			self.width -= 1
		while self.height > 0 and self.isBlankRow(self.yStart):
			self.yStart += 1
			self.height -= 1
		while self.height > 0 and self.isBlankRow(self.yStart+self.height-1):
			self.height -= 1
	#
	def isBlankColumn(self,x):
		for y in range(0,SourceImage.getHeight(self)):
			if SourceImage._get(self,x,y) >= 0:
				return False
		return True
	def isBlankRow(self,y):
		for x in range(0,SourceImage.getWidth(self)):
			if SourceImage._get(self,x,y) >= 0:
				return False
		return True
	#
	def _get(self,x,y):
		return SourceImage._get(self,self.xStart+x,self.yStart+y)
	#
	def getWidth(self):
		return self.width
	def getHeight(self):
		return self.height


if __name__ == "__main__":	
	image = SourceImageStripped("test/j.png")
	print("Width :  ",image.getWidth())
	print("Height : ",image.getHeight())
	for y in range(0,image.getHeight()):
		l = [image.get(x,y) for x in range(0,image.getWidth())]
		#print("".join(["{0:3} ".format(c) for c in l]))

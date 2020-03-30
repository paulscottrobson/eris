# *****************************************************************************
# *****************************************************************************
#
#		Name:		ellipse.py
#		Purpose:	Ellipse Algorithm test. Manipulated circle :)
#		Created:	8th March 2020
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# *****************************************************************************
# *****************************************************************************

import random

# *****************************************************************************
#
#								A simple display class
#
# *****************************************************************************

class Display(object):
	def __init__(self,width=48,height=32):
		self.width = width
		self.height = height
		self.display = []
		for i in range(0,self.height):
			self.display.append(["."] * self.width)
	#
	def plot(self,x,y,c):
		self.display[y][x] = c[0]
	#
	def show(self):
		s = "\n".join(["".join(self.display[x]) for x in range(0,self.height)])
		print(s)
	#
	def draw(self,radius,c = "*"):
		f = 1 - radius
		ddfX = 0
		ddfY = -2 * radius
		x = 0
		y = radius
		self.qplot(x,y)
		while x < y:
			if f >= 0:
				y = y - 1
				ddfY += 2
				f += ddfY
			x += 1
			ddfX += 2
			f += ddfX + 1
			self.qplot(x,y)

	def qplot(self,x,y):
		self.plot(int(self.width/2)+x,int(self.height/2)+y,"*")
		self.plot(int(self.width/2)+y,int(self.height/2)+x,"*")
		self.plot(int(self.width/2)+x,int(self.height/2)-y,"*")
		self.plot(int(self.width/2)+y,int(self.height/2)-x,"*")
		self.plot(int(self.width/2)-x,int(self.height/2)+y,"*")
		self.plot(int(self.width/2)-y,int(self.height/2)+x,"*")
		self.plot(int(self.width/2)-x,int(self.height/2)-y,"*")
		self.plot(int(self.width/2)-y,int(self.height/2)-x,"*")

d = Display()
d.draw(14)
d.show()			
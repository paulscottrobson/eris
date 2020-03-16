# *****************************************************************************
# *****************************************************************************
#
#		Name:		bresenham.py
#		Purpose:	Bresenham type Line Algorithm test
#		Created:	8th March 2020
#		Reviewed: 	TODO
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
	def draw(self,x0,y0,x1,y1,c = "*"):
		assert x0 <= x1 and y0 <= y1 			# only down and left. Sort on Y ; if x0 > x1 then subtract 1.
		dx = x1-x0
		dy = y0-y1
		err = dx + dy
		while x0 != x1 or y0 != y1:
			self.plot(x0,y0,c)
			e2 = 2 * err
			if e2 >= dy:
				err += dy
				x0 += 1
			if dx >= e2:
				err += dx
				y0 += 1
		self.plot(x0,y0,c)	

d = Display()
d.draw(2,2,46,12,"A")
d.draw(2,2,16,30,"B")
d.draw(2,2,46,2,"C")
d.draw(2,2,2,30,"D")
d.plot(2,2,"*")
d.show()			
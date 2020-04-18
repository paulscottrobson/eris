from PIL import Image, ImageDraw
import math

def convertPolar(n,r,d):
	x1 = n * 16 + 8
	y1 = 8
	r = math.radians(r)
	return (round(x1+math.cos(r)*d),round(y1+math.sin(r)*d))

def drawLine(d,ix,rotation,r1,d1,r2,d2):
	x1 = convertPolar(ix,rotation+r1,d1)
	x2 = convertPolar(ix,rotation+r2,d2)
	d.line([x1,x2],fill=(255,255,255))

asteroids = Image.new('RGB',(224,16),(0,0,0))
d = ImageDraw.Draw(asteroids)
for rot in range(0,7):
	degrees = rot * 90 / 6-90
	drawLine(d,rot,degrees,0,8,135,8)
	drawLine(d,rot,degrees,0,8,225,8)
	drawLine(d,rot,degrees,100,3,360-100,3)
asteroids.show()
asteroids.save("astgfx.png")
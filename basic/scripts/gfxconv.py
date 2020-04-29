# *****************************************************************************
# *****************************************************************************
#
#		Name:		gfxconv.py
#		Purpose:	Convert graphics file
#		Created:	29th March 2020
#		Reviewed: 	TODO
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# *****************************************************************************
# *****************************************************************************

import re,os,sys
from PIL import Image

fileName = sys.argv[1]
imageCount = 0
print("Converting "+fileName)	
image = Image.open(fileName).convert('RGB')
imagePalette = image.getpalette()
#
data = [ 0 ]
for inm in range(0,32):
	imageData = []
	xOrigin = (inm % 8) * 17 + 1
	yOrigin = int(inm / 8) * 17 + 1
	for y in range(0,16):
		rowData = 0
		for x in range(0,16):
			pixel = image.getpixel((xOrigin+x,yOrigin+y))
			if sum(pixel) > 400:
				rowData |= (0x8000 >> x)
		imageData.append(rowData)
	if sum(imageData) > 0:
		data += imageData
		imageCount += 1
print("\tFound {0} images".format(imageCount))
h = open(fileName[:-4]+".spr","wb")
for d in data:
	h.write(bytes([d & 0xFF]))
	h.write(bytes([d >> 8]))
h.close()
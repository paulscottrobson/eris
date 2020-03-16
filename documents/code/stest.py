# *****************************************************************************
# *****************************************************************************
#
#		Name:		stest.py
#		Purpose:	16 bit signed comparison check.
#		Created:	8th March 2020
#		Reviewed: 	TODO
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# *****************************************************************************
# *****************************************************************************

import random

#
#		Couldn't see why this trick wouldn't work but went for exhaustive test :)
#
def stest(n1,n2):
	n1 = (n1 + 0x8000) & 0xFFFF
	n2 = (n2 + 0x8000) & 0xFFFF
	if n1 == n2:
		return 0
	return -1 if n1 < n2 else 1

def test(n1,n2):
	if n1 == n2:
		return 0
	return -1 if n1 < n2 else 1


random.seed()
for i in range(0,5000*1000):
	a = random.randint(-32768,32767)
	b = random.randint(-32768,32767)
	if stest(a,b) != test(a,b):
		print(a,b)

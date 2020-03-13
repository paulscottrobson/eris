# *****************************************************************************
# *****************************************************************************
#
#		Name:		divide.py
#		Purpose:	16 bit unsigned Integer Division prototype in Python
#		Created:	8th March 2020
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# *****************************************************************************
# *****************************************************************************

import random
#
#		Calculate q / m - 16 bit integer ; returns [result,modulus]
#
def divide(q,m):
	a = 0
	for y in range(0,16):
		#
		#		Shift AQ Left
		#
		a = (a << 1) | ((q & 0x8000) >> 15)
		q = (q << 1) & 0xFFFF
		#
		#		Optional subtraction and bit set
		#
		if a >= m:
			a = a - m
			q = q | 1
	return [q,a]


random.seed(42)
for n in range(0,100*1000*1000):
	if (n % 100000) == 0:
		print("Done",n)
	n1 = random.randint(0,65535)
	n2 = random.randint(1,65535)
	r = divide(n1,n2)
	if r[0] != int(n1/n2):
		print("Error ",r,n1,n2)
	if r[1] != n1 % n2:
		print("Error ",r,n1,n2)

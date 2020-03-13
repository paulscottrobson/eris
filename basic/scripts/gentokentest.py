# *****************************************************************************
# *****************************************************************************
#
#		Name:		gentokentest.py
#		Purpose:	Generate test routines for tokeniser
#		Created:	12th March 2020
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# *****************************************************************************
# *****************************************************************************

import os,re,random

inp = "  42 32767 32769 &2A &802A %101010"
inp = "* >= > = <> : |"
inp = "2+3>=9"
inp = '"ABC""" "ABCD" "A" "AB"'
inp = "right$("
random.seed(42)
inp = [ord(x) for x in inp]
inp.append(0)
inp = [x + (random.randint(0,255) << 8) for x in inp]
h = open(".."+os.sep+"generated"+os.sep+"token_test.inc","w")
h.write(".TestTokeniserRoutine\n")
h.write("\tmov r0,#TokenTest\n")
h.write("\tjsr #TokeniseString\n")
h.write("\tbreak\n")
h.write("\tjmp #TestTokeniserRoutine\n")
h.write(".TokenTest\n")
h.write("\tword {0}\n".format(",".join(["${0:04x}".format(c) for c in inp])))
h.close()


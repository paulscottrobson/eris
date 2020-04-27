# ****************************************************************************
# ****************************************************************************
#
#		Name:		extractv.py
#		Purpose:	Extract OS Vector addresses as a constant file.
#		Created:	27th April 2020
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# ****************************************************************************
# ****************************************************************************

import os
#
#		Open kernel label file and extract vectors.
#
src = open("..{0}..{0}kernel{0}bin{0}a.lbl".format(os.sep),"r").readlines()
src = [x.strip() for x in src if x.startswith("OS")]
src = [[x[:x.find("=")],int(x[-4:],16)] for x in src]
src = [x for x in src if x[1] < 0x100]
#
#print("\n".join(["{0:32} ${1:04x}".format(x[0],x[1]) for x in src]))
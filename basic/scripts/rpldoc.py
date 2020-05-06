# *****************************************************************************
# *****************************************************************************
#
#		Name:		rpldoc.py
#		Purpose:	Generate RPL Documentation
#		Created:	6th May 2020
#		Reviewed: 	TODO
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# *****************************************************************************
# *****************************************************************************

import re,os,sys
keywords = {}
current = ""
for root,dir,files in os.walk(".."+os.sep+"src"+os.sep+"rpl"):
	for f in [x for x in files if x.endswith(".rpl")]:
		for s in open(root+os.sep+f).readlines():
			if s.find(";;") >= 0:
				if s.startswith(";;"):
					current = current + " " + (s[2:].replace("\t"," ").strip())
				else:
					m = re.match("^\\.(.*?)\\s*\\;\\;\\s*\\[(.*?)\\]",s)
					assert m is not None,"Bad line "+s
					s = m.group(2).lower().strip()
					if current != "":
						keywords[s] = current
					current = ""

kwList = [x for x in keywords.keys()]
kwList.sort()
print("<html><head></head><body>")
for k in kwList:
	m = re.match("^(\\(.*?\\))(.*)$",keywords[k].strip())
	print("<hr><h1>{0}</h1>\n<p><b>{1}</b></p><p>{2}</p>".format(k,m.group(1),m.group(2)))
print("</body>")
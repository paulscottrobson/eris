# *****************************************************************************
# *****************************************************************************
#
#		Name:		tables.py
#		Purpose:	Generate external tables
#		Created:	2nd March 2020
#		Reviewed: 	17th March 2020
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# *****************************************************************************
# *****************************************************************************

import re,os,sys

from tokens import *
tokens = Tokens()

#
#		Generate table of constants
#
h = open(".."+os.sep+"generated"+os.sep+"tok_const.inc","w")
h.write(";\n;\tAutomatically generated\n;\n")
for t in tokens.getList():
	id = tokens.getInfo(t)["token"]
	tn = "TOK_"+t 															# Convert punctuation to text
	tn = tn.replace("<","LESS").replace(">","GREATER").replace("=","EQUAL").replace(":","COLON")
	tn = tn.replace("+","PLUS").replace("-","MINUS").replace("*","STAR").replace("/","SLASH")
	tn = tn.replace("!","PLING").replace(",","COMMA").replace(";","SEMICOLON").replace("%","PERCENT")
	tn = tn.replace("(","LPAREN").replace(")","RPAREN").replace("&","AMPERSAND").replace("$","DOLLAR")
	tn = tn.replace("'","QUOTE").replace(".","DOT").replace("|","VBAR").replace("?","QMARK")
	#tn = tn.replace("","").replace("","").replace("","").replace("","")
	assert re.match("^[A-Z0-9\\_]+$",tn) is not None,"Bad token "+tn
	h.write("{0} = ${1:04x}\n".format(tn,id))
h.close()
#
#		Generate the tokenisation encode/decode table.
#
h = open(".."+os.sep+"generated"+os.sep+"tok_text.inc","w")
h.write(";\n;\tAutomatically generated\n;\n")
h.write(".TokeniserWords\n")
for t in tokens.getList():
	id = tokens.getInfo(t)["token"]
	code = tokens.encode(t)
	#
	#		This word contains the type in bits 8..11 and the encoded token length in 0..7
	#
	defWord = (((id >> 9) & 0x0F) << 8) | len(code)
	code.insert(0,defWord)
	code = ",".join(["${0:04x}".format(c) for c in code])
	h.write("\tword\t{0:32} ; ${1:04x} {2}\n".format(code,id,t))
	#print("{0:10} {1:04x} {2}".format(t,id,code))
h.write("\tword\t$0000\n")	
h.close()
#
#		Scan the source files for markers, and create a vector table.
#	
handlers = {}
for root,dirs,files in os.walk(".."+os.sep+"src"):
	for f in [x for x in files if x.endswith(".asm")]:
		for s in open(root+os.sep+f).readlines():
			if s.find(";;") >= 0:
				m = re.match("^\\.(.*?)\\s+\\;\\;\\s+\\[(.*?)\\]\\s*$",s)
				assert m is not None,f+" : "+s
				keyword = m.group(2).strip().upper()
				assert keyword not in handlers,"Duplicate handler "+keyword
				assert tokens.getInfo(keyword) is not None,"Unknown keyword "+keyword
				handlers[keyword] = m.group(1).strip()

h = open(".."+os.sep+"generated"+os.sep+"tok_vectors.inc","w")
h.write(";\n;\tAutomatically generated\n;\n")
h.write(".TokenVectors\n")
undefined = []
for t in tokens.getList():
	if t in handlers:
		handler = handlers[t]
	else:
	 	handler = "SyntaxError"
	 	undefined.append(t)
	h.write("\tword\t{0:24} ; ${1:04x} {2}\n".format(handler,tokens.getInfo(t)["token"],t))	
h.close()
#
#		If any aren't implemented output a warning.
#
#if len(undefined) > 0:
#	undefined.sort()
#	print("TODO : "+" ".join(undefined).lower())
				

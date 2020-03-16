# *****************************************************************************
# *****************************************************************************
#
#		Name:		tokens.py
#		Purpose:	Token class
#		Created:	2nd March 2020
#		Reviewed: 	TODO
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# *****************************************************************************
# *****************************************************************************

import re

# *****************************************************************************
#
#								Tokens Class
#
# *****************************************************************************

class Tokens(object):
	#
	#		If first time, then build the list of tokens (in ID order) and the 
	#		information hash (name -> full token ID) from the raw data
	#
	def __init__(self):
		if Tokens.TOKENS is None:
			Tokens.TOKENS = { }
			Tokens.TOKENLIST = [ ]
			tokenID = 0
			currentType = None
			#
			src = [x for x in self.getRaw().replace("\t"," ").split("\n") if not x.startswith("//")]
			for w in " ".join(src).upper().split():
				if re.match("^\\[\\d\\]$",w) is not None:
					currentType = int(w[1])
				elif w == "[UNARY]":
					currentType = 8
				elif w == "[SYNTAX]":
					currentType = 9
				elif w == "[CMD-]":
					currentType = 13
				elif w == "[CMD]":
					currentType = 14
				elif w == "[CMD+]":
					currentType = 15
				else:
					assert not(w.startswith("[") and w.endswith("]"))
					assert tokenID < 512
					newToken = { "name":w,"token":0x2000+currentType*512+tokenID }
					tokenID += 1
					Tokens.TOKENS[w] = newToken
					Tokens.TOKENLIST.append(w)
	#
	#		Get list of tokens in id order (e.g. the lower 9 bits)
	#
	def getList(self):
		return Tokens.TOKENLIST
	#
	#		Get complete dictionary
	#
	def getDictionary(self):
		return Tokens.TOKENS
	#
	#		Get information for a particular token, or None if not recognised.
	#
	def getInfo(self,token):
		token = token.strip().upper()
		return Tokens.TOKENS[token] if token in Tokens.TOKENS else None
	#
	#		This is a common routine for encoding either a punctuation set
	#		or an identifier.
	#
	def encode(self,token):
		token = token.strip().upper()
		if token.startswith("|"):
			return [0xFFFF]
		isAlpha = token[0] >= 'A' and token[0] <= 'Z'
		return self.encodeIdentifier(token) if isAlpha else self.encodePunctuation(token)
	#
	#		Encode an identifier which may end with $ $( or ( which types it.
	#
	def encodeIdentifier(self,s):
		m = re.match("^([A-Z][A-Z0-9\\.]*)(\\$?)(\\(?)$",s)
		assert m is not None,"Bad "+s
		s = m.group(1) if len(m.group(1)) % 2 == 0 else m.group(1)+" "
		code = []
		for i in range(0,len(s),2):
			encWord = 0x4000 + self.encodeChar(s[i])+self.encodeChar(s[i+1])*40
			encWord = encWord if m.group(2) == "" else encWord+0x1000
			encWord = encWord if m.group(3) == "" else encWord+0x0800
			code.append(encWord)
		code[-1] += 0x2000
		return code
	#
	#		Encode a 1 or 2 character punctuation token
	#
	def encodePunctuation(self,s):
		assert len(s) <= 2 and s != "","Bad "+s
		assert re.match("^[\\!\\+\\-\\*\\>\\<\\=\\/\\(\\)\\:\\,\\;\\&\\%\\'\\?]+$",s) is not None,"Bad "+s
		s = s + chr(0)
		return [ 0x8000 + ord(s[0]) + (ord(s[1]) << 8)]
	#
	#		encode a character
	#	
	def encodeChar(self,c):
		n = " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.".find(c.upper())
		assert n >= 0,"Unknown char "+c
		return n
	#
	#		Get the raw token list.
	#
	def getRaw(self):
		return """

// *****************************************************************************
//
//									Tokens in LC3 BASIC
//
// *****************************************************************************

//
//		Expression token
//
[1]
	and	or 	xor 
[2]	
	> >= < <= = <>
[3]	
	+ - 
[4]
	* / mod
[5]
	!
//
//		Basic Unary Functions
//
[Unary]
	( 	&	% 	|constshift
	abs(	asc(	chr$(	false	get( 	get$( 	inkey( 	inkey$( 	
	joyx( 	joyy( 	joyb(	left$(	len(	mid$(	peek(	right$(	
	rnd(	sgn(	str$(	true 	val(	
//
//		Synonyms
//
	length(	random(	to.string$( to.number( sign(
//
//		Syntax only tokens
//
[Syntax]
	) 		, 		; 		to 		step
//
//		Structure enter
//
[Cmd+]
		for if repeat while proc
//
//		Structure exit
//		
[Cmd-]
		endif  next then until wend endproc
//
//		Commands
//
[Cmd]
	' 		:		?
	assert 	call 	clear 	dim 	dir 	else 	end 	fkey	gosub 	
	goto 	input 	let 	list 	load 	new 	old 	poke 	print 	
	rem 	return 	run 	save 	stop 	sys 	

"""

Tokens.TOKENS = None		
Tokens.TOKENLIST = []

if __name__ == "__main__":	
	tk = Tokens()
	print(tk.getList())
	print(tk.getInfo("DIM"))	
	print(tk.getInfo("DIMX"))		
	
# *****************************************************************************
# *****************************************************************************
#
#		Name:		convert.py
#		Purpose:	Tokenising class, converts ASCII -> tokenised BASIC
#		Created:	3rd March 2020
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# *****************************************************************************
# *****************************************************************************

import re
from tokens import *

# *****************************************************************************
#
#								Tokeniser class
#
# *****************************************************************************

class Tokeniser(object):
	#
	def __init__(self):
		self.tokens = Tokens()
		self.tokenList = self.tokens.getList()
		self.tokenDictionary = self.tokens.getDictionary()
	#
	#							Tokenise a string
	#
	def tokenise(self,s):
		self.code = []
		s = s.strip().replace("\t"," ") 							# pre-process
		while s != "":												# work through string
			s = self._tokenise(s).strip()
		return self.code
	#
	def _tokenise(self,s):
		#
		#		Check for integer
		#
		base = 10
		m = re.match("^(\\d+)(.*)$",s)								# digits, in one
		if m is None:												# of three bases
			base = 2
			token = self.tokens.getInfo("%")["token"]
			m = re.match("^\\%([0-1]+)(.*)$",s)
			if m is None:
				base = 16
				token = self.tokens.getInfo("&")["token"]
				m = re.match("^\\&([0-9A-Fa-f]+)(.*)$",s)

		if m is not None:
			n = int(m.group(1),base) & 0xFFFF						# work out integer
			if base != 10:											# prefix ?
				self.code.append(token)
			if n >= 0x8000:											# if 8000-FFFF need constant shift
				self.code.append(self.tokens.getInfo("|constshift")["token"])
			self.code.append((n & 0x7FFF) | 0x8000)					# add lower 15 bits
			return m.group(2).strip()
		#
		#		Check for string
		#
		m = re.match('^"(.*?)\\"(.*)$',s)							# "<string>"
		if m is not None:
			st = m.group(1)
			st = st if len(st) % 2 == 0 else st + chr(0)			# make even length
			self.code.append(0x100+int(len(st)/2)+2)				# add token/length word
			self.code.append(len(m.group(1)))						# length prefixed
			for i in range(0,len(st),2):							# add compacted string.
				self.code.append(ord(st[i])+ord(st[i+1])*256)
			return m.group(2).strip()
		#
		#		
		#
		if s[0].upper() >= "A" and s[0].upper() <= "Z":				# identifier including $( ?
			m = re.match("^([A-Za-z][A-Za-z0-9\\.]*\\$?\\(?)(.*)$",s)
			assert m is not None									# problems if this fails !
			ident = m.group(1).upper()								# identifier.
			if ident in self.tokenDictionary:						# it's a token
				self.code.append(self.tokens.getInfo(ident)["token"])
			else:													# it's an identifier.
				self.code += self.tokens.encode(ident)
			return m.group(2)
		#
		#		Check for punctuation, the only thing left. Check the first two characters
		#		then the first character on its own. 
		#
		token = s[:2]												# check next two chars
		if token not in self.tokenDictionary:						# if not there try first char
			token = s[0]
		if token not in self.tokenDictionary:						# not known, can't tokenise
			raise Exception("Cannot tokenise "+s)
		self.code.append(self.tokens.getInfo(token)["token"])
		return s[len(token):]
	#
	#							Test routine
	#
	def test(self,s):
		c = ",".join(["${0:04x}".format(n) for n in self.tokenise(s)])
		print("\"{0}\"\n\t{1}".format(s,c))

if __name__ == "__main__":	
	tk = Tokeniser()
	tk.test('42 32769')
	tk.test('"Hi!"')
	tk.test("< <>")
	tk.test("left$( val( a( a$ print0 print")
	tk.test("%101010 &2A")
	tk.test("az09.q")
	tk.test("axxx(")
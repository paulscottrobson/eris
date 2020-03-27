# *****************************************************************************
# *****************************************************************************
#
#		Name:		tokens.py
#		Purpose:	Token class
#		Created:	2nd March 2020
#		Reviewed: 	17th March 2020
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
				if re.match("^\\[\\d\\]$",w) is not None:					# Switch token type
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
					assert not(w.startswith("[") and w.endswith("]"))		# bad type
					assert tokenID < 512 									# too many tokens.
					newToken = { "name":w,"token":0x2000+currentType*512+tokenID }
					tokenID += 1
					assert w not in Tokens.TOKENS,"Duplicate "+w
					Tokens.TOKENS[w] = newToken								# store in hash and list
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
		token = token.strip().upper()										# clean up
		if token.startswith("|"): 											# this means we dont' use it.
			return [0xFFFF]
		isAlpha = token[0] >= 'A' and token[0] <= 'Z'						# encoding for punctuation/identifier
		return self.encodeIdentifier(token) if isAlpha else self.encodePunctuation(token)
	#
	#		Encode an identifier which may end with $ $( or ( which types it.
	#
	def encodeIdentifier(self,s):
		m = re.match("^([A-Z][A-Z0-9\\.]*)(\\$?)(\\(?)$",s)					# check matches pattern
		assert m is not None,"Bad "+s
		s = m.group(1) if len(m.group(1)) % 2 == 0 else m.group(1)+" "		# pad to even size with spaces
		code = []
		for i in range(0,len(s),2): 										# build it a word at a time
			encWord = 0x4000 + self.encodeChar(s[i])+self.encodeChar(s[i+1])*40
			encWord = encWord if m.group(2) == "" else encWord+0x1000		# adjust for typing
			encWord = encWord if m.group(3) == "" else encWord+0x0800
			code.append(encWord)
		code[-1] += 0x2000 													# mark end of word
		return code
	#
	#		Encode a 1 or 2 character punctuation token
	#
	def encodePunctuation(self,s):
		assert len(s) <= 2 and s != "","Bad "+s 							# rubbish validation but works
		assert re.match("^[\\#\\.\\!\\+\\-\\*\\>\\<\\=\\/\\(\\)\\:\\,\\;\\&\\%\\'\\?]+$",s) is not None,"Bad "+s
		s = s + chr(0)
		return [ 0x8000 + ord(s[0]) + (ord(s[1]) << 8)]
	#
	#		encode a character
	#	
	def encodeChar(self,c):
		n = " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.".find(c.upper())		# identifier char -> 0-37
		assert n >= 0,"Unknown char "+c
		return n
	#
	#		Get the raw token list.
	#
	def getRaw(self):
		return """

// *****************************************************************************
// *****************************************************************************
//
//								Tokens in ERIS BASIC
//
// *****************************************************************************
// *****************************************************************************

//
//		Assembler operations first. Some of these (and, xor) are dual purpose
//		The first 16 are the standard set, the remainder popular macros or
//		other assembler functionality
//		(see assembler.py)
//
		[Syntax] 	mov ldm stm add adc sub 
		[1] 		and xor 
		[Syntax] 	mult ror brl skeq skne skse sksn skcm 	
		[Cmd]		clr jmp jsr ret skz sknz skp skm skc sknc skge sklt push pop code word .
//
//		Expression token. Note that AND and XOR are defined in the
//		assembler keywords, as they are "dual purpose", so if you renumber
//		the precedences don't forget those.
//
[1]
	or 
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
	abs(	alloc(	asc(	chr$(	exists(	false	get( 	get$( 	
	hit(	inkey( 	inkey$( joyx( 	joyy( 	joyb(	left$(	len(	
	lower$(	mid$(	page	peek(	right$(	rnd(	sgn(	str$(	
	sysvar(	true 	upper$(	val(	
//
//		Synonyms
//
	length(	random(	to.string$( to.number( sign(
//
//		Syntax only tokens
//
[Syntax]
	#		) 		, 		; 		to 		step
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
	assert 	blit 	call 	clear 	cls 	crunch 	cursor	dim 	dir 	
	draw	else 	end 	fkey	flip	frame 	gosub 	goto 	ink 	
	input 	let 	line	list 	load 	local 	move	new 	old		
	palette	paper	plot 	poke 	print 	rect 	rem 	renum	return 	
	run 	save 	screen	slide	sound	sprite 	stop 	sys 	wait
	
"""

Tokens.TOKENS = None		
Tokens.TOKENLIST = []

if __name__ == "__main__":	
	tk = Tokens()
	print(tk.getList())
	print(tk.getInfo("DIM"))	
	print(tk.getInfo("DIMX"))		
	
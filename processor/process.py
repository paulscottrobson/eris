# *****************************************************************************
# *****************************************************************************
#
#		Name:		process.py
#		Purpose:	Processor CPU Definition
#		Created:	8th March 2020
#		Reviewed: 	17th March 2020
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# *****************************************************************************
# *****************************************************************************
#
#								Processor
#
import re,os,sys

h = open("_instructions.h","w")

instrText = "ldc,ldm,stm,add,adc,sub,and,xor,mult,ror,brl,skeq,skne,skse,sksn,skcm".split(",")			# operation code.
testText = ["ISZERO","ISPOSITIVE","ISCARRY","ISBLITTERAVAILABLE"] 	# Skip tests.

for i in range(0,4096):
	opcode = i << 4 												# operation code
	instr = i >> 8 													# instruction code
	bRegister = i & 15 												# B Register (source)
	aRegister = (i >> 4) & 15 										# A Register (target)

	value = "(R{0}+CONST())".format(bRegister)						# RH value and Asm.
	assembler = "{0} r{1},r{2},#*".format(instrText[instr],aRegister,bRegister)
	if bRegister == 0x0F: 
		value = "FETCH()" 
		assembler = "{0} r{1},#*".format(instrText[instr],aRegister)
	code = [] 														# code generated.
	#
	if instr == 0:													# 0000 LDC
		code.append("R{0} = {1}".format(aRegister,value))
	if instr == 1:													# 0001 LDM
		code.append("R{0} = READ({1})".format(aRegister,value))
	if instr == 2:													# 0010 STM
		code.append("WRITE({1},R{0})".format(aRegister,value))
	if instr == 3:													# 0011 ADD
		code.append("R{0} = add16Bit(R{0},{1},0)".format(aRegister,value))
	if instr == 4:													# 0100 ADC
		code.append("R{0} = add16Bit(R{0},{1},carryFlag)".format(aRegister,value))
	if instr == 5:													# 0101 SUB
		code.append("R{0} = sub16Bit(R{0},{1})".format(aRegister,value))
	if instr == 6:													# 0110 AND
		code.append("R{0} &= {1}".format(aRegister,value))
	if instr == 7:													# 0111 XOR
		code.append("R{0} ^= {1}".format(aRegister,value))
	if instr == 8:													# 1000 MULT
		code.append("R{0} = mul16Bit(R{0},{1})".format(aRegister,value))
	if instr == 9:													# 1001 ROR
		code.append("R{0} = ror16Bit(R{0},{1})".format(aRegister,value))
	if instr == 10:													# 1010 BRL
		code += [ "temp16 = "+value,"R{0} = R15".format(aRegister),"R15 = temp16"]
	if instr == 11:													# 1011 SKEQ
		code.append("SKIP(R{0} == {1})".format(aRegister,value))
	if instr == 12:													# 1100 SKNE
		code.append("SKIP(R{0} != {1})".format(aRegister,value))
	if instr == 13:													# 1101 SKSE
		code.append("SKIP((R{0} & 0x8000) == ({1} & 0x8000))".format(aRegister,value))
	if instr == 14:													# 1110 SKSN
		code.append("SKIP((R{0} & 0x8000) != ({1} & 0x8000))".format(aRegister,value))
	if instr == 15 and aRegister == 15:								# 1111 SKCM
		code.append("SKIP(carryFlag == ({0} & 0x0001))".format(value))
	#
	if len(code) > 0:
		h.write("case 0x{0:03x}: {1};break; // {2}\n".format(i,";".join(code),assembler))
	#
h.close()
print("CPU Generation successful.")

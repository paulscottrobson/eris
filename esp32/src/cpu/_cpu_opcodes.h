case 0x00: /*** $00 LDR R0 ***/
	R0 = READ16(R0);break;
case 0x01: /*** $01 LDR R1 ***/
	R0 = READ16(R1);break;
case 0x02: /*** $02 LDR R2 ***/
	R0 = READ16(R2);break;
case 0x03: /*** $03 LDR R3 ***/
	R0 = READ16(R3);break;
case 0x04: /*** $04 LDR R4 ***/
	R0 = READ16(R4);break;
case 0x05: /*** $05 LDR R5 ***/
	R0 = READ16(R5);break;
case 0x06: /*** $06 LDR R6 ***/
	R0 = READ16(R6);break;
case 0x07: /*** $07 LDR R7 ***/
	R0 = READ16(R7);break;
case 0x08: /*** $08 LDR R8 ***/
	R0 = READ16(R8);break;
case 0x09: /*** $09 LDR R9 ***/
	R0 = READ16(R9);break;
case 0x0a: /*** $0a LDR RA ***/
	R0 = READ16(RA);break;
case 0x0b: /*** $0b LDR RB ***/
	R0 = READ16(RB);break;
case 0x0c: /*** $0c LDR RC ***/
	R0 = READ16(RC);break;
case 0x0d: /*** $0d LDR RD ***/
	R0 = READ16(RD);break;
case 0x0e: /*** $0e LDR RE ***/
	R0 = READ16(RE);break;
case 0x0f: /*** $0f LDR #$ ***/
	R0 = READ16(FETCH16());break;
case 0x10: /*** $10 STR R0 ***/
	WRITE16(R0,R0);break;
case 0x11: /*** $11 STR R1 ***/
	WRITE16(R1,R0);break;
case 0x12: /*** $12 STR R2 ***/
	WRITE16(R2,R0);break;
case 0x13: /*** $13 STR R3 ***/
	WRITE16(R3,R0);break;
case 0x14: /*** $14 STR R4 ***/
	WRITE16(R4,R0);break;
case 0x15: /*** $15 STR R5 ***/
	WRITE16(R5,R0);break;
case 0x16: /*** $16 STR R6 ***/
	WRITE16(R6,R0);break;
case 0x17: /*** $17 STR R7 ***/
	WRITE16(R7,R0);break;
case 0x18: /*** $18 STR R8 ***/
	WRITE16(R8,R0);break;
case 0x19: /*** $19 STR R9 ***/
	WRITE16(R9,R0);break;
case 0x1a: /*** $1a STR RA ***/
	WRITE16(RA,R0);break;
case 0x1b: /*** $1b STR RB ***/
	WRITE16(RB,R0);break;
case 0x1c: /*** $1c STR RC ***/
	WRITE16(RC,R0);break;
case 0x1d: /*** $1d STR RD ***/
	WRITE16(RD,R0);break;
case 0x1e: /*** $1e STR RE ***/
	WRITE16(RE,R0);break;
case 0x1f: /*** $1f STR #$ ***/
	WRITE16(FETCH16(),R0);break;
case 0x20: /*** $20 LDA R0 ***/
	R0 = READ16(R0);R0 += 2;break;
case 0x21: /*** $21 LDA R1 ***/
	R0 = READ16(R1);R1 += 2;break;
case 0x22: /*** $22 LDA R2 ***/
	R0 = READ16(R2);R2 += 2;break;
case 0x23: /*** $23 LDA R3 ***/
	R0 = READ16(R3);R3 += 2;break;
case 0x24: /*** $24 LDA R4 ***/
	R0 = READ16(R4);R4 += 2;break;
case 0x25: /*** $25 LDA R5 ***/
	R0 = READ16(R5);R5 += 2;break;
case 0x26: /*** $26 LDA R6 ***/
	R0 = READ16(R6);R6 += 2;break;
case 0x27: /*** $27 LDA R7 ***/
	R0 = READ16(R7);R7 += 2;break;
case 0x28: /*** $28 LDA R8 ***/
	R0 = READ16(R8);R8 += 2;break;
case 0x29: /*** $29 LDA R9 ***/
	R0 = READ16(R9);R9 += 2;break;
case 0x2a: /*** $2a LDA RA ***/
	R0 = READ16(RA);RA += 2;break;
case 0x2b: /*** $2b LDA RB ***/
	R0 = READ16(RB);RB += 2;break;
case 0x2c: /*** $2c LDA RC ***/
	R0 = READ16(RC);RC += 2;break;
case 0x2d: /*** $2d LDA RD ***/
	R0 = READ16(RD);RD += 2;break;
case 0x2e: /*** $2e LDA RE ***/
	R0 = READ16(RE);RE += 2;break;
case 0x30: /*** $30 STD R0 ***/
	R0 -= 2;WRITE16(R0,R0);break;
case 0x31: /*** $31 STD R1 ***/
	R1 -= 2;WRITE16(R1,R0);break;
case 0x32: /*** $32 STD R2 ***/
	R2 -= 2;WRITE16(R2,R0);break;
case 0x33: /*** $33 STD R3 ***/
	R3 -= 2;WRITE16(R3,R0);break;
case 0x34: /*** $34 STD R4 ***/
	R4 -= 2;WRITE16(R4,R0);break;
case 0x35: /*** $35 STD R5 ***/
	R5 -= 2;WRITE16(R5,R0);break;
case 0x36: /*** $36 STD R6 ***/
	R6 -= 2;WRITE16(R6,R0);break;
case 0x37: /*** $37 STD R7 ***/
	R7 -= 2;WRITE16(R7,R0);break;
case 0x38: /*** $38 STD R8 ***/
	R8 -= 2;WRITE16(R8,R0);break;
case 0x39: /*** $39 STD R9 ***/
	R9 -= 2;WRITE16(R9,R0);break;
case 0x3a: /*** $3a STD RA ***/
	RA -= 2;WRITE16(RA,R0);break;
case 0x3b: /*** $3b STD RB ***/
	RB -= 2;WRITE16(RB,R0);break;
case 0x3c: /*** $3c STD RC ***/
	RC -= 2;WRITE16(RC,R0);break;
case 0x3d: /*** $3d STD RD ***/
	RD -= 2;WRITE16(RD,R0);break;
case 0x3e: /*** $3e STD RE ***/
	RE -= 2;WRITE16(RE,R0);break;
case 0x40: /*** $40 GET R0 ***/
	R0 = R0;break;
case 0x41: /*** $41 GET R1 ***/
	R0 = R1;break;
case 0x42: /*** $42 GET R2 ***/
	R0 = R2;break;
case 0x43: /*** $43 GET R3 ***/
	R0 = R3;break;
case 0x44: /*** $44 GET R4 ***/
	R0 = R4;break;
case 0x45: /*** $45 GET R5 ***/
	R0 = R5;break;
case 0x46: /*** $46 GET R6 ***/
	R0 = R6;break;
case 0x47: /*** $47 GET R7 ***/
	R0 = R7;break;
case 0x48: /*** $48 GET R8 ***/
	R0 = R8;break;
case 0x49: /*** $49 GET R9 ***/
	R0 = R9;break;
case 0x4a: /*** $4a GET RA ***/
	R0 = RA;break;
case 0x4b: /*** $4b GET RB ***/
	R0 = RB;break;
case 0x4c: /*** $4c GET RC ***/
	R0 = RC;break;
case 0x4d: /*** $4d GET RD ***/
	R0 = RD;break;
case 0x4e: /*** $4e GET RE ***/
	R0 = RE;break;
case 0x4f: /*** $4f GET #$ ***/
	R0 = FETCH16();break;
case 0x50: /*** $50 PUT R0 ***/
	R0 = R0;break;
case 0x51: /*** $51 PUT R1 ***/
	R1 = R0;break;
case 0x52: /*** $52 PUT R2 ***/
	R2 = R0;break;
case 0x53: /*** $53 PUT R3 ***/
	R3 = R0;break;
case 0x54: /*** $54 PUT R4 ***/
	R4 = R0;break;
case 0x55: /*** $55 PUT R5 ***/
	R5 = R0;break;
case 0x56: /*** $56 PUT R6 ***/
	R6 = R0;break;
case 0x57: /*** $57 PUT R7 ***/
	R7 = R0;break;
case 0x58: /*** $58 PUT R8 ***/
	R8 = R0;break;
case 0x59: /*** $59 PUT R9 ***/
	R9 = R0;break;
case 0x5a: /*** $5a PUT RA ***/
	RA = R0;break;
case 0x5b: /*** $5b PUT RB ***/
	RB = R0;break;
case 0x5c: /*** $5c PUT RC ***/
	RC = R0;break;
case 0x5d: /*** $5d PUT RD ***/
	RD = R0;break;
case 0x5e: /*** $5e PUT RE ***/
	RE = R0;break;
case 0x60: /*** $60 INC R0 ***/
	R0++;break;
case 0x61: /*** $61 INC R1 ***/
	R1++;break;
case 0x62: /*** $62 INC R2 ***/
	R2++;break;
case 0x63: /*** $63 INC R3 ***/
	R3++;break;
case 0x64: /*** $64 INC R4 ***/
	R4++;break;
case 0x65: /*** $65 INC R5 ***/
	R5++;break;
case 0x66: /*** $66 INC R6 ***/
	R6++;break;
case 0x67: /*** $67 INC R7 ***/
	R7++;break;
case 0x68: /*** $68 INC R8 ***/
	R8++;break;
case 0x69: /*** $69 INC R9 ***/
	R9++;break;
case 0x6a: /*** $6a INC RA ***/
	RA++;break;
case 0x6b: /*** $6b INC RB ***/
	RB++;break;
case 0x6c: /*** $6c INC RC ***/
	RC++;break;
case 0x6d: /*** $6d INC RD ***/
	RD++;break;
case 0x6e: /*** $6e INC RE ***/
	RE++;break;
case 0x70: /*** $70 DEC R0 ***/
	R0--;break;
case 0x71: /*** $71 DEC R1 ***/
	R1--;break;
case 0x72: /*** $72 DEC R2 ***/
	R2--;break;
case 0x73: /*** $73 DEC R3 ***/
	R3--;break;
case 0x74: /*** $74 DEC R4 ***/
	R4--;break;
case 0x75: /*** $75 DEC R5 ***/
	R5--;break;
case 0x76: /*** $76 DEC R6 ***/
	R6--;break;
case 0x77: /*** $77 DEC R7 ***/
	R7--;break;
case 0x78: /*** $78 DEC R8 ***/
	R8--;break;
case 0x79: /*** $79 DEC R9 ***/
	R9--;break;
case 0x7a: /*** $7a DEC RA ***/
	RA--;break;
case 0x7b: /*** $7b DEC RB ***/
	RB--;break;
case 0x7c: /*** $7c DEC RC ***/
	RC--;break;
case 0x7d: /*** $7d DEC RD ***/
	RD--;break;
case 0x7e: /*** $7e DEC RE ***/
	RE--;break;
case 0x80: /*** $80 PSH R0 ***/
	RD -= 2;WRITE16(RD,R0);break;
case 0x81: /*** $81 PSH R1 ***/
	RD -= 2;WRITE16(RD,R1);break;
case 0x82: /*** $82 PSH R2 ***/
	RD -= 2;WRITE16(RD,R2);break;
case 0x83: /*** $83 PSH R3 ***/
	RD -= 2;WRITE16(RD,R3);break;
case 0x84: /*** $84 PSH R4 ***/
	RD -= 2;WRITE16(RD,R4);break;
case 0x85: /*** $85 PSH R5 ***/
	RD -= 2;WRITE16(RD,R5);break;
case 0x86: /*** $86 PSH R6 ***/
	RD -= 2;WRITE16(RD,R6);break;
case 0x87: /*** $87 PSH R7 ***/
	RD -= 2;WRITE16(RD,R7);break;
case 0x88: /*** $88 PSH R8 ***/
	RD -= 2;WRITE16(RD,R8);break;
case 0x89: /*** $89 PSH R9 ***/
	RD -= 2;WRITE16(RD,R9);break;
case 0x8a: /*** $8a PSH RA ***/
	RD -= 2;WRITE16(RD,RA);break;
case 0x8b: /*** $8b PSH RB ***/
	RD -= 2;WRITE16(RD,RB);break;
case 0x8c: /*** $8c PSH RC ***/
	RD -= 2;WRITE16(RD,RC);break;
case 0x8d: /*** $8d PSH RD ***/
	RD -= 2;WRITE16(RD,RD);break;
case 0x8e: /*** $8e PSH RE ***/
	RD -= 2;WRITE16(RD,RE);break;
case 0x8f: /*** $8f PSH #$ ***/
	RD -= 2;WRITE16(RD,FETCH16());break;
case 0x90: /*** $90 POP R0 ***/
	R0 = READ16(RD);RD += 2;break;
case 0x91: /*** $91 POP R1 ***/
	R1 = READ16(RD);RD += 2;break;
case 0x92: /*** $92 POP R2 ***/
	R2 = READ16(RD);RD += 2;break;
case 0x93: /*** $93 POP R3 ***/
	R3 = READ16(RD);RD += 2;break;
case 0x94: /*** $94 POP R4 ***/
	R4 = READ16(RD);RD += 2;break;
case 0x95: /*** $95 POP R5 ***/
	R5 = READ16(RD);RD += 2;break;
case 0x96: /*** $96 POP R6 ***/
	R6 = READ16(RD);RD += 2;break;
case 0x97: /*** $97 POP R7 ***/
	R7 = READ16(RD);RD += 2;break;
case 0x98: /*** $98 POP R8 ***/
	R8 = READ16(RD);RD += 2;break;
case 0x99: /*** $99 POP R9 ***/
	R9 = READ16(RD);RD += 2;break;
case 0x9a: /*** $9a POP RA ***/
	RA = READ16(RD);RD += 2;break;
case 0x9b: /*** $9b POP RB ***/
	RB = READ16(RD);RD += 2;break;
case 0x9c: /*** $9c POP RC ***/
	RC = READ16(RD);RD += 2;break;
case 0x9d: /*** $9d POP RD ***/
	RD = READ16(RD);RD += 2;break;
case 0x9e: /*** $9e POP RE ***/
	RE = READ16(RD);RD += 2;break;
case 0xa0: /*** $a0 ADD R0 ***/
	Add16Bit(R0,0);break;
case 0xa1: /*** $a1 ADD R1 ***/
	Add16Bit(R1,0);break;
case 0xa2: /*** $a2 ADD R2 ***/
	Add16Bit(R2,0);break;
case 0xa3: /*** $a3 ADD R3 ***/
	Add16Bit(R3,0);break;
case 0xa4: /*** $a4 ADD R4 ***/
	Add16Bit(R4,0);break;
case 0xa5: /*** $a5 ADD R5 ***/
	Add16Bit(R5,0);break;
case 0xa6: /*** $a6 ADD R6 ***/
	Add16Bit(R6,0);break;
case 0xa7: /*** $a7 ADD R7 ***/
	Add16Bit(R7,0);break;
case 0xa8: /*** $a8 ADD R8 ***/
	Add16Bit(R8,0);break;
case 0xa9: /*** $a9 ADD R9 ***/
	Add16Bit(R9,0);break;
case 0xaa: /*** $aa ADD RA ***/
	Add16Bit(RA,0);break;
case 0xab: /*** $ab ADD RB ***/
	Add16Bit(RB,0);break;
case 0xac: /*** $ac ADD RC ***/
	Add16Bit(RC,0);break;
case 0xad: /*** $ad ADD RD ***/
	Add16Bit(RD,0);break;
case 0xae: /*** $ae ADD RE ***/
	Add16Bit(RE,0);break;
case 0xaf: /*** $af ADD #$ ***/
	Add16Bit(FETCH16(),0);break;
case 0xb0: /*** $b0 SUB R0 ***/
	Add16Bit(R0 ^ 0xFFFF,1);break;
case 0xb1: /*** $b1 SUB R1 ***/
	Add16Bit(R1 ^ 0xFFFF,1);break;
case 0xb2: /*** $b2 SUB R2 ***/
	Add16Bit(R2 ^ 0xFFFF,1);break;
case 0xb3: /*** $b3 SUB R3 ***/
	Add16Bit(R3 ^ 0xFFFF,1);break;
case 0xb4: /*** $b4 SUB R4 ***/
	Add16Bit(R4 ^ 0xFFFF,1);break;
case 0xb5: /*** $b5 SUB R5 ***/
	Add16Bit(R5 ^ 0xFFFF,1);break;
case 0xb6: /*** $b6 SUB R6 ***/
	Add16Bit(R6 ^ 0xFFFF,1);break;
case 0xb7: /*** $b7 SUB R7 ***/
	Add16Bit(R7 ^ 0xFFFF,1);break;
case 0xb8: /*** $b8 SUB R8 ***/
	Add16Bit(R8 ^ 0xFFFF,1);break;
case 0xb9: /*** $b9 SUB R9 ***/
	Add16Bit(R9 ^ 0xFFFF,1);break;
case 0xba: /*** $ba SUB RA ***/
	Add16Bit(RA ^ 0xFFFF,1);break;
case 0xbb: /*** $bb SUB RB ***/
	Add16Bit(RB ^ 0xFFFF,1);break;
case 0xbc: /*** $bc SUB RC ***/
	Add16Bit(RC ^ 0xFFFF,1);break;
case 0xbd: /*** $bd SUB RD ***/
	Add16Bit(RD ^ 0xFFFF,1);break;
case 0xbe: /*** $be SUB RE ***/
	Add16Bit(RE ^ 0xFFFF,1);break;
case 0xbf: /*** $bf SUB #$ ***/
	Add16Bit(FETCH16() ^ 0xFFFF,1);break;
case 0xc0: /*** $c0 AND R0 ***/
	R0 &= R0;break;
case 0xc1: /*** $c1 AND R1 ***/
	R0 &= R1;break;
case 0xc2: /*** $c2 AND R2 ***/
	R0 &= R2;break;
case 0xc3: /*** $c3 AND R3 ***/
	R0 &= R3;break;
case 0xc4: /*** $c4 AND R4 ***/
	R0 &= R4;break;
case 0xc5: /*** $c5 AND R5 ***/
	R0 &= R5;break;
case 0xc6: /*** $c6 AND R6 ***/
	R0 &= R6;break;
case 0xc7: /*** $c7 AND R7 ***/
	R0 &= R7;break;
case 0xc8: /*** $c8 AND R8 ***/
	R0 &= R8;break;
case 0xc9: /*** $c9 AND R9 ***/
	R0 &= R9;break;
case 0xca: /*** $ca AND RA ***/
	R0 &= RA;break;
case 0xcb: /*** $cb AND RB ***/
	R0 &= RB;break;
case 0xcc: /*** $cc AND RC ***/
	R0 &= RC;break;
case 0xcd: /*** $cd AND RD ***/
	R0 &= RD;break;
case 0xce: /*** $ce AND RE ***/
	R0 &= RE;break;
case 0xcf: /*** $cf AND #$ ***/
	R0 &= FETCH16();break;
case 0xd0: /*** $d0 XOR R0 ***/
	R0 ^= R0;break;
case 0xd1: /*** $d1 XOR R1 ***/
	R0 ^= R1;break;
case 0xd2: /*** $d2 XOR R2 ***/
	R0 ^= R2;break;
case 0xd3: /*** $d3 XOR R3 ***/
	R0 ^= R3;break;
case 0xd4: /*** $d4 XOR R4 ***/
	R0 ^= R4;break;
case 0xd5: /*** $d5 XOR R5 ***/
	R0 ^= R5;break;
case 0xd6: /*** $d6 XOR R6 ***/
	R0 ^= R6;break;
case 0xd7: /*** $d7 XOR R7 ***/
	R0 ^= R7;break;
case 0xd8: /*** $d8 XOR R8 ***/
	R0 ^= R8;break;
case 0xd9: /*** $d9 XOR R9 ***/
	R0 ^= R9;break;
case 0xda: /*** $da XOR RA ***/
	R0 ^= RA;break;
case 0xdb: /*** $db XOR RB ***/
	R0 ^= RB;break;
case 0xdc: /*** $dc XOR RC ***/
	R0 ^= RC;break;
case 0xdd: /*** $dd XOR RD ***/
	R0 ^= RD;break;
case 0xde: /*** $de XOR RE ***/
	R0 ^= RE;break;
case 0xdf: /*** $df XOR #$ ***/
	R0 ^= FETCH16();break;
case 0xe0: /*** $e0 BRL R0 ***/
	temp16 = R0;RE = PC;PC = temp16;break;
case 0xe1: /*** $e1 BRL R1 ***/
	temp16 = R1;RE = PC;PC = temp16;break;
case 0xe2: /*** $e2 BRL R2 ***/
	temp16 = R2;RE = PC;PC = temp16;break;
case 0xe3: /*** $e3 BRL R3 ***/
	temp16 = R3;RE = PC;PC = temp16;break;
case 0xe4: /*** $e4 BRL R4 ***/
	temp16 = R4;RE = PC;PC = temp16;break;
case 0xe5: /*** $e5 BRL R5 ***/
	temp16 = R5;RE = PC;PC = temp16;break;
case 0xe6: /*** $e6 BRL R6 ***/
	temp16 = R6;RE = PC;PC = temp16;break;
case 0xe7: /*** $e7 BRL R7 ***/
	temp16 = R7;RE = PC;PC = temp16;break;
case 0xe8: /*** $e8 BRL R8 ***/
	temp16 = R8;RE = PC;PC = temp16;break;
case 0xe9: /*** $e9 BRL R9 ***/
	temp16 = R9;RE = PC;PC = temp16;break;
case 0xea: /*** $ea BRL RA ***/
	temp16 = RA;RE = PC;PC = temp16;break;
case 0xeb: /*** $eb BRL RB ***/
	temp16 = RB;RE = PC;PC = temp16;break;
case 0xec: /*** $ec BRL RC ***/
	temp16 = RC;RE = PC;PC = temp16;break;
case 0xed: /*** $ed BRL RD ***/
	temp16 = RD;RE = PC;PC = temp16;break;
case 0xee: /*** $ee BRL RE ***/
	temp16 = RE;RE = PC;PC = temp16;break;
case 0xef: /*** $ef BRL #$ ***/
	RE = PC+2;PC = FETCH16();break;
case 0xf0: /*** $f0 SKZ ***/
	Skip(R0 == 0);break;
case 0xf1: /*** $f1 SKNZ ***/
	Skip(R0 != 0);break;
case 0xf2: /*** $f2 SKNC ***/
	Skip(carryFlag == 0);break;
case 0xf3: /*** $f3 SKC ***/
	Skip(carryFlag != 0);break;
case 0xf4: /*** $f4 SKP ***/
	Skip((R0 & 0x8000) == 0);break;
case 0xf5: /*** $f5 SKM ***/
	Skip((R0 & 0x8000) != 0);break;
case 0xf8: /*** $f8 SHR ***/
	carryFlag = R0 & 1;R0 = R0 >> 1;break;
case 0xf9: /*** $f9 SWP ***/
	R0 = (R0 >> 8) | (R0 << 8);break;
case 0xfa: /*** $fa MLT ***/
	_temp32 = R0 * R1;R0 = _temp32;R1 = _temp32 >> 16;break;
case 0xfb: /*** $fb RTI ***/
	interruptActive = 0;PC = interruptReturn;;break;
case 0xff: /*** $ff BRK ***/
	{};break;

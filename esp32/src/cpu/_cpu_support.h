static void inline Skip(BYTE8 test) {
	if (test) {
		PC +=  (ISLONGOPCODE() ? 3 : 1);
	}
}
static inline void Add16Bit(WORD16 n1,BYTE8 c) {
	R0 = _temp32 = R0 + n1 + c;
	carryFlag = (_temp32 & 0x10000) ? 1 : 0;
}
static void resetCPU(void) {
	PC = 0;								// PC is zero
	carryFlag &= 1;						// Carry flag is 1 bit.
}

.TestTokeniserRoutine
	mov r0,#TokenTest
	jsr #TokeniseString
	break
.TokenTest
	word $3920,$0c20,$8c34,$7d32,$7220,$4726,$3432,$2c41,$d820,$1025,$0f31,$2f30,$6f31,$7730,$0d31,$6530,$d620,$7034,$e530,$8e30,$0330,$5130,$d820,$ae26,$8e43,$4f30,$6e30,$ac30,$3400

.TestTokeniserRoutine
	mov r0,#TokenTest
	jsr #TokeniseString
	break
	jmp #TestTokeniserRoutine
.TokenTest
	word $3922,$0c41,$8c42,$7d43,$7222,$4700

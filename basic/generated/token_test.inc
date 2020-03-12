.TestTokeniserRoutine
	mov r0,#TokenTest
	jsr #TokeniseString
	break
	jmp #TestTokeniserRoutine
.TokenTest
	word $3920,$0c20,$8c34,$7d32,$7220,$4700

.TestTokeniserRoutine
	mov r0,#TokenTest
	jsr #TokeniseString
	break
	jmp #TestTokeniserRoutine
.TokenTest
	word $3961,$0c00

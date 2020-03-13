.TestTokeniserRoutine
	mov r0,#TokenTest
	jsr #TokeniseString
	break
	jmp #TestTokeniserRoutine
.TokenTest
	word $3922,$0c41,$8c42,$7d43,$7222,$4722,$3422,$2c20,$d822,$1041,$0f42,$2f43,$6f44,$7722,$0d20,$6522,$d641,$7022,$e520,$8e22,$0341,$5142,$d822,$ae00

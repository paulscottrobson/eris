.TestTokeniserRoutine
	mov r0,#TokenTest
	jsr #TokeniseString
	break
	jmp #TestTokeniserRoutine
.TokenTest
	word $3974,$0c6f,$8c2e,$7d6e,$7275,$476d,$3462,$2c65,$d872,$1028,$0f72,$2f69,$6f67,$7768,$0d74,$6524,$d628,$7070,$e572,$8e69,$036e,$5174,$d83e,$ae3d,$8e00

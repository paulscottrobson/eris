; *****************************************************************************
; *****************************************************************************
;
;		Name:		if.asm
;		Purpose:	If/Then and If/Else/Endif
;		Created:	10th March 2020
;		Reviewed: 	TODO
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

; *****************************************************************************
;
;									IF
;
;		IF <expr> THEN <code to end of line>
;		IF <expr> <code> [ELSE <code>] ENDIF multi-line structure
;
; *****************************************************************************

.Command_If		;; [if]
		push 	link
		jsr 	#EvaluateInteger 			; test ?
		;
		ldm 	r1,r11,#0 					; get next token
		xor 	r1,#TOK_THEN 				; if not then go to multiline handler
		skz 	r1
		jmp 	#_CIFMultiLine
		;
		; 	IF <expr> THEN <code>
		;
		inc 	r11 						; skip over THEN
		skz 	r0 							; if the result failed then skip to EOL.
		jmp 	#_CIFExit 					; otherwise just carry on
		;
		ldm 	r11,#currentLine 			; go to next line
		ldm 	r0,r11,#0 					; read offset of current line
		add 	r11,r0,#0 					; start of next line
		dec 	r11 						; end of this line.
._CIFExit
		pop 	link
		ret
		;
		;		IF <expr> code [ELSE <code>] ENDIF
		;
._CIFMultiLine
		sknz 	r0 							; if continue
		jmp 	#_CIFMultiLine_False
		;
		;		Multi-line true.  Run from here. If hit ELSE pop and Skip
		;		If hit ENDIF pop and continue.
		;
		jsr 	#StackPushMarker 			; push an 'I' marker
		word 	'I'
		pop 	link
		ret
		;
		;		Multi-line false. Skip to ELSE or ENDIF
		;
._CIFMultiline_False		
		mov 	r0,#TOK_ELSE
		mov 	r1,#TOK_ENDIF
		jsr 	#SkipStructure
		dec 	r11 						; get what was found, ELSE or ENDIF
		ldm 	r0,r11,#0
		inc 	r11							; back to token after.
		xor 	r0,#TOK_ENDIF 				; if it is ENDIF, then just carry on
		sknz 	r0
		jmp 	#_CIFExit
		;
		;		Found an ELSE
		;
		jsr 	#StackPushMarker 			; push an 'I' marker
		word 	'I'
		pop 	link
		ret

; *****************************************************************************
;
;				ELSE checks we are in an IF, and skips to ENDIF
;
; *****************************************************************************

.Command_ELSE	;; [else]
		push 	link
		jsr 	#StackCheckMarker 			; check TOS is an 'S' marker.
		word 	'I'
		jmp 	#ElseError
		mov 	r0,#1 						; and reclaim that many words off the stack
		jsr 	#StackPopWords
		mov 	r0,#TOK_ENDIF 				; skip the ELSE claus
		mov 	r1,r0,#0
		jsr 	#SkipStructure
		pop 	link
		ret

; *****************************************************************************
;
;				ENDIF checks we are in an IF and throws that marker
;
; *****************************************************************************

.Command_ENDIF	;; [endif]
		push 	link
		jsr 	#StackCheckMarker 			; check TOS is an 'S' marker.
		word 	'I'
		jmp 	#EndifError
		mov 	r0,#1 						; and reclaim that many words off the stack
		jsr 	#StackPopWords
		pop 	link
		ret


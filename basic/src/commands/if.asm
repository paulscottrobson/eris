; *****************************************************************************
; *****************************************************************************
;
;		Name:		if.asm
;		Purpose:	If/Then and If/Else/Endif
;		Created:	10th March 2020
;		Reviewed: 	16th March 2020
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
		; 	IF <expr> THEN <code> handler
		;
		inc 	r11 						; skip over THEN token
		skz 	r0 							; if the result failed then skip to EOL.
		jmp 	#_CIFExit 					; otherwise just carry on
		;
		ldm 	r11,#currentLine 			; get current line
		ldm 	r0,r11,#0 					; read offset of current line
		add 	r11,r0,#0 					; add to take to next line.
		dec 	r11 						; last token of line $0000 will force next line.
._CIFExit
		pop 	link
		ret
		;
		;		IF <expr> code [ELSE <code>] ENDIF
		;
._CIFMultiLine
		sknz 	r0 							; if continue ?
		jmp 	#_CIFMultiLine_False
		;
		;		Multi-line true.  Run from here. If hit ELSE pop and Skip
		;		If hit ENDIF pop and continue.
		;
		jsr 	#StackPushMarker 			; push an 'I' marker, as we're in a structure
		word 	'I'
		pop 	link
		ret
		;
		;		Multi-line false. Skip to ELSE or ENDIF
		;
._CIFMultiline_False		
		mov 	r0,#TOK_ELSE 				; want to hit one of these
		mov 	r1,#TOK_ENDIF
		jsr 	#SkipStructure
		;
		dec 	r11 						; get what was found, ELSE or ENDIF
		ldm 	r0,r11,#0
		inc 	r11							; back to token after ELSE/ENDIF
		xor 	r0,#TOK_ENDIF 				; if it is ENDIF, then just carry on
		sknz 	r0
		jmp 	#_CIFExit
		;
		;		Found an ELSE e.g. IF <fail> <code> ELSE <here> ....
		;
		jsr 	#StackPushMarker 			; push an 'I' marker so we know we're executing
		word 	'I' 						; an IF
		pop 	link
		ret

; *****************************************************************************
;
;				ELSE checks we are in an IF, and skips to ENDIF
;
;		To execute it you have to have done IF <true> <code executed> ELSE
;
; *****************************************************************************

.Command_ELSE	;; [else]
		push 	link
		jsr 	#StackCheckMarker 			; check TOS is an 'S' marker.
		word 	'I'
		jmp 	#ElseError
		mov 	r0,#1 						; and reclaim that many words off the stack
		jsr 	#StackPopWords
		mov 	r0,#TOK_ENDIF 				; skip the ELSE code.
		mov 	r1,r0,#0
		jsr 	#SkipStructure
		pop 	link
		ret

; *****************************************************************************
;
;				ENDIF checks we are in an IF and throws that marker
;
;	   This is executed by IF <fail> <ignored code> ELSE <exec code> ENDIF
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

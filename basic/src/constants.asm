; *****************************************************************************
; *****************************************************************************
;
;		Name:		constants.asm
;		Purpose:	Basic Constants
;		Created:	3rd March 2020
;		Reviewed: 	16th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

;
;		Memory allocate for CPU stack
;
cpuStackSize = 256
;
;		Max size of string
;
maxStringSize = 255
;
;		Extra space allocated concreting strings, so that they can be expanded in words
;
extraStringAlloc = 8
;
;		Variable hash table size. hashTableSize = 2^hashTablePower
;
hashTableSize = 16
hashTablePower = 4				
;
;		Evaluation stack depth and size
;
stackSize = 32
stackElementSize = 3
;
;		Offsets to evaluation stack elements on 1st and 2nd levels
;
esValue1 = 0
esType1 = 1
esReference1 = 2		

esValue2 = 0+stackElementSize
esType2 = 1+stackElementSize
esReference2 = 2+stackElementSize
;
;		Size of return stack for CALL, REPEAT etc.
;
returnStackSize = 256
;
; 		Words required to store the stack position (line address, code address)
;
stackPosSize = 2
;
;		Indent spaces per level when listing structures.
;
indentStep = 2
;
;		Colour schemes for listing
;
theme_line = 2 			; green lines
theme_keyword = 6 		; cyan keywords
theme_ident = 3 		; yellow identifiers
theme_const = 3 		; yellow integers
theme_string = 7 		; white strings
theme_punc = 2			; green punctuation


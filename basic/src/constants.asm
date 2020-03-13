; *****************************************************************************
; *****************************************************************************
;
;		Name:		constants.asm
;		Purpose:	Basic Constants
;		Created:	3rd March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

;
;		Max size of string
;
maxStringSize = 255
;
;		Extra space allocated concreting strings, so that they can be expanded
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
;		Offsets to evaluation stack elements
;
esValue1 = 0
esType1 = 1
esReference1 = 2		

esValue2 = 0+stackElementSize
esType2 = 1+stackElementSize
esReference2 = 2+stackElementSize
;
;		Size of return stack.
;
returnStackSize = 256
;
; 		Words required to store the stack position (line address, code address)
;
stackPosSize = 2
;
;		Indent spaces per level
;
indentStep = 2

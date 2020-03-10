; *****************************************************************************
; *****************************************************************************
;
;		Name:		data.asm
;		Purpose:	Basic Data Usage
;		Created:	3rd March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

		org 	FreeMemory
;		
;		R9 		Precedence level
;		R10 	Evaluation stack pointer
; 		R11		Program code pointer.
;
;
		
.initialSP									; stack pointer value on start up.
		fill 	1

.currentLine 								; current line address (address of pointer)
		fill 	1
		
.programCode 								; where the Basic code starts.
		fill 	1		

.endMemory 									; highest memory address for BASIC use (CPU Stack above)
		fill 	1

.memAllocTop								; memory allocated from top
		fill 	1

.memAllocBottom 							; memory allocated from bottom
		fill 	1

.tempStringAlloc 							; allocate interim string
		fill 	1	

;
;		Evaluation stack.
;			+0 	data 	(either pointer to a string, or integer)
;			+1 	type 	(0 if integer, #0 if string)
;			+2 	ref 	(0 if value,#0 if reference)
;	
;	
.evalStack		
		fill 	StackSize * stackElementSize

.fixedVariables								; the 26 permanent variables A-Z
		fill 	26 
		
.variableHashTable							; hash tables for 4 variable types
		fill 	hashTableSize*4

.tokenBuffer 								; tokenisation buffer.
		fill 	256			
;
;							End of interpreter data
;
.endOfData
;
;					We put the basic program on a page boundary
;
freeBasicCode = ramStart + $200

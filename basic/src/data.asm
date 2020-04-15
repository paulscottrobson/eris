; *****************************************************************************
; *****************************************************************************
;
;		Name:		data.asm
;		Purpose:	Basic Data Usage
;		Created:	3rd March 2020
;		Reviewed: 	16th March 2020
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; *****************************************************************************
; *****************************************************************************

		org 	FreeMemory

; *****************************************************************************
;								Stock Register Usage
;		
;		R9 		Precedence level
;		R10 	Evaluation stack pointer
; 		R11		Program code pointer.
;
; *****************************************************************************

; *****************************************************************************
;
;								  Basic Variables
;
; *****************************************************************************
		
.programCode 								; where the Basic code starts.
		fill 	1		

.endMemory 									; highest memory address for BASIC use (CPU Stack above)
		fill 	1

.memAllocTop								; memory allocated from top
		fill 	1

.memAllocBottom 							; memory allocated from bottom
		fill 	1

.returnStackTop 							; top and bottom of return stack
		fill 	1
.returnStackBottom
		fill 	1

.localStackTop 								; top and bottom of local stack
		fill 	1
.localStackBottom
		fill 	1

.initialSP									; stack pointer value on BASIC start up.
		fill 	1

.currentLine 								; current line address (address of pointer)
		fill 	1
		
.procTable 									; list of procedure line addresses, ends with $0000
		fill 	1
		
.tempStringAlloc 							; allocate interim string
		fill 	1	

.localStackPtr 								; local variable/parameter stack pointer
		fill 	1
		
.returnStackPtr 							; return stack pointer
		fill 	1

.lastListToken 								; last listed token (for base conversion)
		fill 	1		

.asmPointer 								; next assembly address
		fill 	1

.asmMode 									; assembler mode bit 0 = Pass bit 1 = List
		fill 	1

.eventSemaphore 							; event semaphore
		fill 	1

.eventCheckTime 							; time of next event check
		fill 	1
		
; *****************************************************************************
;
;		Evaluation stack.
;			+0 	data 	(either pointer to a string, or integer)
;			+1 	type 	(0 if integer, #0 if string)
;			+2 	ref 	(0 if value,#0 if reference)
;	
;	
; *****************************************************************************

.evalStack									; stack for evaluation
		fill 	StackSize * stackElementSize

; *****************************************************************************
;
;							Fixed variables A-Z
;
; *****************************************************************************

.fixedVariables								; the 26 permanent variables A-Z
		fill 	26 

; *****************************************************************************
;
;				   4 Hash table for the 4 type combinations
;
; *****************************************************************************
		
.variableHashTable							; hash tables for 4 variable types
		fill 	hashTableSize*4

; *****************************************************************************
;
;								Event table
;
; *****************************************************************************

.eventTable 								; sets of event records
		fill 	evtCount * evtRecSize

; *****************************************************************************
;
;						Buffer used for tokenising text
;
; *****************************************************************************

.tokenBuffer 								; tokenisation buffer.
		fill 	256
.tokenBufferEnd

; *****************************************************************************
;
;						  Buffer used during INPUT
;
; *****************************************************************************

.inputBuffer	 							; buffer for INPUT
		fill 	(charWidth >> 1)+3	 				
;
;							End of interpreter data
;
.endOfData
;
;					We put the basic program on a page boundary
;
freeBasicCode = ramStart + $300


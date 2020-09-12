;
;	Automatically generated
;
.SyntaxError
jsr	#GenErrorHandler
.SyntaxErrorText
	string "Syntax"
.AssertError
jsr	#GenErrorHandler
.AssertErrorText
	string "Assert"
.MissingBracketError
jsr	#GenErrorHandler
.MissingBracketErrorText
	string "Missing )"
.MissingCommaError
jsr	#GenErrorHandler
.MissingCommaErrorText
	string "Missing ,"
.MissingHashError
jsr	#GenErrorHandler
.MissingHashErrorText
	string "Missing #"
.TypeMismatchError
jsr	#GenErrorHandler
.TypeMismatchErrorText
	string "Wrong type"
.DivideZeroError
jsr	#GenErrorHandler
.DivideZeroErrorText
	string "Division by Zero"
.BadNumberError
jsr	#GenErrorHandler
.BadNumberErrorText
	string "Bad Number"
.BadIndexError
jsr	#GenErrorHandler
.BadIndexErrorText
	string "Bad Index"
.ArrayAutoError
jsr	#GenErrorHandler
.ArrayAutoErrorText
	string "Unknown Array"
.ArrayExistsError
jsr	#GenErrorHandler
.ArrayExistsErrorText
	string "Array exists"
.CallError
jsr	#GenErrorHandler
.CallErrorText
	string "Unknown Procedure"
.StrlenError
jsr	#GenErrorHandler
.StrlenErrorText
	string "String Size"
.LocalParamError
jsr	#GenErrorHandler
.LocalParamErrorText
	string "Parameters or Locals"
.NoAddressError
jsr	#GenErrorHandler
.NoAddressErrorText
	string "Assembler not initialised"
.BadRegisterError
jsr	#GenErrorHandler
.BadRegisterErrorText
	string "Bad CPU Register"
.BadLabelError
jsr	#GenErrorHandler
.BadLabelErrorText
	string "Bad Label"
.NoSpritePlaneError
jsr	#GenErrorHandler
.NoSpritePlaneErrorText
	string "No Sprite Plane"
.SoundQueueError
jsr	#GenErrorHandler
.SoundQueueErrorText
	string "Sound Queue Full"
.StackImbalanceError
jsr	#GenErrorHandler
.StackImbalanceErrorText
	string "RPL Stack imbalance"
.UndefinedVariableError
jsr	#GenErrorHandler
.UndefinedVariableErrorText
	string "Variable unknown"
.StructureError
jsr	#GenErrorHandler
.StructureErrorText
	string "Structures wrong"
.ReturnError
jsr	#GenErrorHandler
.ReturnErrorText
	string "Return without Gosub"
.UntilError
jsr	#GenErrorHandler
.UntilErrorText
	string "Until without Repeat"
.WendError
jsr	#GenErrorHandler
.WendErrorText
	string "Wend without While"
.ElseError
jsr	#GenErrorHandler
.ElseErrorText
	string "Else without If"
.EndIfError
jsr	#GenErrorHandler
.EndIfErrorText
	string "Endif without If"
.EndProcError
jsr	#GenErrorHandler
.EndProcErrorText
	string "EndProc without Proc"
.NextError
jsr	#GenErrorHandler
.NextErrorText
	string "Next without For"
.ReturnStackError
jsr	#GenErrorHandler
.ReturnStackErrorText
	string "Structure too deep"
.LineError
jsr	#GenErrorHandler
.LineErrorText
	string "Line unknown"
.MemoryError
jsr	#GenErrorHandler
.MemoryErrorText
	string "Out of Memory"
.StopError
jsr	#GenErrorHandler
.StopErrorText
	string "Stop"
.TokeniseError
jsr	#GenErrorHandler
.TokeniseErrorText
	string "Cannot process line"
.BreakError
jsr	#GenErrorHandler
.BreakErrorText
	string "Break"
.LoadError
jsr	#GenErrorHandler
.LoadErrorText
	string "No such file"
.SaveError
jsr	#GenErrorHandler
.SaveErrorText
	string "Cannot save"
.SaveNameError
jsr	#GenErrorHandler
.SaveNameErrorText
	string "Bad file name"
.DeleteFileError
jsr	#GenErrorHandler
.DeleteFileErrorText
	string "No such file"
.ReadyWarmStart
jsr	#GenErrorHandler
.ReadyWarmStartText
	string "Ready![0D]"
.BasicLanguage
	string "-uk[0D,0D,12]"

;
;	Automatically generated
;
.SyntaxError
	jsr	#GenErrorHandler
	string	"Syntax"
.AssertError
	jsr	#GenErrorHandler
	string	"Assert"
.MissingBracketError
	jsr	#GenErrorHandler
	string	"Missing )"
.MissingCommaError
	jsr	#GenErrorHandler
	string	"Missing ,"
.TypeMismatchError
	jsr	#GenErrorHandler
	string	"Wrong type"
.DivideZeroError
	jsr	#GenErrorHandler
	string	"Division by Zero"
.BadNumberError
	jsr	#GenErrorHandler
	string	"Bad Number"
.BadIndexError
	jsr	#GenErrorHandler
	string	"Bad Index"
.ArrayAutoError
	jsr	#GenErrorHandler
	string	"Unknown Array"
.ArrayExistsError
	jsr	#GenErrorHandler
	string	"Array exists"
.CallError
	jsr	#GenErrorHandler
	string	"Unknown Procedure"
.StrlenError
	jsr	#GenErrorHandler
	string	"String Size"
.LocalParamError
	jsr	#GenErrorHandler
	string	"Parameters or Locals"
.NoAddressError
	jsr	#GenErrorHandler
	string	"Assembler not initialised"
.StructureError
	jsr	#GenErrorHandler
	string	"Structures wrong"
.ReturnError
	jsr	#GenErrorHandler
	string	"Return without Gosub"
.UntilError
	jsr	#GenErrorHandler
	string	"Until without Repeat"
.WendError
	jsr	#GenErrorHandler
	string	"Wend without While"
.ElseError
	jsr	#GenErrorHandler
	string	"Else without If"
.EndIfError
	jsr	#GenErrorHandler
	string	"Endif without If"
.EndProcError
	jsr	#GenErrorHandler
	string	"EndProc without Proc"
.NextError
	jsr	#GenErrorHandler
	string	"Next without For"
.ReturnStackError
	jsr	#GenErrorHandler
	string	"Structure too deep"
.LineError
	jsr	#GenErrorHandler
	string	"Line unknown"
.MemoryError
	jsr	#GenErrorHandler
	string	"Out of Memory"
.StopError
	jsr	#GenErrorHandler
	string	"Stop"
.TokeniseError
	jsr	#GenErrorHandler
	string	"Cannot process line"
.BreakError
	jsr	#GenErrorHandler
	string	"Break"
.LoadError
	jsr	#GenErrorHandler
	string	"No such file"
.SaveError
	jsr	#GenErrorHandler
	string	"Cannot save"
.SaveNameError
	jsr	#GenErrorHandler
	string	"Bad file name"
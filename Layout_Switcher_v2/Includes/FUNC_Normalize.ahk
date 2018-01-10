Normalize(ByRef VarName, ByRef Value := 0)
{
	%VarName% := %VarName% ? %VarName% : Value
}

IniWrite( ByRef Key, ByRef File, ByRef Section, ByRef Value )
{ ; ������ ������������ IniWrite (���������� ������ ���������� ���������)
	If ( not File ) {
		Return
	}
	Value := Value = "ERROR" ? "" : Value
	IniRead, Test_Value, %File%, %Section%, %Key%
	If ( not Test_Value = Value ) {
		IniWrite, %Value%, %File%, %Section%, %Key%
	}
}


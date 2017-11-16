IniWrite(ByRef Key, ByRef File, ByRef Section, ByRef Value)
{ ; замена стандартонго IniWrite (записывает только измененные параметры)
	static Test_Value
	;
	if (not File) {
		return
	}
	Value := Value = "ERROR" ? "" : Value
	IniRead Test_Value, %File%, %Section%, %Key%
	if (not Test_Value = Value) {
		IniWrite %Value%, %File%, %Section%, %Key%
	}
}

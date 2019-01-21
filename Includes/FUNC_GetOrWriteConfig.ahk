GetOrWriteConfig(ConfigFile, SectionName := "", KeyName := "", DefaultValue := "")
{
	local
	if (SectionName and KeyName) {
		IniRead, Ret, %ConfigFile%, %SectionName%, %KeyName%, %A_Space%
		if (Ret = "") {
			IniWrite, %DefaultValue%, %ConfigFile%, %SectionName%, %KeyName%
			Ret := DefaultValue
		}
		return Ret
	}
	if (SectionName) {
		IniRead, Ret, %ConfigFile%, %SectionName%
		if (Ret = "") {
			IniWrite, %DefaultValue%, %ConfigFile%, %SectionName%
			Ret := DefaultValue
		}
		return Ret
	}
	else {
		IniRead, Ret, %ConfigFile%,
	}
	return
}

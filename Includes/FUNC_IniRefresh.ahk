IniRefresh(file, value, section, key := "")
{ ; замена стандартного IniWrite (записывает только измененные параметры)
	local
	if (not file) {
		return
	}
	;
	if (key == "") {
		IniRead, testValue, %file%, %section%
		if (testValue != value) {
			IniDelete, %file%, %section%
			IniWrite, %value%, %file%, %section%
		}
	}
	else {
		value := (value == "ERROR") ? "" : value
		IniRead, testValue, %file%, %section%, %key%
		if (testValue != value) {
			IniWrite, %value%, %file%, %section%, %key%
		}
	}
}

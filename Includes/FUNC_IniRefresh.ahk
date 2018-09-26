IniRefresh(file, value, section, key := "")
{ ; замена стандартного IniWrite (записывает только измененные параметры)
	if (not file) {
		return
	}
	;
	static testValue
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

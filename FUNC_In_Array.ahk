In_Array(Array, Value)
{ ; функция проверки наличия значения во множестве
	static k, v
	;
	if (not isObject(Array)) {
		return False
	}
	if (Array.Length() == 0) {
		return False
	}
	for k, v in Array {
		if (v == Value) {
			return True
		}
	}
	return False
}

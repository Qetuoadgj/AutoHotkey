ArrayGetIndex(Array, Value) {
	static k, v
	if (not isObject(Array)) {
		return
	}
	if (Array.Length() == 0) {
		return
	}
	for k, v in Array {
		if (v = Value) {
			return k
		}
	}
}

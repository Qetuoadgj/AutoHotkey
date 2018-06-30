ObjLen(Obj)
{ ; возвращает длину (кол-во ключей) Object (замена Object.MaxIndex())
	static k,v,l
	for k, v in Obj {
		l := A_Index
	}
	return l
}
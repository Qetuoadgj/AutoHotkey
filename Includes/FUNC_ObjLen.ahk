ObjLen(Obj)
{ ; возвращает длину (кол-во ключей) Object (замена Object.MaxIndex())
	local
	for k, v in Obj {
		l := A_Index
	}
	return l
}
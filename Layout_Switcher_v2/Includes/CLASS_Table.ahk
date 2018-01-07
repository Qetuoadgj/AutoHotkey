class Table
{
	Get_Key_Index(ByRef Table, ByRef Key_Name)
	{ ; функция получения порядкового номера ключа по его имени
		static Key, Index
		;
		if not isObject(Table) {
			return
		}
		for Key in Table {
			if (Key = Key_Name) {
				return A_Index
			}
		}
		for Index, Key in Table {
			if (Key = Key_Name) {
				return A_Index
			}
		}
	}
	
	Get_Key_Name(ByRef Table, ByRef Index)
	{ ; функция получения имени ключа словаря по порядковому номеру
		static Key
		;
		if not isObject(Table) {
			return
		}
		for Key in Table {
			if (A_Index = Index) {
				return Key
			}
		}
	}
	
	Max_Index(ByRef Table)
	{
		static Key, Index
		;
		if not isObject(Table) {
			return
		}
		for Key in Table {
			Index := A_Index
		}
		return Index
	}
}

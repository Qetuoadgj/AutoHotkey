class Table
{
	Get_Key_Index(Table, Key_Name)
	{ ; функция получения порядкового номера ключа по его имени
		local
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
	
	Get_Key_Name(Table, Index)
	{ ; функция получения имени ключа словаря по порядковому номеру
		local
		if not isObject(Table) {
			return
		}
		for Key in Table {
			if (A_Index = Index) {
				return Key
			}
		}
	}
	
	Max_Index(Table)
	{
		local
		if not isObject(Table) {
			return
		}
		for Key in Table {
			Index := A_Index
		}
		return Index
	}
}

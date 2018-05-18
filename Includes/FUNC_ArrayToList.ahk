ArrayToList(Array, Delimiter := "`n")
{
	static List, Index, Value
	List := ""
	for Index, Value in Array
	{
		List .= Value . "`n"
	}
	List := Trim(List, " `t`r`n")
	return List
}

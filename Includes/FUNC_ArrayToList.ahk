ArrayToList(Array, Delimiter := "`n")
{
	local
	List := ""
	for Index, Value in Array
	{
		List .= Value . "`n"
	}
	List := Trim(List, " `t`r`n")
	return List
}

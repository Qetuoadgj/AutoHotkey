ArrayConcat(Arrays*) {
	local
	Ret := []
	for Index, Array in Arrays
	{
		for Index, Element in Array
		{
			Ret.Push(Element)
		}
	}
	return Ret
}

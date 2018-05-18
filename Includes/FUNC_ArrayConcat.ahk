ArrayConcat(Arrays) {
	static Ret, Index, Array, Element
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

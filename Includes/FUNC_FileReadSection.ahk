FileReadSection(SourceFile, StartString, EndString = "", SkipComments := 1, CommentPattern := "^(\s+)?;", SkipEmptyLines := 1)
{ ; ������� ��� "���������" ����� ������ �� ����� (������������� �� �������� ���������� � ��������� ������, ���� �� ���������� ������ � ��������� ������ �����)
	local
	StartLine := 0, EndLine := 0, CurrentLine := 0
	SectionContains := ""
	Loop, Read, %SourceFile%
	{
		if RegExMatch(A_LoopReadLine, StartString) {
			StartLine := A_Index
		}
	}
	Loop, Read, %SourceFile%
	{
		if RegExMatch(A_LoopReadLine, EndString) && (not EndString = "") && (A_Index > StartLine)
		{
			EndLine := A_Index
			break
		}
		else {
			EndLine := A_Index + 1
		}
	}
	Loop, Read, %SourceFile%
	{
		If (SkipEmptyLines) {
			if (Trim(A_LoopReadLine) = "") { ; if looped line is empty
				continue ; skip the current Loop instance
			}
		}
		If (SkipComments) {
			If RegExMatch(A_LoopReadLine, CommentPattern) { ; if looped line is commented
				continue ; skip the current Loop instance
			}
		}
		CurrentLine := A_Index
		If (CurrentLine > StartLine) && (CurrentLine < EndLine) {
			SectionContains .= A_LoopReadLine . "`n"
		}
	}
	SectionContains := RegExReplace(SectionContains, "\s+$", "") ; ������� ��������� ������ ������ (�� ������ ������)
	return SectionContains
}

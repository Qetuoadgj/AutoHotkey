TrimPath(GivenPath)
{ ; ������� �������� ������ �������� �� �����
	GivenPath := StrReplace(GivenPath, """", "") ; �������� ������� �� ����
	GivenPath := RegExReplace(GivenPath, "[\\+]$", "", ,1) ; �������� ����������� ����� �� ����
	GivenPath := RegExReplace(GivenPath, "^[\\+]", "", ,1) ; �������� ��������������� ����� �� ����
	Return %GivenPath%
}

FileGetLongPath(GivenPath)
{ ; ������� ��������� ������� ���� � �����
	GivenPath := TrimPath(GivenPath)
	IfExist, %GivenPath%
	{
		Loop, %GivenPath%, 1
		{
			return %A_LoopFileLongPath%
		}
	}
	else {
		return %GivenPath%
	}
}

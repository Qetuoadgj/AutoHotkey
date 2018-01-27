IniRead(Filename, Section := "", Key := "", Default := "ERROR")
{ ; ������ ������������ IniRead
	static Match, Match1, Match2
	static SectionContains, LineText, KeyName, KeyValue, SectionsList, SectionName
	if (Section) { ; ������ �������
		SectionContains := FileReadSection(Filename, "\[" . Section . "\]", "^\[.*?\]", 1, "^(\s+)?[;#]", 1) ; ��������� ����������� ��������� ������
		if (Key) { ; ������ ����
			Loop, Parse, SectionContains, `n, `r
			{ ; ����� ������� ����� � ��������� ������
				LineText := Trim(A_LoopField)
				if RegExMatch(LineText, "^(.*?)[ \t]?+=[ \t]?+(.*)$", Match) { ; ������ �����-�� ���� �� ���������
					KeyName := Match1 ; ��� ����
					KeyValue := StrLen(Match2) > 0 ? Match2 : Default ; ������������� �������� �����
					if (KeyName = Key) { ; ������ ����, ������� �� ������
						; return KeyValue ? KeyValue : KeyName ; ���������� �������� �����, ���� ��� ����, ���� �������� ��� - ���������� ��� ����
						return KeyValue ; ���������� �������� �����
					}
				}
				if (LineText = Key) { ; ������ ���� ��� ����� ��������� (������� �����), ���������� � ������� ������
					return LineText ; ���������� ���� � ���� ������ (��� ����� ��������� � ��������)
				}
			}
			return ; �� ������ ������� ���� - ���������� "������" ��������
		}
		return SectionContains ; ���� �� ��� ������, ���������� ���������� ���� ������
	}
	else { ; ������ �� ���� �������
		SectionsList := "" ; ������ "������" �������� ��� �������� ������ ������
		Loop, Read, %Filename%
		{ ; ���� � ����� "������", ��������� ������ RegEx
			if RegExMatch(Trim(A_LoopReadLine), "^\[(.*?)\]$", Match) { ; �� ������� ������� ������
				SectionName := Match1 ; �������� ��� ������
				SectionsList .= SectionName . "`n" ; ��������� ��� � ������ ������
			}
		}
		SectionsList := RegExReplace(SectionsList, "\s+$", "") ; ������� ��������� ������ ������ (�� ������ ������)
		return SectionsList ; ���������� ������ ������
	}
}

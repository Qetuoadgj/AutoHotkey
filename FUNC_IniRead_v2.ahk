IniRead(Filename, Section := "", Key := "", Default := "ERROR")
{ ; замена стандартного IniRead
	static Match, Match1, Match2
	static SectionContains, LineText, KeyName, KeyValue, SectionsList, SectionName
	if (Section) { ; секция указана
		SectionContains := FileReadSection(Filename, "\[" . Section . "\]", "^\[.*?\]", 1, "^(\s+)?[;#]", 1) ; получение содержимого указанной секции
		if (Key) { ; указан ключ
			Loop, Parse, SectionContains, `n, `r
			{ ; поиск нужного ключа в указанной секции
				LineText := Trim(A_LoopField)
				if RegExMatch(LineText, "^(.*?)[ \t]?+=[ \t]?+(.*)$", Match) { ; найден какой-то ключ со значением
					KeyName := Match1 ; сам ключ
					KeyValue := StrLen(Match2) > 0 ? Match2 : Default ; устанавливаем значение ключа
					if (KeyName = Key) { ; найден ключ, который мы искали
						; return KeyValue ? KeyValue : KeyName ; возвращаем значение ключа, если оно есть, если значения нет - возвращаем сам ключ
						return KeyValue ; возвращаем значение ключа
					}
				}
				if (LineText = Key) { ; найден ключ без знака равенства (обычный текст), сопадающий с искомым ключем
					return LineText ; возвращаем ключ в виде текста (без знака равенства и значения)
				}
			}
			return ; не найден искомый ключ - возвращаем "пустое" значение
		}
		return SectionContains ; ключ не был указан, возвращаем содержимое всей секции
	}
	else { ; секция не была указана
		SectionsList := "" ; задаем "пустое" значения для будущего списка секций
		Loop, Read, %Filename%
		{ ; ищем в файле "секции", используя шаблон RegEx
			if RegExMatch(Trim(A_LoopReadLine), "^\[(.*?)\]$", Match) { ; по шаблону найдена секция
				SectionName := Match1 ; получаем имя секции
				SectionsList .= SectionName . "`n" ; добавляем имя в список секций
			}
		}
		SectionsList := RegExReplace(SectionsList, "\s+$", "") ; удаляем последние пустые строки (на всякий случай)
		return SectionsList ; возвращаеи список секций
	}
}

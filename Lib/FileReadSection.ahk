; ===================================================================================
;                       ФУНКЦИЯ ЧТЕНИЯ ЗАДАННОЙ СЕКЦИИ ФАЙЛА
; ===================================================================================
FileReadSection(SourceFile, StartString, EndString = "", SkipComments := 1, SkipEmptyLines := 1)
{
  SectionArray := Object()

  Loop, Read, %SourceFile%
  {
    IfInString, A_LoopReadLine, %StartString%
    {
      StartLine:=A_Index
    }
  }

  Loop, Read, %SourceFile%
  {
    If RegExMatch(A_LoopReadLine, EndString) && not EndString = "" && A_Index > StartLine
    {
      EndLine:=A_Index
      Break
    } else {
      EndLine:=A_Index + 1
    }
  }

  Loop, Read, %SourceFile%
  {
    If % SkipEmptyLines = 1
    {
      If A_LoopReadLine = ; if looped line is empty
      Continue ; skip the current Loop instance
    }
    If % SkipComments = 1
    {
      If RegExMatch(A_LoopReadLine, "^(\s+)?;") ; if looped line is commented
        Continue ; skip the current Loop instance

      If RegExMatch(A_LoopReadLine, "^(\s+)?//") ; if looped line is commented
        Continue ; skip the current Loop instance
    }

    CurrentLine:=A_Index
    If (CurrentLine > StartLine) && (CurrentLine < EndLine)
    {
      ; CurrentString := ExpandEnvironmentStrings(A_LoopReadLine)
      ; SectionArray.Push(CurrentString)
      SectionArray.Push(A_LoopReadLine)
    }
  }

  Return SectionArray
}

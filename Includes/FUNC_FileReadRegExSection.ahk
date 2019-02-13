FileReadRegExSection(FilePath, SectionStartRegExp, SectionEndRegExp, NewLine := "`r`n", SkipSectionStartLine := 0, ByRef SectionStartLine := 0, ByRef SectionEndLine := 0)
{ ; FoldersList := FileReadRegExSection(ConfigFile, "i)^\[FoldersList\]", "^\[", "`r`n", 1, SectionStartLine, SectionEndLine)
	local
	SectionStartLine := 0, SectionEndLine := 0
	FoldersList := ""
	Loop, Read, %FilePath%
	{
		if (SectionStartLine) {
			SectionEndLine := A_Index
			if RegExMatch(Trim(A_LoopReadLine), SectionEndRegExp) {
				SectionEndLine--
				break
			}
		}
		else if RegExMatch(Trim(A_LoopReadLine), SectionStartRegExp) {
			SectionStartLine := A_Index
		}
	}
	SectionStartLine := Min(SectionStartLine, SectionEndLine)
	SectionStartLine := (SectionStartLine and SkipSectionStartLine) ? SectionStartLine + 1 : SectionStartLine
	SectionText := ""
	Loop, Read, %FilePath%
	{
		if ((A_Index >= SectionStartLine) and (A_Index <= SectionEndLine)) {
			SectionText .= RTrim(A_LoopReadLine) . NewLine
		}
	}
	; SectionText := RTrim(SectionText, NewLine)
	return SectionText
}

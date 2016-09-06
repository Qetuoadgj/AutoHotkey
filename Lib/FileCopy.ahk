; ===================================================================================
; 		 ФУНКЦИЯ КОПИРОВАНИЯ ФАЙЛОВ С АВТОМАТИЧЕСКИМ СОЗДАНИЕМ НЕОБХОДИМЫХ ПАПОК
; ===================================================================================
FileCopy(SourcePattern, DestPattern, Flag = 0)
{
	IfNotExist,% SourcePattern
		return -1
	SplitPath, DestPattern, , OutDir
	IfNotExist, OutDir
	{
		FileCreateDir,% OutDir
		if ErrorLevel
			return -2
	}
  FileCopyDir,% SourcePattern,% DestPattern,% Flag
	FileCopy,% SourcePattern,% DestPattern,% Flag
	return ErrorLevel
}

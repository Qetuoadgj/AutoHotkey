PlaySound(ByRef Sound)
{ ; //autohotkey.com/board/topic/29541-preload-files-into-memory-for-fast-access/?p=188741
	return DllCall("winmm.dll\PlaySound" (A_IsUnicode ? "W" : "A"), UInt, &Sound, UInt, 0, UInt, ((SND_MEMORY := 0x4) | (SND_NODEFAULT := 0x2) | (SND_ASYNC := 0x1)))
}
/*
	PlaySound - позволяет проигрывать звуковые файлы прямо из переменной.
	На пример:
	FileRead, MySound, *c C:\MySound.WAV	; Сохраняет звуковой файл в переменную
	PlaySound(MySound)						; Проигрывает переменную
*/

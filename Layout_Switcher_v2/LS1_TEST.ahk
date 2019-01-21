#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn, All, MsgBox ; Enable warnings to assist with detecting common errors.
SendMode, Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir, %A_ScriptDir% ; Ensures a consistent starting directory.

#Warn, ClassOverwrite, Off

#Persistent
; #SingleInstance, Ignore

Script_Name := A_ScriptName

#SingleInstance, Off
Script_PID := DllCall("GetCurrentProcessId")

gosub, Maximize_Script_Performance
gosub, Init_Script
gosub, Init_MsgMonitor
gosub, ForceSingleInstance

Hotkey, Numpad0, Sub_Get_Word, B0

OnExit, Exit_Script
return

Sub_Get_Word:
{
	gosub, Clipboard_Save
	gosub, Text_Select
	gosub, Clipboard_Restore
	return
}

Clipboard_Save:
{ ; рутина сохранения текущего буфера обмена в переменную Clipboard_Image
	Clipboard_Image := ""									; очищаем переменную Clipboard_Image
	Clipboard_Image := ClipboardAll							; сохраняем двоичные данные из буфера обмена в переменную Clipboard_Image
	return
}

Clipboard_Restore:
{ ; рутина восстановления буфера обмена из переменной Clipboard_Image. (Требует предварительного запуска рутины Clipboard_Save)
	Clipboard := ""											; очищаем буфер обмена
	Clipboard := Clipboard_Image							; помещаем в буфер обмена двоичные данные из переменной Clipboard_Image
	ClipWait, 1.0, 0										; ждем пока данные передадутся в буфер обмена
	VarSetCapacity(Clipboard_Image, 0)						; удаляем переменную Clipboard_Image из памяти
	return
}

Text_Copy_To_Clipboard:
{ ; рутина сохранения выделенного текста в переменную Selected_Text
	Clipboard := ""											; очищаем буфер обмена
	SendInput, ^c											; нажимаем Ctrl+C
	ClipWait, 0.05, 0										; ждем пока данные передадутся в буфер обмена
	Selected_Text := Clipboard								; сохраняем текстовые данные из буфера обмена в переменную Selected_Text
	;
	ToolTip, Selected_Text:`n"%Selected_Text%"
	return
}

Text_Select:
{ ; рутина выделения ближайшего (слева от курсора) "слова" с сохранением его в переменную Selected_Text
	Selected_Text := ""										; "опустошаем" переменную Selected_Text
	gosub, Text_Copy_To_Clipboard							; сохраняем выделенный текст в переменную Selected_Text
	if (Selected_Text == "")								; если переменная Selected_Text осталась пустой
	{ 														; пытаемся выделить ближайшее (слева от курсора) слово
		Loop, 50											; делаем много циклов выделения "влево" (до начала текста или ближайшего пробела)
		{
			SendInput, ^+{Left}								; выполняем продвижение на одно "выделение" влево (Ctrl+Shift+Left)
			;
			Selected_Text_Len := StrLen(Selected_Text)		; получаем длину текущего текста (для последующего сравнения)
			gosub, Text_Copy_To_Clipboard					; еще раз копируем текст в переменную Selected_Text
			if (Selected_Text_Len == StrLen(Selected_Text)) ; если дины текущего и ранее выделенного текста совпадают, то:
			{												; достигнуто начало текста
				VarSetCapacity(Selected_Text_Len, 0)		; удаляем переменную Selected_Text_Len из памяти
				break										; прекращаем дальнейшее выделение
			}
			if RegExMatch(Selected_Text, "\s")				; если в выделение попал пробел, то:
			{												; достигнут пробел перед словом
				SendInput, ^+{Right}						; выполняем возврат на одно "выделение" вправо (Ctrl+Shift+Right)
				gosub, Text_Copy_To_Clipboard				; еще раз копируем текст в переменную Selected_Text
				break										; прекращаем дальнейшее выделение
			}
		}
	}
	return
}

Init_Script:
{
	MsgBox, 262144, %Script_Name%, Script_PID: %Script_PID%, 1
	Clipboard := Script_PID
	return
}

Exit_Script:
{
	MsgBox, 262144, %Script_Name%, OK, 1
	ExitApp
	return
}

Maximize_Script_Performance:
{
	#MaxThreads
	SetBatchLines, -1
	return
}

Init_MsgMonitor:
{
	OnMessage(0x5555, "MsgMonitor")								; запуск отслеживания входящих сообщений Post/SendMessage (с кодом 0x5555)
	MsgMonitor(wParam, lParam, msg)
	{ ; функция, которая срабатывает при получении программой сообщениий Post/SendMessage
		if (wParam == 10)										; если wParam равен 10
		{														; выполняем следующие действия:
			if (lParam == 1)									; при lParam равном 1
			{
				; MsgBox, lParam = %lParam% (ExitApp)
				ExitApp										; выполненяем завершение (выход из) скрипта
			}
			else if (lParam == 2)								; при lParam равном 2
			{
				; MsgBox, lParam = %lParam% (Reload)
				Reload											; выполненяем завершение и перезапуск скрипта 
			}
			else
			{
				; MsgBox, lParam = %lParam% (ToolTip)
				ToolTip, Message %msg% arrived:`nWPARAM: %wParam%`nLPARAM: %lParam%
			}
		}
		else
		{
			ToolTip, Message %msg% arrived:`nWPARAM: %wParam%`nLPARAM: %lParam%
		}
	}
	return
}

ForceSingleInstance:
{
	A_DetectHiddenWindows_tmp := A_DetectHiddenWindows
	#SingleInstance, Off
	DetectHiddenWindows, On
	Script_Name := RegExReplace(A_ScriptName, "^(.*)\.(.*)$", "$1")
	App_Full_Path := A_ScriptDir . "\" . Script_Name
	App_Full_Path := App_Full_Path ? App_Full_Path : A_ScriptFullPath . " ahk_class AutoHotkey"
	WinGet, Current_ID, ID, % A_ScriptFullPath . " ahk_class AutoHotkey"
	WinGet, Current_PID, PID, % A_ScriptFullPath . " ahk_class AutoHotkey"
	WinGet, Process_List, List, % App_Full_Path . " ahk_class AutoHotkey"
	Loop, %Process_List%
	{
		Process_ID := Process_List%A_Index%
		if (Process_ID = Current_ID) {
			continue
		}
		WinGet, Process_PID, PID, % App_Full_Path . " ahk_id " . Process_ID
		PostMessage, 0x5555, 10, 1,, ahk_pid %Process_PID% ; The message is sent  to the "last found window" due to WinExist() above.
	}	
	DetectHiddenWindows, %A_DetectHiddenWindows_tmp%
	return
}

; #Include D:\Google Диск\AutoHotkey\Includes\CLASS_Script.ahk

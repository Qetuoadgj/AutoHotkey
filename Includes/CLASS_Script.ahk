class Script
{ ; функции управления скриптом

	Force_Single_Instance(File_Names := false)
	{ ; функция автоматического завершения всех копий текущего скрипта (одновременно для .exe и .ahk)
		static Detect_Hidden_Windows_Tmp
		static File_Name, Index
		static Script_Name, App_Full_Path
		;
		Detect_Hidden_Windows_Tmp := A_DetectHiddenWindows
		#SingleInstance, Off
		DetectHiddenWindows, On
		Script_Name := RegExReplace(A_ScriptName, "^(.*)\.(.*)$", "$1")
		File_Names := File_Names ? File_Names : [ Script_Name . ".exe", Script_Name . ".ahk" ]
		for Index, File_Name in File_Names {
			App_Full_Path := A_ScriptDir . "\" . File_Name
			This.Close_Other_Instances(App_Full_Path . "ahk_class AutoHotkey")
		}
		DetectHiddenWindows, % Detect_Hidden_Windows_Tmp
	}
	
	Close_Process(Process_PID)
	{ ; функция завершения процесса с вызовом сабрутины OnExit
		static DHW
		DHW := A_DetectHiddenWindows
		DetectHiddenWindows, On
		try {
			; WinClose, ahk_pid %Confirmed_PID%
			; WinGet, ID, ID, ahk_pid %Confirmed_PID%
			PostMessage, 0x111, 65405, 0,, ahk_pid %Process_PID%
		}
		catch {
			Process, Close, %Process_PID%
		}
		DetectHiddenWindows, %DHW%
		return
	}

	Close_Other_Instances(App_Full_Path)
	{ ; функция завершения всех копий текущего скрипта (только для указанного файла)
		static Current_ID, Process_List, Process_Count, Process_ID, Process_PID
		;
		App_Full_Path := App_Full_Path ? App_Full_Path : A_ScriptFullPath . " ahk_class AutoHotkey"
		WinGet, Current_ID, ID, % A_ScriptFullPath . " ahk_class AutoHotkey"
		WinGet, Process_List, List, % App_Full_Path . " ahk_class AutoHotkey"
		Process_Count := 1
		Loop, %Process_List%
		{
			Process_ID := Process_List%Process_Count%
			if (not Process_ID = Current_ID) {
				WinGet, Process_PID, PID, % App_Full_Path . " ahk_id " . Process_ID
				; Process, Close, %Process_PID%
				This.Close_Process(Process_PID)
			}
			Process_Count += 1
		}
	}

	Run_As_Admin(Params := "")
	{ ; функция запуска скрипта с правами администратора
		if (not A_IsAdmin) {
			try {
				Run, *RunAs "%A_ScriptFullPath%" %Params%
			}
			ExitApp
		}
	}

	Name()
	{ ; функция получения имени текущего скрипта
		static Name
		;
		SplitPath, A_ScriptFullPath,,,, Name
		return Name
	}

	Args()
	{ ; функция получения аргументов коммандной строки в виде текста
		static ret
		ret := ""
		
		static n, param
		for n, param in A_Args
		{
			ret .= " " param
		}
		ret := Trim(ret)
		return ret
	}
	
	InArgs(Arg)
	{ ; функция получения аргументов коммандной строки в виде текста
		static n, param
		for n, param in A_Args
		{
			param := Trim(param)
			if (param = Arg) {
				return n
			}
		}
		return
	}
}

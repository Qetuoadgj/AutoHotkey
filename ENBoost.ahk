#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn, All ; Enable warnings to assist with detecting common errors.
SendMode, Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir, %A_ScriptDir% ; Ensures a consistent starting directory.

#SingleInstance Force

; Your code here...
Start:
{
	; gosub Create_Vars
	gosub, Set_Values
	; gosub Get_Config_Framework
	gosub, Get_Config
}

Exit

q(s)
{
	s = "%s%"
	return s
}

Create_Vars:
{
	enblocal_ini := "D:\Games\Oblivion\enblocal.ini"
	; output := "ini := {}" . "`n"
	IniRead, ini_sections, % enblocal_ini
	Loop, Parse, % ini_sections, `n, `r
	{
		section_name := A_LoopField
		; output .= ";`n" . "ini." . section_name . " := {}" . "`n"
		IniRead, section_keys, % enblocal_ini, % section_name
		Loop, Parse, % section_keys, `n, `r
		{
			key := Trim(RegExReplace(A_LoopField, "=.*", ""))
			IniRead, value, % enblocal_ini, % section_name, % key
			output .= "ini_" . section_name . "_" . key . " := " . q(value) . "`n"
		}
	}
	MsgBox, % output
	return
}

Get_Video_Memory:
{
	OSWindowsVersion := SubStr(A_OSVersion, 5)
	VideoMemorySize := Round(GetVideoMemorySize() / 1024**2)
	InstalledSystemMemory := Round(GetPhysicallyInstalledSystemMemory() / 1024)
	MsgBox, 68,, % "Video Adapter Memory = " . VideoMemorySize . " MB" . "`n"
	. "Installed Memory (RAM) = " . InstalledSystemMemory . " MB" . "`n"
	IfMsgBox, No
	{
		InputBox, VideoMemorySizeCustom,,,,, 100
		if (StrLen(Trim(VideoMemorySize)) > 0) {
			VideoMemorySize := VideoMemorySizeCustom
		}
		MsgBox, 68,, % "Video Adapter Memory = " . VideoMemorySize . " MB" . "`n"
		. "Installed Memory (RAM) = " . InstalledSystemMemory . " MB" . "`n"
		IfMsgBox, No
		{
			gosub, %A_ThisLabel%
		}
	}
	
	ENB_ReservedMemorySizeMb := Round(VideoMemorySize / 8)
	ENB_VideoMemorySizeMb := !A_Is64bitOS or (A_Is64bitOS && VideoMemorySize <= 1024*8)
	? Round(VideoMemorySize + InstalledSystemMemory - 2048)
	: VideoMemorySize - (OSWindowsVersion >= 8 ? 350 : 170) ; https://www.youtube.com/watch?v=zYgFihHMD4w
	
	MsgBox, % ""
	. "OSWindowsVersion = " . OSWindowsVersion . "`n"
	. "ENB_ReservedMemorySizeMb = " . ENB_ReservedMemorySizeMb . "`n"
	. "ENB_VideoMemorySizeMb = " . ENB_VideoMemorySizeMb . "`n"
	return
}

Set_Values:
{
	gosub, Get_Video_Memory
	;
	ini_PROXY_EnableProxyLibrary := "false"
	ini_PROXY_InitProxyFunctions := "true"
	ini_PROXY_ProxyLibrary := "other_d3d9.dll"
	;
	ini_MULTIHEAD_ForceVideoAdapterIndex := "false"
	ini_MULTIHEAD_VideoAdapterIndex := "0"
	;
	ini_MEMORY_ExpandSystemMemoryX64 := A_Is64bitOS ? "true" : "false"
	ini_MEMORY_ReduceSystemMemoryUsage := "true"
	ini_MEMORY_DisableDriverMemoryManager := "false" ;"true"
	ini_MEMORY_DisablePreloadToVRAM := "false"
	ini_MEMORY_EnableUnsafeMemoryHacks := A_Is64bitOS ? "false" : "true"
	ini_MEMORY_ReservedMemorySizeMb := ENB_ReservedMemorySizeMb ; "256"
	ini_MEMORY_VideoMemorySizeMb := ENB_VideoMemorySizeMb
	ini_MEMORY_EnableCompression := "true" ;"false"
	;
	ini_WINDOW_ForceBorderless := "false"
	ini_WINDOW_ForceBorderlessFullscreen := "false"
	;
	ini_ENGINE_ForceAnisotropicFiltering := "true"
	ini_ENGINE_MaxAnisotropy := "2"
	ini_ENGINE_AddDisplaySuperSamplingResolutions := "false"
	;
	ini_LIMITER_WaitBusyRenderer := "false"
	ini_LIMITER_EnableFPSLimit := "false"
	ini_LIMITER_FPSLimit := "60"
	;
	ini_INPUT_KeyFPSLimit := "36"
	ini_INPUT_KeyShowFPS := "106"
	ini_INPUT_KeyScreenshot := "44"
	ini_INPUT_KeyFreeVRAM := "115"
	;
	return
}

Get_Config_Framework:
{
	output := "", enblocal_ini := "D:\Games\Oblivion\enblocal.ini"
	IniRead, ini_sections, % enblocal_ini
	Loop, Parse, % ini_sections, `n, `r
	{
		section_name := A_LoopField
		output .= "`n" . "[" . section_name . "]" . "`n"
		IniRead, section_keys, % enblocal_ini, % section_name
		Loop, Parse, % section_keys, `n, `r
		{
			key := Trim(RegExReplace(A_LoopField, "=.*", ""))
			; IniRead value, % enblocal_ini, % section_name, % key
			output .= key . "=" . "%ini_" . section_name . "_" . key . "%" . "`n"
		}
	}
	MsgBox, % output
	return
}

Get_Config:
{
	out =
	( LTrim RTrim Join`r`n
	[PROXY]
	EnableProxyLibrary=%ini_PROXY_EnableProxyLibrary%
	InitProxyFunctions=%ini_PROXY_InitProxyFunctions%
	ProxyLibrary=%ini_PROXY_ProxyLibrary%
	
	[MULTIHEAD]
	ForceVideoAdapterIndex=%ini_MULTIHEAD_ForceVideoAdapterIndex%
	VideoAdapterIndex=%ini_MULTIHEAD_VideoAdapterIndex%
	
	[MEMORY]
	ExpandSystemMemoryX64=%ini_MEMORY_ExpandSystemMemoryX64%
	ReduceSystemMemoryUsage=%ini_MEMORY_ReduceSystemMemoryUsage%
	DisableDriverMemoryManager=%ini_MEMORY_DisableDriverMemoryManager%
	DisablePreloadToVRAM=%ini_MEMORY_DisablePreloadToVRAM%
	EnableUnsafeMemoryHacks=%ini_MEMORY_EnableUnsafeMemoryHacks%
	ReservedMemorySizeMb=%ini_MEMORY_ReservedMemorySizeMb%
	VideoMemorySizeMb=%ini_MEMORY_VideoMemorySizeMb%
	EnableCompression=%ini_MEMORY_EnableCompression%
	
	[WINDOW]
	ForceBorderless=%ini_WINDOW_ForceBorderless%
	ForceBorderlessFullscreen=%ini_WINDOW_ForceBorderlessFullscreen%
	
	[ENGINE]
	ForceAnisotropicFiltering=%ini_ENGINE_ForceAnisotropicFiltering%
	MaxAnisotropy=%ini_ENGINE_MaxAnisotropy%
	AddDisplaySuperSamplingResolutions=%ini_ENGINE_AddDisplaySuperSamplingResolutions%
	
	[LIMITER]
	WaitBusyRenderer=%ini_LIMITER_WaitBusyRenderer%
	EnableFPSLimit=%ini_LIMITER_EnableFPSLimit%
	FPSLimit=%ini_LIMITER_FPSLimit%
	
	[INPUT]
	KeyFPSLimit=%ini_INPUT_KeyFPSLimit%
	KeyShowFPS=%ini_INPUT_KeyShowFPS%
	KeyScreenshot=%ini_INPUT_KeyScreenshot%
	KeyFreeVRAM=%ini_INPUT_KeyFreeVRAM%
	
	)
	MsgBox, 4,, % out ;, 1
	IfMsgBox, Yes
	{
		Clipboard := ""
		Sleep, 1
		Clipboard := out
		ClipWait, 1
		ExitApp
	}
	else {
		gosub, Start
	}
	return
}

GetPhysicallyInstalledSystemMemory()
{
	static TotalMemory
	TotalMemory = 0
    if not DllCall("kernel32.dll\GetPhysicallyInstalledSystemMemory", "UInt64*", TotalMemory) {
        return DllCall("kernel32.dll\GetLastError")
	}
    return TotalMemory
}

GetVideoMemorySize()
{
	static info_file, video_adapter_info, Match, Match1
	info_file := A_Temp "\Win32_videocontroller_info.txt"
	RunWait, %ComSpec% /k wmic PATH Win32_videocontroller GET adapterram>"%info_file%" & exit,, Hide
	if FileExist(info_file) {
		FileRead, video_adapter_info, % info_file
		Loop, Parse, % video_adapter_info, `n, `r
		{
			if RegExMatch(Trim(A_LoopField), "^(\d{4,})$", Match) {
				return (Match1+0)
			}
		}
		FileDelete, % info_file
	}
	return
}

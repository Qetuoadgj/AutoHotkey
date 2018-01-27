#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn All ; Enable warnings to assist with detecting common errors.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
; SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.

#SingleInstance Force

global app_name := "ReShade_Helper"
global os_type := A_Is64bitOS ? "64" : "32"
global reshade_dll := A_WorkingDir . "\ReShade" . os_type . ".dll"
global reshade_ini := A_WorkingDir . "\ReShade.ini"
global reshade_dir := A_WorkingDir . "\reshade-shaders"
global driver_dll := ""
global driver_ini := ""
global shaders_dir := reshade_dir . "\Shaders"

if A_Args.Length() > 0
{
    ; MsgBox % "This script requires at least 3 parameters but it only received " A_Args.Length() "."
	gosub COPY_PRESET_SHADERS
	; MsgBox %PresetFile%
    ExitApp
}

gosub CREATE_MAIN_WINDOW

Exit

RESET_SETTINGS:
{
	OutMsg := ""
	MsgBox, 33,, Reset settings to reshade_defaults.ini ?
	IfMsgBox Ok
	{
		global DefaultsINI := A_WorkingDir . "\ReShade.ini", DefaultsSections := ""
		IniRead DefaultsSections, %DefaultsINI%
		OutMsg .= DefaultsSections . "`n"
		; MsgBox % OutMsg
	}
	return
}

CREATE_MAIN_WINDOW:
{
	global MainGUI := APP_NAME . "_"
	Gui %MainGUI%: Add, Button, x12 y10 w460 h70 gBrowseOpen vSelectGame Disabled, % "Select game"
	Gui %MainGUI%: Add, Radio, x197 y80 w90 h30 gSelectDriver vdxgi Group, % "Direct3D 10+"
	Gui %MainGUI%: Add, Radio, x102 y80 w90 h30 gSelectDriver vdx9, % "Direct3D 9"
	Gui %MainGUI%: Add, Radio, x292 y80 w90 h30 gSelectDriver vopengl, % "OpenGL"
	Gui %MainGUI%: Show, w488 h112, % "Welcome"
	Gui %MainGUI%: Submit, NoHide ; необходимо для "запуска" переменных
	return
}

ReShade_Helper_GuiClose:
{ ; %MainGUI%GuiClose
	ExitApp
}

SelectDriver:
{
	Gui %MainGUI%: Submit, NoHide ; необходимо для "запуска" переменных
	driver_dll := dxgi ? "dxgi.dll" : dx9 ? "d3d9.dll" : opengl ? ("opengl" . os_type . ".dll") : ""
	driver_ini := dxgi ? "dxgi.ini" : dx9 ? "d3d9.ini" : opengl ? ("opengl" . os_type . ".ini") : ""
	if (driver_dll) {		
		GuiControl, Enable, SelectGame
	}
	else {
		GuiControl, Disable, SelectGame
	}
	return
}

BrowseOpen:
{
	global SelectedFilePath, SelectedFileFileName, SelectedFileDir, SelectedFileExtension, SelectedFileNameNoExt, SelectedFileDrive
	FileSelectFile, SelectedFilePath, 3,, % "Select file", % "*.exe"
	if SelectedFilePath and driver_dll {
		SplitPath, SelectedFilePath, SelectedFileFileName, SelectedFileDir, SelectedFileExtension, SelectedFileNameNoExt, SelectedFileDrive
		FileCopy % reshade_dll, % SelectedFileDir . "\" . driver_dll
		FileCopy % reshade_ini, % SelectedFileDir . "\" . driver_ini
		FileCopyDir % reshade_dir, % SelectedFileDir . "\reshade-shaders"
		MsgBox % reshade_dll . "`n" . reshade_ini . "`n`n-->`n`n" . SelectedFileDir . "\" . driver_dll . "`n" . SelectedFileDir . "\" . driver_ini
		MsgBox % reshade_dir . "`n`n-->`n`n" . SelectedFileDir . "\reshade-shaders"
		if ErrorLevel {
			MsgBox The folder could not be copied, perhaps because a folder of that name already exists in "%SelectedFileDir%".
		}
		if FileExist(SelectedFileDir . "\reshade-shaders") {
			FileCreateDir % SelectedFileDir . "\screenshots"
		}
	}
	return
}

COPY_PRESET_SHADERS:
{
	global PresetFile, TechniquesList, ShaderFile, ShaderContents, fxhFile, MustCopy
	PresetFile := A_Args[1]
	TechniquesList := IniRead(PresetFile, "", "Techniques", "")
	OutMsg := "TechniquesList: " . TechniquesList . "`n"
	;
	if (TechniquesList and not TechniquesList = "ERROR") {
		EmptyDir(shaders_dir)
		;
		Loop Parse, TechniquesList, `,
		{
			Technique := Trim(A_LoopField, """" . " ")
			Loop, Files, % reshade_dir . "\Main\*.fx", RF
			{
				ShaderFile := A_LoopFileFullPath
				FileRead, ShaderContents, %ShaderFile%
				Loop Parse, ShaderContents, `n, `r
				{
					if RegExMatch(Trim(A_LoopField), "technique[`t ]+" . Technique . "\b", ShaderMatch) {
						FileCopy %ShaderFile%, % shaders_dir, 0
						fxhFile := RegExReplace(ShaderFile, "^(.*)\.fx$", "$1.fxh")
						if FileExist(fxhFile) {
							FileCopy %fxhFile%, % shaders_dir, 0
						}
						; MsgBox % ShaderMatch . "`n" . ShaderFile
					}
				}
			}
			; MsgBox % Technique
		}
		MustCopy := "ReShade.fxh,DrawText.fxh"
		Loop, Files, % reshade_dir . "\Main\Shaders\*.fxh", RF
		{
			if A_LoopFileName in %MustCopy%
			{
				ShaderFile := A_LoopFileFullPath
				FileCopy %ShaderFile%, % shaders_dir, 0
			}
		}
	}
	;
	MsgBox % OutMsg
	return
}

EmptyDir(Dir) {
	FileRemoveDir % Dir, 1
	FileCreateDir % Dir
	return ErrorLevel
}

#Include %A_ScriptDir%\Includes\FUNC_IniRead.ahk

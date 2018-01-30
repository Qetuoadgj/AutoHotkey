#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn, All ; Enable warnings to assist with detecting common errors.
SendMode, Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir, %A_ScriptDir% ; Ensures a consistent starting directory.

#SingleInstance Force
DetectHiddenWindows, On

; Your code here...

GUI_W := 450
GUI_H := 80
GUI_Marging := 5

BTN_X := 0
BTN_Y := 0
BTN_W := GUI_W - GUI_Marging*2
BTN_H := 30

ActiveShaderSet := ""
if FileExist(A_WorkingDir . "\shaders\night-eye.txt") {
	FileRead, ActiveShaderSet, % A_WorkingDir . "\shaders\night-eye.txt"
}

GuiButtons := []

Selected_BTN := ""
Loop, Files, %  A_WorkingDir . "\accNightEyeShaders0_2d\*", D
{
	BTN_X := GUI_Marging
	BTN_Y := BTN_H * (A_Index - 1) + GUI_Marging * A_Index
	GUI_H := (BTN_H + GUI_Marging) * A_Index + GUI_Marging
	Gui, Add, Button, x%BTN_X% y%BTN_Y% w%BTN_W% h%BTN_H% gOn_Button_Pressed, % A_LoopFileName
	GuiButtons.Push(A_LoopFileName)
	if (A_LoopFileName = ActiveShaderSet) {
		Selected_BTN := % A_LoopFileName
	}
}

Gui, Show, w%GUI_W% h%GUI_H%, Untitled GUI
if (Selected_BTN) {
	Gui, Font, Bold, Default ; If desired, use a line like this to set a new default font for the window.
	GuiControl, Font, % Selected_BTN ; Put the above font into effect for a control.
	GuiControl, Focus, % Selected_BTN
}

Exit

On_Button_Pressed:
{
	Loop, Files, % A_WorkingDir . "\accNightEyeShaders0_2d\" . A_GuiControl . "\*", FR
	{
		ShaderFile := A_LoopFileFullPath
		ShaderFileName := A_LoopFileName
		if (A_Index = 1) {
			FileRemoveDir, %  A_WorkingDir . "\shaders", 1
			FileCreateDir, %  A_WorkingDir . "\shaders"
		}
		Skip := RegExMatch(A_LoopFileName, "NIGHTEYE000.*")
		if (not Skip) {
			FileCopy, % ShaderFile, %  A_WorkingDir . "\shaders\" . ShaderFileName
		}
	}
	Loop, 15
	{
		FileCopy, %  A_WorkingDir . "\accNightEyeShaders0_2d\" . A_GuiControl . "\shaderpackage001.sdp", %  A_WorkingDir . "\shaders\" . Format("shaderpackage{1:0.3d}.sdp", A_Index), 0
	}
	FileAppend, % A_GuiControl, % A_WorkingDir . "\shaders\night-eye.txt"
	if (not ErrorLevel) {
		for BTN_Index, BTN in GuiButtons
		{
			Gui, Font, Normal, Default
			GuiControl, Font, % BTN
		}
		Gui, Font, Bold, Default
		GuiControl, Font, % A_GuiControl
	}
	return
}

GuiClose:
{
	ExitApp
}

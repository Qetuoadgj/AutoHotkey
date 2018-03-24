#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn, All, MsgBox ; Enable warnings to assist with detecting common errors.
SendMode, Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir, %A_ScriptDir% ; Ensures a consistent starting directory.

#InstallKeybdHook
#UseHook, On

#SingleInstance, Ignore

; SetFormat, Integer, Hex
Gui, -ToolWindow +SysMenu +AlwaysOnTop

Gui, Font, s14 Bold, Arial

tX := 15, tY := 15, tW := 200, tH := 33

Gui, Add, Text, % "x" tX " y" tY+(tH+tY)*0 " w" tW " h" tH " vKN" " 0x201" " +Border", % "Key Name"
Gui, Add, Text, % "x" tX " y" tY+(tH+tY)*1 " w" tW " h" tH " vVK" " 0x201" " +Border", % "Key VK"
Gui, Add, Text, % "x" tX " y" tY+(tH+tY)*2 " w" tW " h" tH " vSC" " 0x201" " +Border", % "Key SC"

Gui, Show,, % "Scan Code Finder"

Loop, 9
{
	OnMessage( 255+A_Index, "ScanCode" ) ; 0x100 to 0x108
}

Return

ScanCode(wParam, lParam)
{
	/*
	Clipboard := "SC" SubStr((((lParam>>16) & 0xFF)+0xF000),-2)
	GuiControl,, SC, %Clipboard%
	SetFormat, Integer, D
	VK := GetKeyVK(Clipboard)
	SC := Clipboard ;GetKeySC(Clipboard)
	KN := GetKeyName(Clipboard)
	*/

	local
	static

	KeyHistory := ParseKeyHistory()

	KN := KeyHistory[KeyHistory.MaxIndex()]["Key"]
	VK := KeyHistory[KeyHistory.MaxIndex()]["VK"]
	SC := KeyHistory[KeyHistory.MaxIndex()]["SC"]

	VK := hexToDecimal(VK)

	GuiControl,, KN, %KN%
	GuiControl,, VK, %VK%
	GuiControl,, SC, SC%SC%

	Clipboard := "SC" SC " `; " KN " [vk" VK "]"
}

GuiContextMenu:
{
	Menu, Tray, Show
	Return
}

ScriptInfo(Command)
{
	static hEdit := 0, pfn, bkp
	if !hEdit {
		hEdit := DllCall("GetWindow", "ptr", A_ScriptHwnd, "uint", 5, "ptr")
		user32 := DllCall("GetModuleHandle", "str", "user32.dll", "ptr")
		pfn := [], bkp := []
		for i, fn in ["SetForegroundWindow", "ShowWindow"] {
			pfn[i] := DllCall("GetProcAddress", "ptr", user32, "astr", fn, "ptr")
			DllCall("VirtualProtect", "ptr", pfn[i], "ptr", 8, "uint", 0x40, "uint*", 0)
			bkp[i] := NumGet(pfn[i], 0, "int64")
		}
	}

	if (A_PtrSize=8) {	; Disable SetForegroundWindow and ShowWindow.
		NumPut(0x0000C300000001B8, pfn[1], 0, "int64")	; return TRUE
		NumPut(0x0000C300000001B8, pfn[2], 0, "int64")	; return TRUE
		}
	else {
		NumPut(0x0004C200000001B8, pfn[1], 0, "int64")	; return TRUE
		NumPut(0x0008C200000001B8, pfn[2], 0, "int64")	; return TRUE
	}

	static cmds := {ListLines:65406, ListVars:65407, ListHotkeys:65408, KeyHistory:65409}
	cmds[Command] ? DllCall("SendMessage", "ptr", A_ScriptHwnd, "uint", 0x111, "ptr", cmds[Command], "ptr", 0) : 0

	NumPut(bkp[1], pfn[1], 0, "int64")	; Enable SetForegroundWindow.
	NumPut(bkp[2], pfn[2], 0, "int64")	; Enable ShowWindow.

	ControlGetText, text,, ahk_id %hEdit%
	return text
}

ParseKeyHistory(KeyHistory:="",ParseStringEnumerations:=1){
	/*
	Parses the text from AutoHotkey's Key History into an associative array:

	Header:
	KeyHistory[0]	["Window"]					String
	["K-hook"]					Bool
	["M-hook"]					Bool
	["TimersEnabled"]			Int
	["TimersTotal"]				Int
	["Timers"]					String OR Array		[i] String
	["ThreadsInterrupted"]		Int
	["ThreadsPaused"]			Int
	["ThreadsTotal"]			Int
	["ThreadsLayers"]			Int
	["PrefixKey"]				Bool
	["ModifiersGetKeyState"]	|String OR Array	["LAlt"]   Bool
	["ModifiersLogical"]		|					["LCtrl"]  Bool
	["ModifiersPhysical"]		|					["LShift"] Bool
	["LWin"]   Bool
	["RAlt"]   Bool
	["RCtrl"]  Bool
	["RShift"] Bool
	["RWin"]   Bool

	Body:
	KeyHistory[i]	["VK"]		String [:xdigit:]{2}
	["SC"]		String [:xdigit:]{3}
	["Type"]	Char [ hsia#U]
	["UpDn"]	Bool (0=up 1=down)
	["Elapsed"]	Float
	["Key"]		String
	["Window"]	String
	*/


	If !(KeyHistory) && IsFunc("ScriptInfo")
	KeyHistory:=ScriptInfo("KeyHistory")

	RegExMatch(KeyHistory,"sm)(?P<Head>.*?)\s*^NOTE:.*-{109}\s*(?P<Body>.*)\s+Press \[F5] to refresh\.",KeyHistory_)
	KeyHistory:=[]

	RegExMatch(KeyHistory_Head,"Window: (.*)\s+Keybd hook: (.*)\s+Mouse hook: (.*)\s+Enabled Timers: (\d+) of (\d+) \((.*)\)\s+Interrupted threads: (.*)\s+Paused threads: (\d+) of (\d+) \((\d+) layers\)\s+Modifiers \(GetKeyState\(\) now\) = (.*)\s+Modifiers \(Hook's Logical\) = (.*)\s+Modifiers \(Hook's Physical\) = (.*)\s+Prefix key is down: (.*)",Re)

	KeyHistory[0]:={"Window": Re1, "K-hook": (Re2="yes"), "M-hook": (Re3="yes"), "TimersEnabled": Re4, "TimersTotal": Re5, "Timers": Re6, "ThreadsInterrupted": Re7, "ThreadsPaused": Re8, "ThreadsTotal": Re9, "ThreadsLayers": Re10, "ModifiersGetKeyState": Re11, "ModifiersLogical": Re12, "ModifiersPhysical": Re13, "PrefixKey": (Re14="yes")}

	If (ParseStringEnumerations){
		Loop, Parse,% "ModifiersGetKeyState,ModifiersLogical,ModifiersPhysical",CSV
		{
			i:=A_Loopfield
			k:=KeyHistory[0][i]
			KeyHistory[0][i]:={}
			Loop, Parse,% "LWin,LShift,LCtrl,LAlt,RWin,RShift,RCtrl,RAlt",CSV
			KeyHistory[0][i][A_LoopField]:=Instr(k,A_Loopfield)
		}

		k:=KeyHistory[0]["Timers"]
		KeyHistory[0]["Timers"]:=[]
		Loop, Parse,k,%A_Space%
		KeyHistory[0]["Timers"].Push(A_Loopfield)
	}

	Loop, Parse,KeyHistory_Body,`n,`r
	{
		RegExMatch(A_Loopfield,"(\w+) {2}(\w+)\t([ hsia#U])\t([du])\t(\S+)\t(\S*) *\t(.*)",Re)
		KeyHistory.Push({"VK": Re1, "SC": Re2, "Type": Re3, "UpDn": (Re4="D"), "Elapsed": Re5, "Key": Re6, "Window": Re7})
	}

	Return KeyHistory
}

hexToDecimal(str)
{
	static _0 := 0
	static _1 := 1
	static _2 := 2
	static _3 := 3
	static _4 := 4
	static _5 := 5
	static _6 := 6
	static _7 := 7
	static _8 := 8
	static _9 := 9
	static _a := 10
	static _b := 11
	static _c := 12
	static _d := 13
	static _e := 14
	static _f := 15
	;
	str := LTrim(str, "0x `t`n`r")
	len := StrLen(str)
	ret := 0
	Loop, Parse, str
	{
		ret += _%A_LoopField% * (16 ** (len - A_Index))
	}
	return ret
}

#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn,All ; Enable warnings to assist with detecting common errors.
SendMode,Input ; Recommended for new scripts due to its superior speed and reliability.
; SetWorkingDir,%A_ScriptDir% ; Ensures a consistent starting directory.

Script.Force_Single_Instance()
Script.Run_As_Admin()
/*
if not ( Win_Width or Win_Height ) {
	MsgBox, �� ������� ����:`n%Win_Title%
	ExitApp
}
*/

Win_Title := "���������� ABBYY FineReader ahk_exe FineReader.exe ahk_class #32770"
Win_Width = 0
Win_Height = 0

Step := 5
Scale := 2

Text_1 := "��� �� ������: +20%`n`n��� �������� / ������ �����������: -50%`n���������� ����`n������ (0, 0.3, 255)  -  Numpad *  `n���������� ����`n������ (0, 1.0, 179)  -  Numpad /  `n"

ToolTip_Time := 800*3

pixelsPerMove := 1

#IfWinActive, ahk_exe FineReader.exe
{
	Numpad9:: ; ���������� 20 ������ �������
	Win_ID := WinExist( Win_Title )
	if ( Win_ID )
	{
		WinActivate, ahk_id %Win_ID%
		if WinActive( "ahk_id " Win_ID )
		{			
			Max := Get_Max()
			Pct := 20 ; To_Percent( Get_Pos(), Max, False ) + Step
			Pos := To_Pos( Pct, Max, False )
			SendMessage, 0x0422, 0, %Pos%, msctls_trackbar321, ahk_id %Win_ID%
			Cur := To_Percent( Get_Pos(), Max, False )
			Tip := Cur > 0 ? "+" Cur "%" : Cur "%"
			Tip := Tip "`n`n" Text_1
			ToolTip( Tip, ToolTip_Time )
		}
	}
	return
	
	Numpad7:: ; ���������� -50 ������ �������
	Win_ID := WinExist( Win_Title )
	if ( Win_ID )
	{	
		WinActivate, ahk_id %Win_ID%
		if WinActive( "ahk_id " Win_ID )
		{			
			Max := Get_Max()
			Pct := -50 ; To_Percent( Get_Pos(), Max, False ) + Step
			Pos := To_Pos( Pct, Max, False )
			SendMessage, 0x0422, 0, %Pos%, msctls_trackbar321, ahk_id %Win_ID%
			Cur := To_Percent( Get_Pos(), Max, False )
			Tip := Cur > 0 ? "+" Cur "%" : Cur "%"
			Tip := Tip "`n`n" Text_1
			ToolTip( Tip, ToolTip_Time )
		}
	}
	return
	
	Numpad5:: ; �������� ������� �� 0
	Win_ID := WinExist( Win_Title )
	if ( Win_ID )
	{	
		WinActivate, ahk_id %Win_ID%
		if WinActive( "ahk_id " Win_ID )
		{			
			Max := Get_Max()
			SendMessage, 0x0422, 0, 0, msctls_trackbar321, ahk_id %Win_ID%
			Cur := To_Percent( Get_Pos(), Max, False )
			Tip := Cur > 0 ? "+" Cur "%" : Cur "%"
			Tip := Tip "`n`n" Text_1
			ToolTip( Tip, ToolTip_Time )
		}
	}
	return
	
	Numpad6:: ; �������� 5 ������ �������
	Win_ID := WinExist( Win_Title )
	if ( Win_ID )
	{	
		WinActivate, ahk_id %Win_ID%
		if WinActive( "ahk_id " Win_ID )
		{			
			Max := Get_Max()
			Pct := To_Percent( Get_Pos(), Max, False ) + Step
			Pos := To_Pos( Pct, Max, False )
			SendMessage, 0x0422, 0, %Pos%, msctls_trackbar321, ahk_id %Win_ID%
			Cur := To_Percent( Get_Pos(), Max, False )
			Tip := Cur > 0 ? "+" Cur "%" : Cur "%"
			Tip := Tip "`n`n" Text_1
			ToolTip( Tip, ToolTip_Time )
		}
	}
	return
	
	Numpad4:: ; ������ 5 ������ �������
	Win_ID := WinExist( Win_Title )
	if ( Win_ID )
	{
		WinActivate, ahk_id %Win_ID%
		if WinActive( "ahk_id " Win_ID )
		{			
			Max := Get_Max()
			Pct := To_Percent( Get_Pos(), Max, False ) - Step
			Pos := To_Pos( Pct, Max, False )
			SendMessage, 0x0422, 0, %Pos%, msctls_trackbar321, ahk_id %Win_ID%
			Cur := To_Percent( Get_Pos(), Max, False )
			Tip := Cur > 0 ? "+" Cur "%" : Cur "%"
			Tip := Tip "`n`n" Text_1
			ToolTip( Tip, ToolTip_Time )
		}
	}
	return
	
	NumpadAdd:: ; ��������� ����
	Win_ID := WinExist( Win_Title )
	if ( Win_ID )
	{	
		gosub, GetStartDimensions
		WinActivate, ahk_id %Win_ID%
		if WinActive( "ahk_id " Win_ID )
		{			
			; Center Win
			; --------------------------------------
			; WinGetPos,,, Width, Height, ahk_id %Win_ID%
			Scale := ( A_ScreenHeight - 100 ) / Win_Height
			Width := Win_Width * Scale
			Height := Win_Height * Scale
			WinMove, ahk_id %Win_ID%,, (A_ScreenWidth/2)-(Width/2), (A_ScreenHeight/2)-(Height/2), Width, Height
			; --------------------------------------
		}
	}
	return
	
	NumpadSub:: ; ��������� ����
	Win_ID := WinExist( Win_Title )
	if ( Win_ID )
	{	
		gosub, GetStartDimensions
		WinActivate, ahk_id %Win_ID%
		if WinActive( "ahk_id " Win_ID )
		{			
			; Center Win
			; --------------------------------------
			; WinGetPos,,, Width, Height, ahk_id %Win_ID%
			Width := Win_Width
			Height := Win_Height
			WinMove, ahk_id %Win_ID%,, (A_ScreenWidth/2)-(Width/2), (A_ScreenHeight/2)-(Height/2), Width, Height
			; --------------------------------------
		}
	}
	return
	
	NumpadMult:: ; ������ (0, 0.3, 255)
	Win_ID := WinExist( "ahk_exe FineReader.exe ahk_class FineReader12MainWindowClass" )
	if ( Win_ID )
	{	
		WinActivate, ahk_id %Win_ID%
		if WinActive( "ahk_id " Win_ID )
		{
			Val = 0,30
			ControlSetText, Edit9, %Val%, ahk_id %Win_ID%
			ControlSend, Edit9, {Space}
		}
	}
	return
	
	NumpadDiv:: ; ������ (0, 1.0, 179)
	Win_ID := WinExist( "ahk_exe FineReader.exe ahk_class FineReader12MainWindowClass" )
	if ( Win_ID )
	{	
		WinActivate, ahk_id %Win_ID%
		if WinActive( "ahk_id " Win_ID )
		{
			Val := Round( (1 - 0.30) * 255, 0 )
			ControlSetText, Edit10, %Val%, ahk_id %Win_ID%
			ControlSend, Edit10, {Space}
		}
	}
	return
	
	Right:: ; ������� ����� ������
	Win_ID := WinExist( "ahk_exe FineReader.exe ahk_class FineReader12MainWindowClass" )
	if ( Win_ID )
	{	
		WinActivate, ahk_id %Win_ID%
		if WinActive( "ahk_id " Win_ID )
		{
			MouseClickDrag,Left,,,% pixelsPerMove,0,,R
		}
	}
	return
	
	Left:: ; ������� ����� �����
	Win_ID := WinExist( "ahk_exe FineReader.exe ahk_class FineReader12MainWindowClass" )
	if ( Win_ID )
	{	
		WinActivate, ahk_id %Win_ID%
		if WinActive( "ahk_id " Win_ID )
		{
			MouseClickDrag,Left,,,% -pixelsPerMove,0,,R
		}
	}
	return
	
	Up:: ; ������� ����� �����
	Win_ID := WinExist( "ahk_exe FineReader.exe ahk_class FineReader12MainWindowClass" )
	if ( Win_ID )
	{	
		WinActivate, ahk_id %Win_ID%
		if WinActive( "ahk_id " Win_ID )
		{
			MouseClickDrag,Left,,,0,% -pixelsPerMove,,R
		}
	}
	return
	
	Down:: ; ������� ����� ����
	Win_ID := WinExist( "ahk_exe FineReader.exe ahk_class FineReader12MainWindowClass" )
	if ( Win_ID )
	{	
		WinActivate, ahk_id %Win_ID%
		if WinActive( "ahk_id " Win_ID )
		{
			MouseClickDrag,Left,,,0,% pixelsPerMove,,R
		}
	}
	return
	
	Numpad3:: ; A4
	Win_ID := WinExist( "ahk_exe FineReader.exe ahk_class FineReader12MainWindowClass" )
	if ( Win_ID )
	{	
		WinActivate, ahk_id %Win_ID%
		if WinActive( "ahk_id " Win_ID )
		{
			ControlGetText, Val, Edit2, ahk_id %Win_ID%
			Val := StrReplace(Val, ",", ".") * 1 ; ����� � �����
			Val := Round(Val * (210 / 297), 1) ; ��� �4 (210 � 297 ��)
			Val := StrReplace(Val, ".", ",") ; ����� � �����
			;
			ControlGet, Control_HWND, HWND,, Edit1, ahk_id %Win_ID%
			ControlSetText,, %Val%, ahk_id %Control_HWND%
			ControlFocus,, ahk_id %Control_HWND%
			SendMessage, 177, 0, -1,, ahk_id %Control_HWND%
			ControlSend,, {Enter}, ahk_id %Control_HWND%
		}
	}
	return
	
	Numpad1:: ; ������ (297, 1, 200)
	Win_ID := WinExist( "ahk_exe FineReader.exe ahk_class FineReader12MainWindowClass" )
	if ( Win_ID )
	{	
		WinActivate, ahk_id %Win_ID%
		if WinActive( "ahk_id " Win_ID )
		{
			Val = 243 ;200
			ControlSetText, Edit10, %Val%, ahk_id %Win_ID%
			ControlSend, Edit10, {Space}
			;
			; Val := Val - 3
			; ControlSetText, Edit8, %Val%, ahk_id %Win_ID%
			; ControlSend, Edit8, {Space}
			;
			Val = 0.01 ; 1
			ControlSetText, Edit9, %Val%, ahk_id %Win_ID%
			ControlSend, Edit9, {Space}
		}
	}
	return	
}

F12::			
WinGet, ActiveControlList, ControlList, A
out := ""
; Loop, Parse, ActiveControlList, `n
; {
	; ControlGet, theList, List,, %A_LoopField%, A
	; ControlGetText, theText, %A_LoopField%
	; val := theText ? theText : theList
	; out .= "Control #" a_index " is " A_LoopField "`t===>`t" val "`n"
; }
ControlGetFocus, OutputVar, A
out := OutputVar
MsgBox, % out
return

/*
NumpadEnter:: ; ������� ����� ����
Win_ID := WinExist( "ahk_exe FineReader.exe ahk_class FineReader12MainWindowClass" )
if ( Win_ID )
{	
	ClassNN := "AWL:2EE50000:80:0:0:0:02"
	ControlGetFocus, OutputVar, A
	Control, ShowDropDown, , %OutputVar%, A
	Control, Choose, 2, %OutputVar%, A
	Control, ChooseString, "�����-����", %OutputVar%, A
}
return
*/

ExitApp

GetStartDimensions:
{
	Win_Width = 683
	Win_Height = 475
	if not ( Win_Width or Win_Height ) {
		WinGetPos,,, Win_Width, Win_Height, %Win_Title%
	}
	return
}

Get_Min( Win_ID := False )
{
	Win_ID := Win_ID ? Win_ID : WinExist("A")
	SendMessage, 0x0401, 0, 0, msctls_trackbar321, ahk_id %Win_ID% ; TBM_GETRANGEMIN
	return, ErrorLevel
}

Get_Max( Win_ID := False )
{
	Win_ID := Win_ID ? Win_ID : WinExist("A")
	SendMessage, 0x0402, 0, 0, msctls_trackbar321, ahk_id %Win_ID% ; TBM_GETRANGEMAX
	return, ErrorLevel
}
Get_Pos( Win_ID := False )
{
	Win_ID := Win_ID ? Win_ID : WinExist("A")
	static Min, Max, Pos
	SendMessage, 0x0401, 0, 0, msctls_trackbar321, ahk_id %Win_ID% ; TBM_GETRANGEMIN
	Min := ErrorLevel
	SendMessage, 0x0402, 0, 0, msctls_trackbar321, ahk_id %Win_ID% ; TBM_GETRANGEMAX
	Max := ErrorLevel
	SendMessage, 0x0400, 0, 0, msctls_trackbar321, ahk_id %Win_ID% ; TBM_GETPOS
	Pos := ErrorLevel
	Pos := Pos > Max ? Pos - Min - Max : Pos
	return, Pos
}

To_Percent( Cur, Max, Rnd := 0)
{
	return, Round( Cur / Max * 100, Rnd )
}

To_Pos( Pct, Max, Rnd := 0 )
{
	return, Round( Max * ( Pct / 100 ), Rnd )
}

ToolTip( text, time := 800 )
{ ; ������� ������ ������������ ��������� � ����������� ( ��������� �� ������� )
	ToolTip, %text%
	SetTimer, Clear_ToolTips, %time%
}

Clear_ToolTips:
{ ; ������ ������� ��������� � ���������� ��������� � ��� ��������
	ToolTip
	SetTimer, %A_ThisLabel%, Off
	return
}

class Script
{ ; ������� ���������� ��������
	
	Force_Single_Instance()
	{ ; ������� ��������������� ���������� ���� ����� �������� ������� (������������ ��� .exe � .ahk)
		static Detect_Hidden_Windows_Tmp
		static File_Types, Index, File_Type
		static Script_Name, Script_Full_Path
		Detect_Hidden_Windows_Tmp := A_DetectHiddenWindows
		#SingleInstance, Off
		DetectHiddenWindows, On
		File_Types := [ ".exe", ".ahk" ]
		for Index, File_Type in File_Types {
			Script_Name := RegExReplace( A_ScriptName, "^(.*)\.(.*)$", "$1" ) . File_Type
			Script_Full_Path := A_ScriptDir . "\" . Script_Name
			This.Close_Other_Instances( Script_Full_Path . "ahk_class AutoHotkey" )
		}
		DetectHiddenWindows, % Detect_Hidden_Windows_Tmp
	}
	
	Close_Other_Instances( Script_Full_Path )
	{ ; ������� ���������� ���� ����� �������� ������� (������ ��� ���������� �����)
		static Process_ID
		Script_Full_Path := Script_Full_Path ? Script_Full_Path : A_ScriptFullPath . " ahk_class AutoHotkey"
		WinGet, Current_ID, ID, % A_ScriptFullPath . " ahk_class AutoHotkey"
		WinGet, Process_List, List, % Script_Full_Path . " ahk_class AutoHotkey"
		Process_Count := 1
		Loop, %Process_List%
		{
			Process_ID := Process_List%Process_Count%
			if ( not Process_ID = Current_ID ) {
				WinGet, Process_PID, PID, % Script_Full_Path . " ahk_id " . Process_ID
				Process, Close, %Process_PID%
			}
			Process_Count += 1
		}
	}
	
	Run_As_Admin( Params := "" )
	{ ; ������� ������� ������� � ������� ���������������
		if ( not A_IsAdmin ) {
			try {
				Run, *RunAs "%A_ScriptFullPath%" %Params%
			}
			ExitApp
		}
	}
	
	Name()
	{ ; ������� ��������� ����� �������� �������
		SplitPath, A_ScriptFullPath,,,, Name
		return, Name
	}
}


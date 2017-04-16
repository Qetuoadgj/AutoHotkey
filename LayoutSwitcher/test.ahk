#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn,All ; Enable warnings to assist with detecting common errors.
SendMode,Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir,%A_ScriptDir% ; Ensures a consistent starting directory.

Script.Force_Single_Instance()

Script_Name := Script.Name()
Config_File := A_ScriptDir "\" Script_Name ".ini"

CreateLocalization:
{
	Translation_Language := Layout.Language_Name( "0x" . A_Language, true )
	Translation_File := A_ScriptDir "\Translations\" Translation_Language ".ini"
	; MsgBox, % Translation_Language
	
	; Info
	IniRead, l_info_app_site, %Translation_File%, Info, info_app_site, App URL

	; System
	IniRead, l_system_suspend_hotkeys, %Translation_File%, System, system_suspend_hotkeys, % "Suspend HotKeys"
	IniRead, l_system_enable_auto_start, %Translation_File%, System, system_enable_auto_start, % "Auto Start"
	IniRead, l_system_start_with_admin_rights, %Translation_File%, System, system_start_with_admin_rights, % "Admin Rights"
	; IniRead, l_system_encoding_compatibility_mode, %Translation_File%, System, system_encoding_compatibility_mode, % "Encoding Compatibility Mode"
	IniRead, l_system_show_tray_icon, %Translation_File%, System, system_show_tray_icon, % "Show Tray Icon"

	; Flag
	IniRead, l_flag_show_borders, %Translation_File%, Flag, flag_show_borders, % "Show Borders"
	IniRead, l_flag_always_on_top, %Translation_File%, Flag, flag_always_on_top, % "Always On Top"
	IniRead, l_flag_fixed_position, %Translation_File%, Flag, flag_fixed_position, % "Fix Position"
	IniRead, l_flag_hide_in_fullscreen_mode, %Translation_File%, Flag, flag_hide_in_fullscreen_mode, % "Hide In Fullscreen Mode"

	; Sound
	IniRead, l_sound_enable, %Translation_File%, Sound, sound_enable, % "Enable Sounds"
	
	; App
	IniRead, l_app_restart, %Translation_File%, App, app_restart, % "Restart App"
	IniRead, l_app_exit, %Translation_File%, App, app_exit, % "Close App"
	IniRead, l_app_options, %Translation_File%, App, app_options, % "Open Settings"
	IniRead, l_app_generate_dictionaries, %Translation_File%, App, app_generate_dictionaries, % "Generate Dictionaries"
}

GoSub, SET_DEFAULTS
GoSub, READ_CONFIG_FILE

If ( system_start_with_admin_rights ) {
	Script.Run_As_Admin()
}

GoSub, FLAG_Create_GUI

GoSub, FLAG_Customize_Menus

GoSub, FLAG_Add_Picture

Last_Layout_Full_Name := ""
SetTimer, FLAG_Update, % system_check_layout_change_interval

GoSub, SAVE_CONFIG_FILE

NumPad0::
{
	Selected_Text := Edit_Text.Select()
	Converted_Text := Edit_Text.Convert_Case( Selected_Text, false )
	Edit_Text.Paste( Converted_Text )
	Sleep, 50
	Return
}

NumPad1::
{
	; -----------------------------------------------------------------------------------
	; ��������� ������ / ��������� ��� �����������, ���������� ���������� "Selected_Text"
	; -----------------------------------------------------------------------------------
	Selected_Text := Edit_Text.Select()
	; -----------------------------------------------------------------------------------
	; ����������� �������, ��������� ���������������� ������
	; -----------------------------------------------------------------------------------
	Selected_Text_Dictionary := Edit_Text.Dictionary( Selected_Text )
	Converted_Text := Edit_Text.Replace_By_Dictionaries( Selected_Text, Selected_Text_Dictionary, "Russian" )
	; MsgBox, % Selected_Text_Dictionary ":`n" Edit_Text.Dictionaries[Selected_Text_Dictionary]
	; ToolTip, % Selected_Text "`n" Converted_Text
	Edit_Text.Paste( Converted_Text )
	; -----------------------------------------------------------------------------------
	Sleep, 50
	Return
}

NumPad2::
{
	Selected_Text := Edit_Text.Select()
	Selected_Text_Dictionary := Edit_Text.Dictionary( Selected_Text )
	If ( not Selected_Text_Dictionary ) {
		Text_Layout_Index := Layout.Get_Index( Layout.Get_HKL( "A" ) )
		Selected_Text_Dictionary := Layout.Layouts_List[Text_Layout_Index].Full_Name
	} Else {
		Text_Layout_Index := Layout.Get_Index_By_Name( Selected_Text_Dictionary )
	}
	If ( Text_Layout_Index ) {
		Next_Layout_Index := Text_Layout_Index + 1 > Layout.Layouts_List.MaxIndex() ? 1 : Text_Layout_Index + 1
		Next_Layout_Full_Name := Layout.Layouts_List[Next_Layout_Index].Full_Name
		Converted_Text := Edit_Text.Replace_By_Dictionaries( Selected_Text, Selected_Text_Dictionary, Next_Layout_Full_Name )
		Edit_Text.Paste( Converted_Text )
		Next_Layout_HKL := Layout.Layouts_List[Next_Layout_Index].HKL
		Layout.Change( Next_Layout_HKL )
		
		Next_Layout_Display_Name := Layout.Layouts_List[Next_Layout_Index].Display_Name
		ToolTip( Next_Layout_Full_Name " - " Next_Layout_Display_Name )
	}
	Sleep, 50
	Return
}

Exit

SET_DEFAULTS:
{
	; Info
	info_app_site := "https://github.com/Qetuoadgj/AutoHotkey/tree/master/LayoutSwitcher"
	
	; System
	system_suspend_hotkeys := 0
	system_enable_auto_start := 0
	system_start_with_admin_rights := 0
	system_check_layout_change_interval := "On" ; 250
	system_detect_dictionary := 1
	system_encoding_compatibility_mode := 0
	system_show_tray_icon := 1
	
	; Flag
	flag_width := 32
	flag_height := 22
	flag_position_x := "Center"
	flag_position_y := "Center"
	flag_show_borders := 1
	flag_always_on_top := 1
	flag_fixed_position := 0
	flag_hide_in_fullscreen_mode := 1
	
	; Sound
	sound_enable := 1
	sound_next_layout := "sounds\next_layout.wav"
	sound_switch_text_case := "sounds\switch_text_case.wav"
	sound_switch_text_layout := "sounds\switch_text_layout.wav"
	
	; HotKeys
	key_next_layout := "CapsLock"
	key_switch_text_case := "$~!Break"
	key_switch_text_layout := "$~Break"
	
	; Dictionaries
	dictionary_english := "``1234567890-=qwertyuiop[]asdfghjkl;'\\zxcvbnm,./ ~!@#$^&*()_+QWERTYUIOP{}ASDFGHJKL:""||ZXCVBNM<>?"
	dictionary_ukrainian := "�1234567890-=����������������������\����������. �!""�;:?*()_+����������կԲ�������ƪ/����������,"
	dictionary_russian := "�1234567890-=�����������������������\\���������. �!""�;:?*()_+�����������������������//���������,"
	
	Return
}

READ_CONFIG_FILE:
{
	; Info
	IniRead, info_app_site, %Config_File%, Info, info_app_site, %info_app_site%

	; System
	IniRead, system_suspend_hotkeys, %Config_File%, System, system_suspend_hotkeys, %system_suspend_hotkeys%
	IniRead, system_enable_auto_start, %Config_File%, System, system_enable_auto_start, %system_enable_auto_start%
	IniRead, system_start_with_admin_rights, %Config_File%, System, system_start_with_admin_rights, %system_start_with_admin_rights%
	IniRead, system_check_layout_change_interval, %Config_File%, System, system_check_layout_change_interval, %system_check_layout_change_interval%
	IniRead, system_detect_dictionary, %Config_File%, System, system_detect_dictionary, %system_detect_dictionary%
	IniRead, system_encoding_compatibility_mode, %Config_File%, System, system_encoding_compatibility_mode, %system_encoding_compatibility_mode%
	IniRead, system_show_tray_icon, %Config_File%, System, system_show_tray_icon, %system_show_tray_icon%

	; Flag
	IniRead, flag_width, %Config_File%, Flag, flag_width, %flag_width%
	IniRead, flag_height, %Config_File%, Flag, flag_height, %flag_height%
	IniRead, flag_position_x, %Config_File%, Flag, flag_position_x, %flag_position_x%
	IniRead, flag_position_y, %Config_File%, Flag, flag_position_y, %flag_position_y%
	IniRead, flag_show_borders, %Config_File%, Flag, flag_show_borders, %flag_show_borders%
	IniRead, flag_always_on_top, %Config_File%, Flag, flag_always_on_top, %flag_always_on_top%
	IniRead, flag_fixed_position, %Config_File%, Flag, flag_fixed_position, %flag_fixed_position%
	IniRead, flag_hide_in_fullscreen_mode, %Config_File%, Flag, flag_hide_in_fullscreen_mode, %flag_hide_in_fullscreen_mode%

	; Sound
	IniRead, sound_enable, %Config_File%, Sound, sound_enable, %sound_enable%
	IniRead, sound_next_layout, %Config_File%, Sound, sound_next_layout, %sound_next_layout%
	IniRead, sound_switch_text_case, %Config_File%, Sound, sound_switch_text_case, %sound_switch_text_case%
	IniRead, sound_switch_text_layout, %Config_File%, Sound, sound_switch_text_layout, %sound_switch_text_layout%

	; HotKeys
	IniRead, key_next_layout, %Config_File%, HotKeys, key_next_layout, %key_next_layout%
	IniRead, key_switch_text_case, %Config_File%, HotKeys, key_switch_text_case, %key_switch_text_case%
	IniRead, key_switch_text_layout, %Config_File%, HotKeys, key_switch_text_layout, %key_switch_text_layout%

	; Dictionaries
	IniRead, dictionary_english, %Config_File%, Dictionaries, dictionary_english, %dictionary_english%
	IniRead, dictionary_ukrainian, %Config_File%, Dictionaries, dictionary_ukrainian, %dictionary_ukrainian%
	IniRead, dictionary_russian, %Config_File%, Dictionaries, dictionary_russian, %dictionary_russian%
	
	Get_Dictionaries( Config_File, "Dictionaries" , "dictionary_" )
	Remove_Unused_Dictionaries()
	
	Return
}

SAVE_CONFIG_FILE:
{
	; Info
	IniWrite( "info_app_site", Config_File, "Info", info_app_site )

	; System
	IniWrite( "system_suspend_hotkeys", Config_File, "System", system_suspend_hotkeys )
	IniWrite( "system_enable_auto_start", Config_File, "System", system_enable_auto_start )
	IniWrite( "system_start_with_admin_rights", Config_File, "System", system_start_with_admin_rights )
	IniWrite( "system_check_layout_change_interval", Config_File, "System", system_check_layout_change_interval )
	IniWrite( "system_detect_dictionary", Config_File, "System", system_detect_dictionary )
	IniWrite( "system_encoding_compatibility_mode", Config_File, "System", system_encoding_compatibility_mode )
	IniWrite( "system_show_tray_icon", Config_File, "System", system_show_tray_icon )

	; Flag
	IniWrite( "flag_width", Config_File, "Flag", flag_width )
	IniWrite( "flag_height", Config_File, "Flag", flag_height )
	IniWrite( "flag_position_x", Config_File, "Flag", flag_position_x )
	IniWrite( "flag_position_y", Config_File, "Flag", flag_position_y )
	IniWrite( "flag_show_borders", Config_File, "Flag", flag_show_borders )
	IniWrite( "flag_always_on_top", Config_File, "Flag", flag_always_on_top )
	IniWrite( "flag_fixed_position", Config_File, "Flag", flag_fixed_position )
	IniWrite( "flag_hide_in_fullscreen_mode", Config_File, "Flag", flag_hide_in_fullscreen_mode )

	; Sound
	IniWrite( "sound_enable", Config_File, "Sound", sound_enable )
	IniWrite( "sound_next_layout", Config_File, "Sound", sound_next_layout )
	IniWrite( "sound_switch_text_case", Config_File, "Sound", sound_switch_text_case )
	IniWrite( "sound_switch_text_layout", Config_File, "Sound", sound_switch_text_layout )

	; HotKeys
	IniWrite( "key_next_layout", Config_File, "HotKeys", key_next_layout )
	IniWrite( "key_switch_text_case", Config_File, "HotKeys", key_switch_text_case )
	IniWrite( "key_switch_text_layout", Config_File, "HotKeys", key_switch_text_layout )

	; Dictionaries
	IniWrite( "dictionary_english", Config_File, "Dictionaries", dictionary_english )
	IniWrite( "dictionary_ukrainian", Config_File, "Dictionaries", dictionary_ukrainian )
	IniWrite( "dictionary_russian", Config_File, "Dictionaries", dictionary_russian )
	
	Return
}

Get_Dictionaries( ByRef Config_File, ByRef Section, ByRef Prefix := "" )
{
	static Dictionaries_List
	static Match
	static Key
	static Value
	IniRead, Dictionaries_List, %Config_File%, %Section%
	Loop, Parse, Dictionaries_List, `n, `r
	{
		If ( RegExMatch( A_LoopField, Prefix . "(.*?)=(.*)", Match ) ) {
			Key := Trim( Match1 )
			If ( Layout.Get_Index_By_Name( Key ) ) {
				IniRead, Value, %Config_File%, %Section%, % Prefix . Key
				Edit_Text.Dictionaries[Key] := Value
				; MsgBox, % Prefix . Key "`n" Value
			}
		}
	}
}

Remove_Unused_Dictionaries()
{
	static Dictionary_Name
	For Dictionary_Name in Edit_Text.Dictionaries {
		If ( not Layout.Get_Index_By_Name( Dictionary_Name ) ) {
			Edit_Text.Dictionaries.Delete( Dictionary_Name )
			; MsgBox, % Dictionary_Name
		}
	}
}

FLAG_Create_GUI:
{
	; Gui, FLAG_: Color, FFFFFF
	Gui, FLAG_: -SysMenu +Owner -Caption +ToolWindow
	If ( flag_always_on_top ) {
		Gui, FLAG_: +AlwaysOnTop
	} Else {
		Gui, FLAG_: -AlwaysOnTop
	}
	If ( flag_show_borders ) {
		Gui, FLAG_: +Border
	} Else {
		Gui, FLAG_: -Border
	}
	Gui, FLAG_: Show, w%flag_width% h%flag_height% x%flag_position_x% y%flag_position_y%
	Gui, FLAG_: +LastFound
	WinGet, flag_win_id, ID
	OnMessage( WM_LBUTTONDOWN := 0x201, "FLAG_WM_LBUTTONDOWN" ) ; ������ LMB
	Return
}

FLAG_GuiContextMenu:
{ ; ���� RMB �� ����� (Gui, FLAG_:...)
	Menu, Tray, Show
	Return
}

FLAG_WM_LBUTTONDOWN()
{
	global flag_fixed_position
	If ( flag_fixed_position ) {
		Return
	}
	PostMessage, WM_NCLBUTTONDOWN := 0xA1, 2
	Sleep, 250
	PostMessage, WM_NCLBUTTONUP := 0xA2, 2
	GoSub, FLAG_Save_Position
	Return
}

FLAG_Save_Position:
{
	WinGetPos, flag_position_x, flag_position_y,,, ahk_id %flag_win_id%
	IniWrite( "flag_position_x", Config_File, "Flag", flag_position_x )
	IniWrite( "flag_position_y", Config_File, "Flag", flag_position_y )
	Return
}

FLAG_Add_Picture:
{
	Gui, FLAG_: Add, Picture, x0 y0 w%flag_width% h%flag_height% vFLAG_PICTURE
	Return
}

FLAG_Update:
{
	If ( flag_always_on_top ) {
		If ( flag_hide_in_fullscreen_mode and isWindowFullScreen( "A" ) ) {
			; Gui, FLAG_: -AlwaysOnTop
			WinSet, Bottom,, ahk_id %flag_win_id%
		} Else {
			Gui, FLAG_: +AlwaysOnTop
		}
	}
	Current_Layout_HKL := Layout.Get_HKL( "A" )
	If ( not Current_Layout_HKL ) {
		Return
	}
	Current_Layout_Full_Name := Layout.Language_Name( Current_Layout_HKL, True )
	If ( Current_Layout_Full_Name = Last_Layout_Full_Name) {
		Return
	}
	GoSub, FLAG_Update_Picture
	if ( system_show_tray_icon ) {
		GoSub, FLAG_Update_Tray_Icon
	}
	Last_Layout_Full_Name := Current_Layout_Full_Name
	Return
}

FLAG_Update_Picture:
{
	Current_Layout_Png := A_WorkingDir "\images\" Current_Layout_Full_Name ".png"
	GuiControl, FLAG_:, FLAG_PICTURE, *x0 *y0 *w%flag_width% *h%flag_height% %Current_Layout_Png%
	Return
}

FLAG_Update_Tray_Icon:
{
	Current_Layout_Ico := A_WorkingDir "\icons\" Current_Layout_Full_Name ".ico"
	If FileExist( Current_Layout_Ico ) {
		Menu, Tray, Icon, %Current_Layout_Ico%
	} Else {
		Menu, Tray, Icon, *
	}
	Menu, Tray, Tip, %Current_Layout_Full_Name%
	Return
}

FLAG_Customize_Menus:
{
	Menu, Tray, NoStandard
	
	Menu, Tray, Add, %l_system_suspend_hotkeys%, Menu_Toggle_Suspend
	If ( system_suspend_hotkeys ) {
		Suspend, On
		Menu, Tray, Check, %l_system_suspend_hotkeys%
	}

	Menu, Tray, Add, %l_system_enable_auto_start%, Menu_Toggle_Auto_Start
	If ( system_enable_auto_start ) {
		Menu, Tray, Check, %l_system_enable_auto_start%
	}
	
	Menu, Tray, Add, %l_system_start_with_admin_rights%, Menu_Toggle_Admin_Rights
	If ( system_start_with_admin_rights ) {
		Menu, Tray, Check, %l_system_start_with_admin_rights%
	}
	
	Menu, Tray, Add, %l_system_show_tray_icon%, Menu_Toggle_Show_Tray_Icon
	If ( system_show_tray_icon ) {
		Menu, Tray, Check, %l_system_show_tray_icon%
		Menu, Tray, Icon
	} Else {
		Menu, Tray, NoIcon
	}
	
	Menu, Tray, Add
	
	Menu, Tray, Add, %l_flag_show_borders%, Menu_Toggle_Show_Borders
	If ( flag_show_borders ) {
		Menu, Tray, Check, %l_flag_show_borders%
	}

	Menu, Tray, Add, %l_flag_always_on_top%, Menu_Toggle_Always_On_Top
	If ( flag_always_on_top ) {
		Menu, Tray, Check, %l_flag_always_on_top%
	}
	
	Menu, Tray, Add, %l_flag_fixed_position%, Menu_Toggle_Fixed_Position
	If ( flag_fixed_position ) {
		Menu, Tray, Check, %l_flag_fixed_position%
	}
	
	Menu, Tray, Add, %l_flag_hide_in_fullscreen_mode%, Menu_Toggle_Hide_In_Fullscreen_Mode
	If ( flag_hide_in_fullscreen_mode ) {
		Menu, Tray, Check, %l_flag_hide_in_fullscreen_mode%
	}
	
	Menu, Tray, Add
	
	Menu, Tray, Add, %l_info_app_site%, Menu_App_Site
	
	Menu, Tray, Add

	Menu, Tray, Add, %l_app_generate_dictionaries%, Menu_Generate_Dictionaries
	Menu, Tray, Add, %l_app_options%, Menu_Options
	Menu, Tray, Add, %l_app_restart%, Menu_Reload_App
	Menu, Tray, Add, %l_app_exit%, Menu_Exit_App
	
	Return
}

Menu_Toggle_Suspend:
{
	Menu, Tray, ToggleCheck, %A_ThisMenuItem%
	system_suspend_hotkeys := not system_suspend_hotkeys
	IniWrite( "system_suspend_hotkeys", Config_File, "System", system_suspend_hotkeys )
	Suspend, Toggle
	Return
}

Menu_Toggle_Auto_Start:
{
	Menu, Tray, ToggleCheck, %A_ThisMenuItem%
	system_enable_auto_start := not system_enable_auto_start
	IniWrite( "system_enable_auto_start", Config_File, "System", system_enable_auto_start )
	Auto_Run_Task_Name := "CustomTasks\" Script_Name
	If ( system_enable_auto_start ) {
		Create_Auto_Run_Task( Auto_Run_Task_Name, system_start_with_admin_rights )
	} Else {
		Delete_Auto_Run_Task( Auto_Run_Task_Name )
	}
	Return
}

Menu_Toggle_Admin_Rights:
{
	Menu, Tray, ToggleCheck, %A_ThisMenuItem%
	system_start_with_admin_rights := not system_start_with_admin_rights
	IniWrite( "system_start_with_admin_rights", Config_File, "System", system_start_with_admin_rights )
	If ( system_start_with_admin_rights ) {
		Script.Run_As_Admin()
	} Else {
		Reload
	}
	Return
}

Menu_Toggle_Show_Tray_Icon:
{
	Menu, Tray, ToggleCheck, %A_ThisMenuItem%
	system_show_tray_icon := not system_show_tray_icon
	IniWrite( "system_show_tray_icon", Config_File, "System", system_show_tray_icon )
	If ( system_show_tray_icon ) {
		Menu, Tray, Icon
	} Else {
		Menu, Tray, NoIcon
	}
	Return
}

Menu_Toggle_Show_Borders:
{
	Menu, Tray, ToggleCheck, %A_ThisMenuItem%
	flag_show_borders := not flag_show_borders
	IniWrite( "flag_show_borders", Config_File, "Flag", flag_show_borders )
	If ( flag_show_borders ) {
		Gui, FLAG_: +Border
	} Else {
		Gui, FLAG_: -Border
	}
	Gui, FLAG_: Show, w%flag_width% h%flag_height%
	Return
}

Menu_Toggle_Always_On_Top:
{
	Menu, Tray, ToggleCheck, %A_ThisMenuItem%
	flag_always_on_top := not flag_always_on_top
	IniWrite( "flag_always_on_top", Config_File, "Flag", flag_always_on_top )
	If ( flag_always_on_top ) {
		Gui, FLAG_: +AlwaysOnTop
	} Else {
		Gui, FLAG_: -AlwaysOnTop
	}
	Return
}

Menu_Toggle_Fixed_Position:
{
	Menu, Tray, ToggleCheck, %A_ThisMenuItem%
	flag_fixed_position := not flag_fixed_position
	IniWrite( "flag_fixed_position", Config_File, "Flag", flag_fixed_position )
	If ( flag_always_on_top ) {
		Gui, FLAG_: +AlwaysOnTop
	} Else {
		Gui, FLAG_: -AlwaysOnTop
	}
	Return
}

Menu_Toggle_Hide_In_Fullscreen_Mode:
{
	Menu, Tray, ToggleCheck, %A_ThisMenuItem%
	flag_hide_in_fullscreen_mode := not flag_hide_in_fullscreen_mode
	IniWrite( "flag_hide_in_fullscreen_mode", Config_File, "Flag", flag_hide_in_fullscreen_mode )
	If ( flag_always_on_top ) {
		Gui, FLAG_: +AlwaysOnTop
	} Else {
		Gui, FLAG_: -AlwaysOnTop
	}
	Return
}

Menu_App_Site:
{
	Run, %info_app_site%
	Return
}

Menu_Generate_Dictionaries:
{
	Generate_Dictionaries()
	Return
}

Menu_Options:
{
	Run, notepad.exe "%Config_File%"
	Return
}

Menu_Reload_App:
{
	Reload
	Return
}

Menu_Exit_App:
{
	ExitApp
	Return
}

Create_Auto_Run_Task( ByRef Task_Name, ByRef Admin_Rights := False )
{
	static Command
	Command = "%A_WinDir%\System32\schtasks.exe" /create /TN "%Task_Name%" /TR """"%A_ScriptFullPath%"""" /SC ONLOGON
	Command .= Admin_Rights ? " /RL HIGHEST /F" : " /F"
	RunWait, *RunAs %Command%
}

Delete_Auto_Run_Task( ByRef Task_Name )
{
	static Command
	Command = "%A_WinDir%\System32\schtasks.exe" /delete /TN "%Task_Name%" /F
	RunWait, *RunAs %Command%
}

Generate_Dictionaries()
{
	static Notepad_PID, Notepad_ID, Win_Title, Keys
	Run, % "notepad.exe /W",,, Notepad_PID

	WinWait, ahk_pid %Notepad_PID%
	WinGet, Notepad_ID, ID, ahk_pid %Notepad_PID%

	Win_Title = ahk_id %Notepad_ID%

	Keys := ["SC029","SC002","SC003","SC004"
	,"SC005","SC006","SC007","SC008","SC009"
	,"SC00A","SC00B","SC00C","SC00D","SC010"
	,"SC011","SC012","SC013","SC014","SC015"
	,"SC016","SC017","SC018","SC019","SC01A"
	,"SC01B","SC01E","SC01F","SC020","SC021"
	,"SC022","SC023","SC024","SC025","SC026"
	,"SC027","SC028","SC02B","SC056","SC02C"
	,"SC02D","SC02E","SC02F","SC030","SC031"
	,"SC032","SC033","SC034","SC035"]
	
	WinActivate, %Win_Title%
	WinWaitActive, %Win_Title%
	
	static Layout_Index, Layout_Data
	static Dictionary_Name, k, v
	
	For Layout_Index, Layout_Data in Layout.Layouts_List
	{
		WinActivate, %Win_Title%
		WinWaitActive, %Win_Title%
		IfWinActive, %Win_Title%
		{			
			While ( Layout.Get_HKL( Win_Title ) != Layout_Data.HKL and A_Index < 5 )
			{
				Layout.Change( Layout_Data.HKL, Win_Title )
				Sleep,50
			}
			If ( Layout.Get_HKL( Win_Title ) = Layout_Data.HKL )
			{
				Dictionary_Name := Layout_Data.Full_Name
				SendRaw, %Dictionary_Name%=
				For k, v in Keys {
					Send, {%v%}
				}
				Send, {SC039}
				For k, v in Keys {
					Send, +{%v%}
				}
				SendRaw, % "`n"
			}
		}
	}
}

class Layout
{ ; ������� ���������� ����������� ����������
	static SISO639LANGNAME := 0x0059 ; ISO abbreviated language name, eg "en"
	static LOCALE_SENGLANGUAGE := 0x1001 ; Full language name, eg "English"
	static WM_INPUTLANGCHANGEREQUEST := 0x0050
	static INPUTLANGCHANGE_FORWARD := 0x0002
	static INPUTLANGCHANGE_BACKWARD := 0x0004
	
	static Layouts_List := Layout.Get_Layouts_List()
	
	Get_Layouts_List()
	{ ; ������� �������� ���� ������ ��� ������� ���������
		static Layouts_List, Layouts_List_Size
		static Layout_HKL, Layout_Name, Layout_Full_Name, Layout_Display_Name
		VarSetCapacity( List, A_PtrSize * 5 )
		Layouts_List_Size := DllCall( "GetKeyboardLayoutList", Int, 5, Str, List )
		Layouts_List := []
		Loop, % Layouts_List_Size
		{
			Layout_HKL := NumGet( List, A_PtrSize * ( A_Index - 1 ) ) ; & 0xFFFF
			Layout_Name := This.Language_Name( Layout_HKL, false )
			Layout_Full_Name := This.Language_Name( Layout_HKL, true )
			Layout_Display_Name := This.Display_Name( Layout_HKL )
			Layouts_List[A_Index] := {}
			Layouts_List[A_Index].HKL := Layout_HKL
			Layouts_List[A_Index].Name := Layout_Name
			Layouts_List[A_Index].Full_Name := Layout_Full_Name
			Layouts_List[A_Index].Display_Name := Layout_Display_Name
		}
		Return, Layouts_List
	}
	
	Language_Name( ByRef HKL, ByRef Full_Name := false )
	{ ; ������� ��������� ������������ ( ������������ "en" ��� ������� "English") ��������� �� � "HKL" 
		static LocID, LCType, Size
		LocID := HKL & 0xFFFF
		LCType := Full_Name ? This.LOCALE_SENGLANGUAGE : This.SISO639LANGNAME
		Size := DllCall( "GetLocaleInfo", UInt, LocID, UInt, LCType, UInt, 0, UInt, 0 ) * 2
		VarSetCapacity( localeSig, Size, 0 )
		DllCall( "GetLocaleInfo", UInt, LocID, UInt, LCType, Str, localeSig, UInt, Size )
		Return, localeSig
	}
	
	Display_Name( ByRef HKL )
	{ ; ������� ��������� �������� ( "����������" ) ��������� �� � "HKL" 
		static KLID
		KLID := This.KLID( HKL )
		RegRead, Display_Name, % "HKEY_LOCAL_MACHINE", % "SYSTEM\CurrentControlSet\Control\Keyboard Layouts\" . KLID, % "Layout Display Name"
		if (not Display_Name) {
			Return, False
		}
		DllCall( "Shlwapi.dll\SHLoadIndirectString", "Ptr", &Display_Name, "Ptr", &Display_Name, "UInt", outBufSize := 50, "UInt", 0 )
		if (not Display_Name) {
			RegRead, Display_Name, % "HKEY_LOCAL_MACHINE", % "SYSTEM\CurrentControlSet\Control\Keyboard Layouts\" . KLID, % "Layout Text"
		}
		Return, Display_Name
	}
	
	KLID( Byref HKL )
	{ ; ������� ��������� �������� "KLID" ��������� �� � "HKL" 
		static KLID, Prior_HKL
		VarSetCapacity( KLID, 8 * ( A_IsUnicode ? 2 : 1 ) )
		Prior_HKL := DllCall( "GetKeyboardLayout", "Ptr", DllCall( "GetWindowThreadProcessId", "Ptr", 0, "UInt", 0, "Ptr" ), "Ptr" )
		if ( not DllCall( "ActivateKeyboardLayout", "Ptr", HKL, "UInt", 0 ) or not DllCall( "GetKeyboardLayoutName", "Ptr", &KLID ) or not DllCall( "ActivateKeyboardLayout", "Ptr", Prior_HKL, "UInt", 0 ) ) {
			Return, False
		}
		Return, StrGet(&KLID)
	}
	
	Get_HKL( ByRef Window := "A" )
	{ ; ������� ��������� �������� "HKL" ������� ���������
		static HKL
		If ( Window_ID := WinExist( Window ) ) {
			WinGetClass, Window_Class
			If ( Window_Class = "ConsoleWindowClass" ) {
				WinGet, Console_PID, PID
				DllCall( "AttachConsole", Ptr, Console_PID )
				VarSetCapacity( Buff, 16 )
				DllCall( "GetConsoleKeyboardLayoutName", Str, Buff )
				DllCall( "FreeConsole" )
				HKL := SubStr( Buff, -3 )
				HKL := HKL ? "0x" . HKL : 0
			} else {
				HKL := DllCall( "GetKeyboardLayout", Ptr, DllCall( "GetWindowThreadProcessId", Ptr, Window_ID, UInt, 0, Ptr ), Ptr ) ; & 0xFFFF
			}
			If ( not HKL )
			{ ; ������� ���� Windows
				If ( Window_ID := WinExist( "ahk_class Progman ahk_exe Explorer.EXE" ) ) {
					HKL := DllCall( "GetKeyboardLayout", Ptr, DllCall( "GetWindowThreadProcessId", Ptr, Window_ID, UInt, 0, Ptr ), Ptr ) ; & 0xFFFF
				}
			}
			Return, HKL
		}
	}
	
	Next( ByRef Window := "A" )
	{ ; ������� ����� ��������� ( ������ )
		If ( Window_ID := WinExist( Window ) ) {
			PostMessage, % This.WM_INPUTLANGCHANGEREQUEST, % This.INPUTLANGCHANGE_FORWARD,,, ahk_id %Window_ID%
		}
	}
	
	Change( Byref HKL, ByRef Window := "A" )
	{ ; ������� ����� ��������� �� "HKL"
		If ( Window_ID := WinExist( Window ) ) {
			PostMessage, % This.WM_INPUTLANGCHANGEREQUEST,, % HKL,, ahk_id %Window_ID%
		}
	}
	
	Get_Index( Byref HKL )
	{ ; ������� ��������� ����������� ������ ��������� �� "HKL"
		static Index, Layout
		For Index, Layout in This.Layouts_List
		{
			If ( This.KLID( Layout.HKL ) = This.KLID( HKL ) ) {
				Return, Index
			}
		}
	}
	
	Get_Index_By_Name( Byref Full_Name )
	{ ; ������� ��������� ����������� ������ ��������� �� ������� ����� ( "English" )
		static Index, Layout
		For Index, Layout in This.Layouts_List
		{
			If ( Layout.Full_Name = Full_Name ) {
				Return, Index
			}
		}
	}
}

class Edit_Text
{ ; ������� ��������� / ��������� ������
	static Ctrl_C := "^{vk43}"
	static Ctrl_V := "^{vk56}"
	static Select_Left := "^+{Left}"
	static Select_Right := "^+{Right}"
	static Select_No_Space := "^+{Right 2}" . "^+{Left}"

	static Title_Case_Symbols := "(\_|\-|\.|\[|\(|\{)"
	static Title_Case_Match := "(.)"
	static Upper_Case_Words := "(ID\b|PID\b|UI\b|HKL\b|KLID\b)"
	
	static Next_Case_ID := "U"
	
	static Dictionaries := {}
	static Dictionaries.Russian := "�1234567890-=�����������������������\\���������. �!""�;%:?*()_+�����������������������//���������,"
	static Dictionaries.English := "``1234567890-=qwertyuiop[]asdfghjkl;'\\zxcvbnm,./ ~!@#$%^&*()_+QWERTYUIOP{}ASDFGHJKL:""||ZXCVBNM<>?"
	static Dictionaries.Ukrainian := "�1234567890-=����������������������\����������. �!""�;%:?*()_+����������կԲ�������ƪ/����������,"
	
	Select()
	{ ; ������� ��������� ����������� ������ ���� ��������� ������ ����� �� ������� �������
		static Selected_Text
		; -----------------------------------------------------------------------------------
		; ��������� ������ / ��������� ��� �����������, ���������� ���������� "Selected_Text"
		; -----------------------------------------------------------------------------------
		Clipboard = ; Null
		SendInput, % This.Ctrl_C
		ClipWait, 0.05
		Selected_Text = ; Null
		If ( not Selected_Text := Clipboard ) {
			Loop, 100
			{
				Clipboard = ; Null
				SendInput, % This.Select_Left . This.Ctrl_C
				ClipWait, 0.5
				If ( not Clipboard )
				{ ; ������������� �� ������, ���� ����� ������ ���������� ����������� � �����
					Return
				}
				If RegExMatch( Clipboard, "\s" ) {
					Clipboard = ; Null
					SendInput, % This.Select_No_Space . This.Ctrl_C ; This.Select_Right . This.Ctrl_C
					ClipWait, 0.5
					Break
				}
				If ( StrLen( Clipboard ) = StrLen( Selected_Text ) ) {
					Break
				}
				Selected_Text := Clipboard
			}
		}
		; -----------------------------------------------------------------------------------
		Return, Selected_Text
	}
	
	Convert_Case( ByRef Selected_Text, ByRef Force_Case_ID := 0 )
	{ ; ������� ����� �������� ������
		static Converted_Text
		; -----------------------------------------------------------------------------------
		; �������������� �������� ������, ���������� ���������� "Converted_Text"
		; -----------------------------------------------------------------------------------
		If ( not Selected_Text ) {
			Return
		}
		This.Next_Case_ID := Force_Case_ID ? Force_Case_ID : This.Next_Case_ID
		If ( This.Next_Case_ID = "U" ) {
			StringUpper, Converted_Text, Selected_Text
			If ( not Force_Case_ID and Converted_Text == Selected_Text ) {
				This.Next_Case_ID := "T"
			}
		}
		If ( This.Next_Case_ID = "T" ) {
			StringLower, Converted_Text, Selected_Text, T
			Converted_Text := RegExReplace( Converted_Text, This.Title_Case_Symbols . This.Title_Case_Match, "$1$U2" )
			Converted_Text := RegExReplace( Converted_Text, "i)" . This.Title_Case_Symbols . This.Upper_Case_Words, "$1$U2" )
			If ( not Force_Case_ID and Converted_Text == Selected_Text ) {
				This.Next_Case_ID := "L"
			}
		}
		If ( This.Next_Case_ID = "L" ) {
			StringLower, Converted_Text, Selected_Text
			If ( not Force_Case_ID and Converted_Text == Selected_Text ) {
				This.Next_Case_ID := "U"
			}
		}
		If ( not Force_Case_ID ) {
			If ( This.Next_Case_ID = "U" ) {
				This.Next_Case_ID := "T"
			} Else If ( This.Next_Case_ID = "T" ) {
				This.Next_Case_ID := "L"
			} Else If ( This.Next_Case_ID = "L" ) {
				This.Next_Case_ID := "U"
			}
		}
		; -----------------------------------------------------------------------------------
		Return, Converted_Text
	}
	
	Dictionary( ByRef Selected_Text )
	{ ; ������� �������� ������ �� ��������� ( ����������� �������, ���������������� ������ )
		static Language
		static Dictionary
		static Same_Dictionary
		; -----------------------------------------------------------------------------------
		; ����������� �������, ��������� ���������������� ������
		; -----------------------------------------------------------------------------------
		If ( not Selected_Text ) {
			Return
		}
		For Language, Dictionary in This.Dictionaries {
			; MsgBox, % Language " = " Dictionary
			Loop, Parse, Selected_Text
			{
				Same_Dictionary := InStr( Dictionary, A_LoopField, 1 ) or RegExMatch( A_LoopField, "\s" )
			} Until not Same_Dictionary
			If ( Same_Dictionary ) {
				Return, Language
			}
		}
		; -----------------------------------------------------------------------------------
	}
	
	Replace_By_Dictionaries( ByRef Selected_Text, ByRef Current_Dictionary, ByRef Next_Dictionary )
	{ ; ������� ������ �������� ������ ������� ���������������� ( �� ������� ) ��������� ������� ( ����� ��������� ������ )
		static Converted_Text
		; -----------------------------------------------------------------------------------
		; ������ �������� ������� "Current_Dictionary" ���������������� ��������� "Next_Dictionary"
		; -----------------------------------------------------------------------------------
		If ( not Selected_Text ) {
			Return
		}
		Converted_Text = ; Null
		Loop, Parse, Selected_Text
		{
			If ( Current_Dictionary_Match := InStr( This.Dictionaries[Current_Dictionary], A_LoopField, 1 ) ) {
				Converted_Text .= SubStr( This.Dictionaries[Next_Dictionary], Current_Dictionary_Match, 1 )
			} Else {
				Converted_Text .= A_LoopField
			}
		}
		; -----------------------------------------------------------------------------------
		Return, Converted_Text
	}
	
	Paste( ByRef Converted_Text )
	{ ; ������� �������� ����� ������ ������ / ������ ������
		; -----------------------------------------------------------------------------------
		; ����������� "Converted_Text" � ����� ������ � �������� ������� "Control + V"
		; -----------------------------------------------------------------------------------
		If ( not Converted_Text ) {
			Return
		}
		Clipboard = ; Null
		Clipboard := Converted_Text
		ClipWait, 1.0
		SendInput, % This.Ctrl_V
		; -----------------------------------------------------------------------------------
		Return, Clipboard
	}
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
		For Index, File_Type in File_Types {
			Script_Name := RegExReplace( A_ScriptName, "^(.*)\.(.*)$", "$1" ) . File_Type
			Script_Full_Path := A_ScriptDir . "\" . Script_Name
			This.Close_Other_Instances( Script_Full_Path . "ahk_class AutoHotkey" )
		}
		DetectHiddenWindows, % Detect_Hidden_Windows_Tmp
	}

	Close_Other_Instances( ByRef Script_Full_Path )
	{ ; ������� ���������� ���� ����� �������� ������� (������ ��� ���������� �����)
		static Process_ID
		Script_Full_Path := Script_Full_Path ? Script_Full_Path : A_ScriptFullPath . " ahk_class AutoHotkey"
		WinGet, Current_ID, ID, % A_ScriptFullPath . " ahk_class AutoHotkey"
		WinGet, Process_List, List, % Script_Full_Path . " ahk_class AutoHotkey"
		Process_Count := 1
		Loop, %Process_List%
		{
			Process_ID := Process_List%Process_Count%
			If ( not Process_ID = Current_ID ) {
				WinGet, Process_PID, PID, % Script_Full_Path . " ahk_id " . Process_ID
				Process, Close, %Process_PID%
			}
			Process_Count += 1
		}
	}

	Run_As_Admin()
	{ ; ������� ������� ������� � ������� ���������������
		If ( not A_IsAdmin ) {
			Try {
				Run, *RunAs "%A_ScriptFullPath%"
			}
			ExitApp
		}
	}
	
	Name()
	{ ; ������� ��������� ����� �������� �������
		SplitPath, A_ScriptFullPath,,,, Name
		Return, Name
	}
}

IniWrite( ByRef Key, ByRef File, ByRef Section, ByRef Value )
{ ; ������ ������������ IniWrite (���������� ������ ���������� ���������)
	if (not File) {
		Return
	}
	Value := Value = "ERROR" ? "" : Value
	IniRead, Test_Value, %File%, %Section%, %Key%
	If (not Test_Value = Value) {
		IniWrite, %Value%, %File%, %Section%, %Key%
	}
}

ToolTip( ByRef text, ByRef time := 800 )
{ ; ������� ������ ������������ ��������� � ����������� ( ��������� �� ������� )
	Tooltip, %text%
	SetTimer, Clear_ToolTips, %time%
}

Clear_ToolTips:
{ ; ������ ������� ��������� � ���������� ��������� � ��� ��������
	ToolTip
	SetTimer, %A_ThisLabel%, Off
	Return
}

isWindowFullScreen( ByRef Win_Title := "A" )
{ ; ������� �������� �������������� ������
	static Win_ID
	Win_ID := WinExist( Win_Title )
	If ( not Win_ID ) {
		Return, False
	}
	WinGet, Win_Style, Style, ahk_id %Win_ID%
	WinGetPos,,, Win_W, Win_H, %Win_Title%
	; 0x800000 is WS_BORDER.
	; 0x20000000 is WS_MINIMIZE.
	; no border and not minimized
	Return, ( ( Win_Style & 0x20800000 ) or Win_H < A_ScreenHeight or Win_W < A_ScreenWidth ) ? False : True
}
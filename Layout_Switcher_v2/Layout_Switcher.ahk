#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn All, StdOut ; Enable warnings to assist with detecting common errors.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.

DetectHiddenWindows On

; https://autohotkey.com/boards/viewtopic.php?f=6&t=6413#
#NoEnv
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#KeyHistory 0
ListLines Off
; Process Priority,, A
SetBatchLines -1
SetKeyDelay -1, -1
SetMouseDelay -1
SetDefaultMouseSpeed 0
SetWinDelay -1
;

; Определение классов (для исключения их прямой перезаписи)
new Script			:= c_Script
new Task_Sheduler	:= c_Task_Sheduler
new Windows			:= c_Windows
new Window			:= c_Window
new Layout			:= c_Layout
new Edit_Text		:= c_Edit_Text
;

Script_Name := Script.Name()
Script.Force_Single_Instance([RegExReplace(Script_Name, "_x(32|64)", "") . "*"])

Config_File := A_ScriptDir . "\" . "Layout_Switcher" . ".ini"
Auto_Run_Task_Name := "CustomTasks" . "\" . "Layout_Switcher" ; Script_Name

Clipboard_Tmp := "" ; Null

gosub CREATE_LOCALIZATION
gosub SET_DEFAULTS
gosub READ_CONFIG_FILE

if (system_start_with_admin_rights) {
	Script.Run_As_Admin(%0%)
}

if (A_IsCompiled and system_enable_auto_start and not Task_Sheduler.Task_Exists(Auto_Run_Task_Name, A_ScriptFullPath)) {
	Task_Sheduler.Create_Auto_Run_Task(Auto_Run_Task_Name, system_start_with_admin_rights, True)
}

App_PID := DllCall("GetCurrentProcessId")
if (system_run_with_high_priority) {
	Process Priority, %App_PID%, High
	; Thread NoTimers, true
	; Thread Priority, 2147483647
}
else {
	Process Priority, %App_PID%, Normal
}

gosub FLAG_Create_GUI
gosub FLAG_Customize_Menus
gosub FLAG_Add_Picture

Last_Layout_Full_Name := ""
SetTimer FLAG_Update, % system_check_layout_change_interval

gosub SAVE_CONFIG_FILE

SystemCursor("On")

OnExit, App_Close

Exit

CREATE_LOCALIZATION:
{
	Translation_Language := Layout.Language_Name("0x" . A_Language, true)
	Translation_File := A_ScriptDir . "\Translations\" . Translation_Language . ".ini"
	; MsgBox, % Translation_Language
	
	; Info
	IniRead l_info_app_site, %Translation_File%, Info, info_app_site, % "App Site"
	IniRead l_info_app_update, %Translation_File%, Info, info_app_update, % "Update App"
	
	; System
	IniRead l_system_suspend_hotkeys, %Translation_File%, System, system_suspend_hotkeys, % "Suspend HotKeys"
	IniRead l_system_enable_auto_start, %Translation_File%, System, system_enable_auto_start, % "Auto Start"
	IniRead l_system_start_with_admin_rights, %Translation_File%, System, system_start_with_admin_rights, % "Admin Rights"
	IniRead l_system_run_with_high_priority, %Translation_File%, System, system_run_with_high_priority, % "High priority"
	; IniRead, l_system_encoding_compatibility_mode, %Translation_File%, System, system_encoding_compatibility_mode, % "Encoding Compatibility Mode"
	IniRead l_system_show_tray_icon, %Translation_File%, System, system_show_tray_icon, % "Show Tray Icon"
	IniRead l_system_skip_unused_dictionaries, %Translation_File%, System, system_skip_unused_dictionaries, % "Skip Unavailable Languages"
	IniRead l_system_fix_config_file_encoding, %Translation_File%, System, system_fix_config_file_encoding, % "Fix Config File Encoding"
	IniRead l_system_switch_layouts_by_send, %Translation_File%, System, system_switch_layouts_by_send, % "Use Alternative Layout Switch"
	
	; Flag
	IniRead l_flag_show_borders, %Translation_File%, Flag, flag_show_borders, % "Show Borders"
	IniRead l_flag_always_on_top, %Translation_File%, Flag, flag_always_on_top, % "Always On Top"
	IniRead l_flag_fixed_position, %Translation_File%, Flag, flag_fixed_position, % "Fix Position"
	IniRead l_flag_hide_in_fullscreen_mode, %Translation_File%, Flag, flag_hide_in_fullscreen_mode, % "Hide In Fullscreen Mode"
	
	; Sound
	IniRead l_sound_enable, %Translation_File%, Sound, sound_enable, % "Enable Sounds"
	
	; App
	IniRead l_app_restart, %Translation_File%, App, app_restart, % "Restart App"
	IniRead l_app_exit, %Translation_File%, App, app_exit, % "Close App"
	IniRead l_app_options, %Translation_File%, App, app_options, % "Open Settings"
	IniRead l_app_generate_dictionaries, %Translation_File%, App, app_generate_dictionaries, % "Generate Dictionaries"
	
	return
}

SET_DEFAULTS:
{
	Defaults := {}
	; Info
	Defaults.info_app_site := "https://github.com/Qetuoadgj/AutoHotkey/tree/master/Layout_Switcher_v2"
	Defaults.info_updater := "updater.exe"
	
	; System
	Defaults.system_suspend_hotkeys := 0
	Defaults.system_enable_auto_start := 1 ;0
	Defaults.system_start_with_admin_rights := 1 ;0
	Defaults.system_run_with_high_priority := 1
	Defaults.system_check_layout_change_interval := "On" ; 250
	Defaults.system_detect_dictionary := 1
	; Defaults.system_encoding_compatibility_mode := 0
	Defaults.system_show_tray_icon := 1
	Defaults.system_skip_unused_dictionaries := 1
	Defaults.system_fix_config_file_encoding := 1
	Defaults.system_switch_layouts_by_send := 1
	
	; Flag
	Defaults.flag_width := 32
	Defaults.flag_height := 22
	Defaults.flag_position_x := "Center"
	Defaults.flag_position_y := "Center"
	Defaults.flag_show_borders := 1
	Defaults.flag_always_on_top := 1
	Defaults.flag_fixed_position := 0
	Defaults.flag_hide_in_fullscreen_mode := 1
	
	; Sound
	Defaults.sound_enable := 1
	Defaults.sound_switch_keyboard_layout := "sounds\switch_keyboard_layout.wav"
	Defaults.sound_switch_text_case := "sounds\switch_text_case.wav"
	Defaults.sound_switch_text_layout := "sounds\switch_text_layout.wav"
	Defaults.sound_toggle_cursor := "sounds\toggle_cursor.mp3"
	; Defaults.sound_toggle_fullscreen := "sounds\toggle_fullscreen.mp3"
	
	; HotKeys
	Defaults.key_switch_keyboard_layout := "NumPad1" ;"CapsLock"
	Defaults.key_switch_text_case := "NumPad0" ;"$~!Break"
	Defaults.key_switch_text_layout := "NumPad2" ;"$~Break"
	Defaults.key_toggle_cursor := "RWin" ;"#c"
	; Defaults.key_toggle_fullscreen := "LWin & LButton"
	
	; KeyCombos
	Defaults.combo_switch_layout := "{Alt Down}{Shift Down}{Alt Up}{Shift Up}"
	
	; Text
	Defaults.text_title_case_symbols := "(\_+|\-+|\.+|\[+|\(+|\{+|\\+|\/+|\<+|\>+|\=+|\++|\-+|\*+|\%+)"
	Defaults.text_title_case_match := "(.)"
	Defaults.text_upper_case_words := "(ID\b|PID\b|UI\b|HKL\b|KLID\b|AI\b)"
	
	; Dictionaries
	Defaults.dictionary_english := "``1234567890-=qwertyuiop[]asdfghjkl;'\\zxcvbnm,./ ~!@#$^&*()_+QWERTYUIOP{}ASDFGHJKL:`"`"||ZXCVBNM<>?"
	Defaults.dictionary_russian := "ё1234567890-=йцукенгшщзхъфывапролджэ\\ячсмитьбю. Ё!`"`"№;:?*()_+ЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭ//ЯЧСМИТЬБЮ,"
	Defaults.dictionary_ukrainian := "ё1234567890-=йцукенгшщзхїфівапролджє\ґячсмитьбю. Ё!`"`"№;:?*()_+ЙЦУКЕНГШЩЗХЇФІВАПРОЛДЖЄ/ҐЯЧСМИТЬБЮ,"
	
	
	
	return
}

READ_CONFIG_FILE:
{
	; Info
	IniRead info_app_site, %Config_File%, Info, info_app_site, % Defaults.info_app_site
	IniRead info_updater, %Config_File%, Info, info_updater, % Defaults.info_updater
	
	Normalize("info_updater", Defaults.info_updater)
	
	; System
	IniRead system_suspend_hotkeys, %Config_File%, System, system_suspend_hotkeys, % Defaults.system_suspend_hotkeys
	IniRead system_enable_auto_start, %Config_File%, System, system_enable_auto_start, % Defaults.system_enable_auto_start
	IniRead system_start_with_admin_rights, %Config_File%, System, system_start_with_admin_rights, % Defaults.system_start_with_admin_rights
	IniRead system_run_with_high_priority, %Config_File%, System, system_run_with_high_priority, % Defaults.system_run_with_high_priority
	IniRead system_check_layout_change_interval, %Config_File%, System, system_check_layout_change_interval, % Defaults.system_check_layout_change_interval
	IniRead system_detect_dictionary, %Config_File%, System, system_detect_dictionary, % Defaults.system_detect_dictionary
	; IniRead, system_encoding_compatibility_mode, %Config_File%, System, system_encoding_compatibility_mode, % Defaults.system_encoding_compatibility_mode
	IniRead system_show_tray_icon, %Config_File%, System, system_show_tray_icon, % Defaults.system_show_tray_icon
	IniRead system_skip_unused_dictionaries, %Config_File%, System, system_skip_unused_dictionaries, % Defaults.system_skip_unused_dictionaries
	IniRead system_fix_config_file_encoding, %Config_File%, System, system_fix_config_file_encoding, % Defaults.system_fix_config_file_encoding
	IniRead system_switch_layouts_by_send, %Config_File%, System, system_switch_layouts_by_send, % Defaults.system_switch_layouts_by_send
	
	; Flag
	IniRead flag_width, %Config_File%, Flag, flag_width, % Defaults.flag_width
	IniRead flag_height, %Config_File%, Flag, flag_height, % Defaults.flag_height
	IniRead flag_position_x, %Config_File%, Flag, flag_position_x, % Defaults.flag_position_x
	IniRead flag_position_y, %Config_File%, Flag, flag_position_y, % Defaults.flag_position_y
	IniRead flag_show_borders, %Config_File%, Flag, flag_show_borders, % Defaults.flag_show_borders
	IniRead flag_always_on_top, %Config_File%, Flag, flag_always_on_top, % Defaults.flag_always_on_top
	IniRead flag_fixed_position, %Config_File%, Flag, flag_fixed_position, % Defaults.flag_fixed_position
	IniRead flag_hide_in_fullscreen_mode, %Config_File%, Flag, flag_hide_in_fullscreen_mode, % Defaults.flag_hide_in_fullscreen_mode
	
	Normalize("flag_width", Defaults.flag_width)
	Normalize("flag_height", Defaults.flag_height)
	Normalize("flag_position_x", Defaults.flag_position_x)
	Normalize("flag_position_y", Defaults.flag_position_y)
	
	; Sound
	IniRead sound_enable, %Config_File%, Sound, sound_enable, % Defaults.sound_enable
	IniRead sound_switch_keyboard_layout, %Config_File%, Sound, sound_switch_keyboard_layout, % Defaults.sound_switch_keyboard_layout
	IniRead sound_switch_text_case, %Config_File%, Sound, sound_switch_text_case, % Defaults.sound_switch_text_case
	IniRead sound_switch_text_layout, %Config_File%, Sound, sound_switch_text_layout, % Defaults.sound_switch_text_layout
	IniRead sound_toggle_cursor, %Config_File%, Sound, sound_toggle_cursor, % Defaults.sound_toggle_cursor
	; IniRead sound_toggle_fullscreen, %Config_File%, Sound, sound_toggle_fullscreen, % Defaults.sound_toggle_fullscreen
	
	; HotKeys
	IniRead key_switch_keyboard_layout, %Config_File%, HotKeys, key_switch_keyboard_layout, % Defaults.key_switch_keyboard_layout
	IniRead key_switch_text_case, %Config_File%, HotKeys, key_switch_text_case, % Defaults.key_switch_text_case
	IniRead key_switch_text_layout, %Config_File%, HotKeys, key_switch_text_layout, % Defaults.key_switch_text_layout
	IniRead key_toggle_cursor, %Config_File%, HotKeys, key_toggle_cursor, % Defaults.key_toggle_cursor
	; IniRead key_toggle_fullscreen, %Config_File%, HotKeys, key_toggle_fullscreen, % Defaults.key_toggle_fullscreen
	
	; KeyCombos
	IniRead combo_switch_layout, %Config_File%, KeyCombos, combo_switch_layout, % Defaults.combo_switch_layout
	Normalize("combo_switch_layout", Defaults.combo_switch_layout)
	Layout.Switch_Layout_Combo := combo_switch_layout
	
	; Text
	IniRead text_title_case_symbols, %Config_File%, Text, text_title_case_symbols, % Defaults.text_title_case_symbols
	IniRead text_title_case_match, %Config_File%, Text, text_title_case_match, % Defaults.text_title_case_match
	IniRead text_upper_case_words, %Config_File%, Text, text_upper_case_words, % Defaults.text_upper_case_words
	
	Edit_Text.Title_Case_Symbols := text_title_case_symbols
	Edit_Text.Title_Case_Match := text_title_case_match
	Edit_Text.Upper_Case_Words := text_upper_case_words
	
	; Dictionaries
	IniRead dictionary_english, %Config_File%, Dictionaries, dictionary_english, % Defaults.dictionary_english
	IniRead dictionary_russian, %Config_File%, Dictionaries, dictionary_russian, % Defaults.dictionary_russian
	IniRead dictionary_ukrainian, %Config_File%, Dictionaries, dictionary_ukrainian, % Defaults.dictionary_ukrainian
	
	Get_Dictionaries(Config_File, "Dictionaries", "dictionary_", system_skip_unused_dictionaries)
	; Remove_Unused_Dictionaries()
	
	; for k, v in Edit_Text.Dictionaries_Order {
	; MsgBox, % v
	; }
	
	Get_Binds(Config_File, "HotKeys", "key_")
	
	/*
	if (system_enable_auto_start and not Task_Sheduler.Task_Exists(Auto_Run_Task_Name, A_ScriptFullPath)) {
	Task_Sheduler.Create_Auto_Run_Task(Auto_Run_Task_Name, system_start_with_admin_rights, True)
	; system_enable_auto_start := Task_Sheduler.Task_Exists(Auto_Run_Task_Name, A_ScriptFullPath)
	}
	*/
	
	if (system_fix_config_file_encoding) {
		ini := FileOpen(Config_File, "r")
		app_ecoding := "CP1251" ;A_FileEncoding ? A_FileEncoding : "CP1251"
		if (ini.Encoding != app_ecoding) {
			ini_data := ini.Read()
			if (ini_data) {
				ini.Close()
				MsgBox 0, Test, % "Encoding of the program: " app_ecoding "`n" "Encoding of " Config_File ": " ini.Encoding
				FileDelete %Config_File%
				FileAppend %ini_data%, %Config_File%, %app_ecoding%
			}
		}
	}
	
	/*
	for key, value in Defaults
	{ ; нормализация переменных
	Normalize(key, value)
	}
	*/
	
	return
}

SAVE_CONFIG_FILE:
{
	; Info
	IniWrite("info_app_site", Config_File, "Info", info_app_site)
	IniWrite("info_updater", Config_File, "Info", info_updater)
	
	; System
	IniWrite("system_suspend_hotkeys", Config_File, "System", system_suspend_hotkeys)
	IniWrite("system_enable_auto_start", Config_File, "System", system_enable_auto_start)
	IniWrite("system_start_with_admin_rights", Config_File, "System", system_start_with_admin_rights)
	IniWrite("system_run_with_high_priority", Config_File, "System", system_run_with_high_priority)
	IniWrite("system_check_layout_change_interval", Config_File, "System", system_check_layout_change_interval)
	IniWrite("system_detect_dictionary", Config_File, "System", system_detect_dictionary)
	; IniWrite("system_encoding_compatibility_mode", Config_File, "System", system_encoding_compatibility_mode)
	IniWrite("system_show_tray_icon", Config_File, "System", system_show_tray_icon)
	IniWrite("system_skip_unused_dictionaries", Config_File, "System", system_skip_unused_dictionaries)
	IniWrite("system_fix_config_file_encoding", Config_File, "System", system_fix_config_file_encoding)
	IniWrite("system_switch_layouts_by_send", Config_File, "System", system_switch_layouts_by_send)
	
	; Flag
	IniWrite("flag_width", Config_File, "Flag", flag_width)
	IniWrite("flag_height", Config_File, "Flag", flag_height)
	IniWrite("flag_position_x", Config_File, "Flag", flag_position_x)
	IniWrite("flag_position_y", Config_File, "Flag", flag_position_y)
	IniWrite("flag_show_borders", Config_File, "Flag", flag_show_borders)
	IniWrite("flag_always_on_top", Config_File, "Flag", flag_always_on_top)
	IniWrite("flag_fixed_position", Config_File, "Flag", flag_fixed_position)
	IniWrite("flag_hide_in_fullscreen_mode", Config_File, "Flag", flag_hide_in_fullscreen_mode)
	
	; Sound
	IniWrite("sound_enable", Config_File, "Sound", sound_enable)
	IniWrite("sound_switch_keyboard_layout", Config_File, "Sound", sound_switch_keyboard_layout)
	IniWrite("sound_switch_text_case", Config_File, "Sound", sound_switch_text_case)
	IniWrite("sound_switch_text_layout", Config_File, "Sound", sound_switch_text_layout)
	IniWrite("sound_toggle_cursor", Config_File, "Sound", sound_toggle_cursor)
	; IniWrite("sound_toggle_fullscreen", Config_File, "Sound", sound_toggle_fullscreen)
	
	; HotKeys
	IniWrite("key_switch_keyboard_layout", Config_File, "HotKeys", key_switch_keyboard_layout)
	IniWrite("key_switch_text_case", Config_File, "HotKeys", key_switch_text_case)
	IniWrite("key_switch_text_layout", Config_File, "HotKeys", key_switch_text_layout)
	IniWrite("key_toggle_cursor", Config_File, "HotKeys", key_toggle_cursor)
	; IniWrite("key_toggle_fullscreen", Config_File, "HotKeys", key_toggle_fullscreen)
	
	; KeyCombos
	IniWrite("combo_switch_layout", Config_File, "KeyCombos", combo_switch_layout)
	
	; Text
	IniWrite("text_title_case_symbols", Config_File, "Text", text_title_case_symbols)
	IniWrite("text_title_case_match", Config_File, "Text", text_title_case_match)
	IniWrite("text_upper_case_words", Config_File, "Text", text_upper_case_words)
	
	; Dictionaries
	IniWrite("dictionary_english", Config_File, "Dictionaries", dictionary_english)
	IniWrite("dictionary_russian", Config_File, "Dictionaries", dictionary_russian)
	IniWrite("dictionary_ukrainian", Config_File, "Dictionaries", dictionary_ukrainian)
	
	return
}

SWITCH_KEYBOARD_LAYOUT:
{
	if WinActive("ahk_id " Windows.Tray_ID) {
		WinActivate % "ahk_id " Windows.Desktop_ID
	}
	Layout.Next("A", system_switch_layouts_by_send)
	Layout_HKL := Layout.Get_HKL("A")
	ToolTip(Layout.Language_Name(Layout_HKL, true) " - " Layout.Display_Name(Layout_HKL))
	if (sound_enable and FileExist(sound_switch_keyboard_layout)) {
		SoundPlay %sound_switch_keyboard_layout%
	}
	Sleep 50
	return
}

TOGGLE_CURSOR:
{
	SystemCursor("Toggle")
	if (sound_enable and FileExist(sound_toggle_cursor)) {
		SoundPlay %sound_toggle_cursor%
	}
	Sleep 50
	return
}
/*
TOGGLE_FULLSCREEN:
{
WinGet, Win_PID, PID, A
if (Win_PID != App_PID) {
WinGet Style, Style, A
if (Style & 0xC40000) {
WinSet Style, -0xC40000, A
WinMaximize A
; if WinActive("ahk_exe chrome.exe") {
; WinMove A,, -5, -15, % A_ScreenWidth + 5*2, % A_ScreenHeight + 5 + 15
; }
}
else {
WinSet Style, +0xC40000, A
WinRestore A
; if WinActive("ahk_exe chrome.exe") {
; WinMove A,, 0, 0, % A_ScreenWidth / 2, % A_ScreenHeight / 2
; }
}
}
return
}
*/
SWITCH_TEXT_CASE:
{
	Clipboard_Tmp := "" ; Null
	Clipboard_Tmp := Clipboard
	if (Selected_Text := Edit_Text.Select()) {
		Converted_Text := Edit_Text.Convert_Case(Selected_Text, false)
		Edit_Text.Paste(Converted_Text)
		if (sound_enable and FileExist(sound_switch_text_case)) {
			SoundPlay %sound_switch_text_case%
		}
	}
	Sleep 50
	Clipboard := "" ; Null
	Clipboard := Clipboard_Tmp
	ClipWait 0.05
	return
}

; /*
SWITCH_TEXT_LAYOUT:
{
	Clipboard_Tmp := "" ; Null
	Clipboard_Tmp := Clipboard
	if (Selected_Text := Edit_Text.Select()) {
		Selected_Text_Dictionary := Edit_Text.Dictionary(Selected_Text)
		if (Selected_Text_Dictionary) {
			Text_Layout_Index := Layout.Get_Index_By_Name(Selected_Text_Dictionary)
		}
		else {
			Text_Layout_Index := Layout.Get_Index(Layout.Get_HKL("A"))
			Selected_Text_Dictionary := Layout.Layouts_List[Text_Layout_Index].Full_Name
		}
		if (Text_Layout_Index) {
			Next_Layout_Index := Text_Layout_Index + 1 > Layout.Layouts_List.MaxIndex() ? 1 : Text_Layout_Index + 1
			Next_Layout_Full_Name := Layout.Layouts_List[Next_Layout_Index].Full_Name
			Converted_Text := Edit_Text.Replace_By_Dictionaries(Selected_Text, Selected_Text_Dictionary, Next_Layout_Full_Name)
			Edit_Text.Paste(Converted_Text)
			if (Next_Layout_HKL := Layout.Layouts_List[Next_Layout_Index].HKL) {
				Layout.Change(Next_Layout_HKL,,system_switch_layouts_by_send)
				Next_Layout_Display_Name := Layout.Layouts_List[Next_Layout_Index].Display_Name
				ToolTip(Next_Layout_Full_Name " - " Next_Layout_Display_Name)
			}
		}
		if (sound_enable and FileExist(sound_switch_text_layout)) {
			SoundPlay %sound_switch_text_layout%
		}
	}
	Sleep 50
	Clipboard := "" ; Null
	Clipboard := Clipboard_Tmp
	ClipWait 0.05
	return
}
; */

/*
SWITCH_TEXT_LAYOUT:
{
Clipboard_Tmp := "" ; Null
Clipboard_Tmp := Clipboard
if (Selected_Text := Edit_Text.Select()) {
Selected_Text_Dictionary := Edit_Text.Dictionary(Selected_Text)
if (not Selected_Text_Dictionary) {
Text_Layout_Index := Layout.Get_Index(Layout.Get_HKL("A"))
Selected_Text_Dictionary := Layout.Layouts_List[Text_Layout_Index].Full_Name
}
if (Selected_Text_Dictionary) {
Text_Dictionary_Index := Table.Get_Key_Index(Edit_Text.Dictionaries_Order, Selected_Text_Dictionary)
Next_Dictionary_Index := Text_Dictionary_Index + 1 > Edit_Text.Dictionaries_Order.MaxIndex() ? 1 : Text_Dictionary_Index + 1
Next_Dictionary_Name := Edit_Text.Dictionaries_Order[Next_Dictionary_Index]

MsgBox % Selected_Text_Dictionary "`n" Next_Dictionary_Name

Converted_Text := Edit_Text.Replace_By_Dictionaries(Selected_Text, Selected_Text_Dictionary, Next_Dictionary_Name)
Edit_Text.Paste(Converted_Text)

if (Next_Layout_Index :=  Layout.Get_Index_By_Name(Next_Dictionary_Name)) {
Next_Layout_HKL := Layout.Layouts_List[Next_Layout_Index].HKL
Layout.Change(Next_Layout_HKL,,system_switch_layouts_by_send)
Next_Layout_Full_Name := Layout.Layouts_List[Next_Layout_Index].Full_Name
Next_Layout_Display_Name := Layout.Layouts_List[Next_Layout_Index].Display_Name
ToolTip(Next_Layout_Full_Name " - " Next_Layout_Display_Name)
}
else {
ToolTip(Next_Dictionary_Name)
}
}
if (sound_enable and FileExist(sound_switch_text_layout)) {
SoundPlay %sound_switch_text_layout%
}
}
Sleep 50
Clipboard := "" ; Null
Clipboard := Clipboard_Tmp
ClipWait 0.05
return
}
*/

Get_Dictionaries(ByRef Config_File, ByRef Section, ByRef Prefix := "", ByRef Skip_Unused := False)
{ ; функция получения словарей из файла настроек
	static Dictionaries_List
	static Match
	static Key
	static Value
	;
	IniRead Dictionaries_List, %Config_File%, %Section%
	Edit_Text.Dictionaries := {}
	; Edit_Text.Dictionaries_Order := []
	Loop Parse, Dictionaries_List, `n, `r
	{
		if RegExMatch(A_LoopField, Prefix . "(.*?)=(.*)", Match) {
			Key := Trim(Match1)
			if (Skip_Unused and not Layout.Get_Index_By_Name(Key)) { ; пропуск словарей, для которых нет раскладки
				Continue
			}
			IniRead Value, %Config_File%, %Section%, % Prefix . Key
			Edit_Text.Dictionaries[Key] := Value
			; if not In_Array(Edit_Text.Dictionaries_Order, Key) {
			; Edit_Text.Dictionaries_Order.Push(Key)
			; }
			; MsgBox, % Prefix . Key "`n" Value
		}
	}
}

/*
Remove_Unused_Dictionaries()
{ ; функция удаления словарей, для которых нет раскладки
static Dictionary_Name
;
for Dictionary_Name in Edit_Text.Dictionaries
{
if (not Layout.Get_Index_By_Name(Dictionary_Name)) {
Edit_Text.Dictionaries.Delete(Dictionary_Name)
Edit_Text.Dictionaries_Order.Delete(Table.Get_Key_Index(Edit_Text.Dictionaries_Order, Dictionary_Name))
; MsgBox, % Dictionary_Name
}
}
}
*/

Get_Binds(ByRef Config_File, ByRef Section, ByRef Prefix := "")
{ ; функция получения назначений клавиш из файла настроек
	static Binds_List
	static Match
	static Match1
	static Key
	static Value
	;
	IniRead Binds_List, %Config_File%, %Section%
	Loop Parse, Binds_List, `n, `r
	{
		if RegExMatch(A_LoopField, Prefix . "(.*?)=(.*)", Match) {
			Key := Trim(Match1)
			IniRead Value, %Config_File%, %Section%, % Prefix . Key
			if (Value != "ERROR" and IsLabel(Key)) {
				Hotkey %Value%, %Key%, UseErrorLevel
				; MsgBox, % Key "`n" Value
			}
		}
	}
}

FLAG_Create_GUI:
{
	; Gui, FLAG_: Color, FFFFFF
	Gui FLAG_: -SysMenu +Owner -Caption +ToolWindow
	
	if (flag_always_on_top) {
		Gui FLAG_: +AlwaysOnTop
	}
	else {
		Gui FLAG_: -AlwaysOnTop
	}
	
	if (flag_show_borders) {
		Gui FLAG_: +Border
	}
	else {
		Gui FLAG_: -Border
	}
	
	Gui FLAG_: Show, w%flag_width% h%flag_height% x%flag_position_x% y%flag_position_y%
	Gui FLAG_: +LastFound
	WinGet flag_win_id, ID
	OnMessage(WM_LBUTTONDOWN := 0x201, "FLAG_WM_LBUTTONDOWN") ; Зажата LMB
	return
}

FLAG_GuiContextMenu:
{ ; Клик RMB по флагу (Gui, FLAG_:...)
	Menu Tray, Show
	return
}

FLAG_WM_LBUTTONDOWN()
{
	global flag_fixed_position
	if (flag_fixed_position) {
		return
	}
	PostMessage WM_NCLBUTTONDOWN := 0xA1, 2
	Sleep 250
	PostMessage WM_NCLBUTTONUP := 0xA2, 2
	gosub FLAG_Save_Position
	return
}

FLAG_Save_Position:
{
	WinGetPos flag_position_x, flag_position_y,,, ahk_id %flag_win_id%
	IniWrite("flag_position_x", Config_File, "Flag", flag_position_x)
	IniWrite("flag_position_y", Config_File, "Flag", flag_position_y)
	return
}

FLAG_Add_Picture:
{
	Gui FLAG_: Add, Picture, x0 y0 w%flag_width% h%flag_height% vFLAG_PICTURE
	return
}

FLAG_Update:
{
	if (flag_always_on_top) {
		if (flag_hide_in_fullscreen_mode and Window.Is_Full_Screen("A")) {
			; Gui, FLAG_: -AlwaysOnTop
			WinSet Bottom,, ahk_id %flag_win_id%
		}
		else {
			Gui FLAG_: +AlwaysOnTop
		}
	}
	Current_Layout_HKL := Layout.Get_HKL("A")
	if (not Current_Layout_HKL) {
		return
	}
	Current_Layout_Full_Name := Layout.Language_Name(Current_Layout_HKL, True)
	if (Current_Layout_Full_Name = Last_Layout_Full_Name) {
		return
	}
	gosub FLAG_Update_Picture
	if (system_show_tray_icon) {
		gosub FLAG_Update_Tray_Icon
	}
	Last_Layout_Full_Name := Current_Layout_Full_Name
	return
}

FLAG_Update_Picture:
{
	Current_Layout_Png := A_WorkingDir "\images\" Current_Layout_Full_Name ".png"
	GuiControl FLAG_:, FLAG_PICTURE, *x0 *y0 *w%flag_width% *h%flag_height% %Current_Layout_Png%
	return
}

FLAG_Update_Tray_Icon:
{
	Current_Layout_Ico := A_WorkingDir "\icons\" Current_Layout_Full_Name ".ico"
	if FileExist(Current_Layout_Ico) {
		Menu Tray, Icon, %Current_Layout_Ico%
	}
	else {
		Menu Tray, Icon, *
	}
	Menu Tray, Tip, %Current_Layout_Full_Name%
	return
}

FLAG_Customize_Menus:
{
	Menu Tray, NoStandard
	
	Menu Tray, Add, %l_system_suspend_hotkeys%, Menu_Toggle_Suspend
	if (system_suspend_hotkeys) {
		Suspend On
		Menu Tray, Check, %l_system_suspend_hotkeys%
	}
	
	Menu Tray, Add, %l_system_enable_auto_start%, Menu_Toggle_Auto_Start
	if (system_enable_auto_start and Task_Sheduler.Task_Exists(Auto_Run_Task_Name, A_ScriptFullPath)) {
		Menu Tray, Check, %l_system_enable_auto_start%
	}
	
	Menu Tray, Add, %l_system_start_with_admin_rights%, Menu_Toggle_Admin_Rights
	if (system_start_with_admin_rights) {
		Menu Tray, Check, %l_system_start_with_admin_rights%
	}
	
	Menu Tray, Add, %l_system_run_with_high_priority%, Menu_Toggle_High_Priority
	if (system_run_with_high_priority) {
		Menu Tray, Check, %l_system_run_with_high_priority%
	}
	
	Menu Tray, Add, %l_system_show_tray_icon%, Menu_Toggle_Show_Tray_Icon
	if (system_show_tray_icon) {
		Menu Tray, Check, %l_system_show_tray_icon%
		Menu Tray, Icon
	}
	else {
		Menu Tray, NoIcon
	}
	
	Menu Tray, Add, %l_sound_enable%, Menu_Toggle_Sound
	if (sound_enable) {
		Menu Tray, Check, %l_sound_enable%
	}
	
	Menu Tray, Add
	
	Menu Tray, Add, %l_system_skip_unused_dictionaries%, Menu_Toggle_Skip_Unused_Dictionaries
	if (system_skip_unused_dictionaries) {
		Menu Tray, Check, %l_system_skip_unused_dictionaries%
	}
	
	Menu Tray, Add, %l_system_fix_config_file_encoding%, Menu_Toggle_Fix_Config_File_Encoding
	if (system_fix_config_file_encoding) {
		Menu Tray, Check, %l_system_fix_config_file_encoding%
	}
	
	Menu Tray, Add, %l_system_switch_layouts_by_send%, Menu_Toggle_Switch_Layouts_By_Send
	if (system_switch_layouts_by_send) {
		Menu Tray, Check, %l_system_switch_layouts_by_send%
	}
	
	Menu Tray, Add
	
	Menu Tray, Add, %l_flag_show_borders%, Menu_Toggle_Show_Borders
	if (flag_show_borders) {
		Menu Tray, Check, %l_flag_show_borders%
	}
	
	Menu Tray, Add, %l_flag_always_on_top%, Menu_Toggle_Always_On_Top
	if (flag_always_on_top) {
		Menu Tray, Check, %l_flag_always_on_top%
	}
	
	Menu Tray, Add, %l_flag_fixed_position%, Menu_Toggle_Fixed_Position
	if (flag_fixed_position) {
		Menu Tray, Check, %l_flag_fixed_position%
	}
	
	Menu Tray, Add, %l_flag_hide_in_fullscreen_mode%, Menu_Toggle_Hide_In_Fullscreen_Mode
	if (flag_hide_in_fullscreen_mode) {
		Menu Tray, Check, %l_flag_hide_in_fullscreen_mode%
	}
	
	Menu Tray, Add
	
	Menu Tray, Add, %l_info_app_site%, Menu_App_Site
	if FileExist(info_updater) {
		Menu Tray, Add, %l_info_app_update%, Menu_App_Update
		MenuIcon("Tray", l_info_app_update, "Icons\Menu\Update.ico", 0, 0)
	}
	
	Menu Tray, Add
	
	Menu Tray, Add, %l_app_generate_dictionaries%, Menu_Generate_Dictionaries
	Menu Tray, Add, %l_app_options%, Menu_Options
	Menu Tray, Add, %l_app_restart%, Menu_Reload_App
	Menu Tray, Add, %l_app_exit%, Menu_Exit_App
	
	MenuIcon("Tray", l_info_app_site, "Icons\Menu\Home.ico", 0, 0)
	MenuIcon("Tray", l_app_generate_dictionaries, "Icons\Menu\Dictionaries.ico", 0, 0)
	MenuIcon("Tray", l_app_options, "Icons\Menu\Settings.ico", 0, 0)
	MenuIcon("Tray", l_app_restart, "Icons\Menu\Restart.ico", 0, 0)
	MenuIcon("Tray", l_app_exit, "Icons\Menu\Shutdown.ico", 0, 0)
	
	return
}

Menu_Toggle_Suspend:
{
	Menu Tray, ToggleCheck, %A_ThisMenuItem%
	system_suspend_hotkeys := not system_suspend_hotkeys
	IniWrite("system_suspend_hotkeys", Config_File, "System", system_suspend_hotkeys)
	Suspend Toggle
	return
}

Menu_Toggle_Auto_Start:
{
	Menu Tray, ToggleCheck, %A_ThisMenuItem%
	system_enable_auto_start := not system_enable_auto_start
	IniWrite("system_enable_auto_start", Config_File, "System", system_enable_auto_start)
	; Auto_Run_Task_Name := "CustomTasks\" "Layout_Switcher" ; Script_Name
	if (system_enable_auto_start) {
		Task_Sheduler.Create_Auto_Run_Task(Auto_Run_Task_Name, system_start_with_admin_rights, True)
	}
	else {
		Task_Sheduler.Delete_Task(Auto_Run_Task_Name)
	}
	return
}

Menu_Toggle_Admin_Rights:
{
	Menu Tray, ToggleCheck, %A_ThisMenuItem%
	system_start_with_admin_rights := not system_start_with_admin_rights
	IniWrite("system_start_with_admin_rights", Config_File, "System", system_start_with_admin_rights)
	if (system_enable_auto_start) {
		; Auto_Run_Task_Name := "CustomTasks\" "Layout_Switcher" ; Script_Name
		Task_Sheduler.Create_Auto_Run_Task(Auto_Run_Task_Name, system_start_with_admin_rights, True)
	}
	if (system_start_with_admin_rights) {
		Script.Run_As_Admin()
	}
	else {
		Reload
	}
	return
}

Menu_Toggle_High_Priority:
{
	Menu Tray, ToggleCheck, %A_ThisMenuItem%
	system_run_with_high_priority := not system_run_with_high_priority
	IniWrite("system_run_with_high_priority", Config_File, "System", system_run_with_high_priority)
	Reload
	return
}

Menu_Toggle_Show_Tray_Icon:
{
	Menu Tray, ToggleCheck, %A_ThisMenuItem%
	system_show_tray_icon := not system_show_tray_icon
	IniWrite("system_show_tray_icon", Config_File, "System", system_show_tray_icon)
	if (system_show_tray_icon) {
		Menu Tray, Icon
	}
	else {
		Menu Tray, NoIcon
	}
	return
}

Menu_Toggle_Sound:
{
	Menu Tray, ToggleCheck, %A_ThisMenuItem%
	sound_enable := not sound_enable
	IniWrite("sound_enable", Config_File, "Sound", sound_enable)
	return
}

Menu_Toggle_Skip_Unused_Dictionaries:
{
	Menu Tray, ToggleCheck, %A_ThisMenuItem%
	system_skip_unused_dictionaries := not system_skip_unused_dictionaries
	IniWrite("system_skip_unused_dictionaries", Config_File, "System", system_skip_unused_dictionaries)
	return
}

Menu_Toggle_Fix_Config_File_Encoding:
{
	Menu Tray, ToggleCheck, %A_ThisMenuItem%
	system_fix_config_file_encoding := not system_fix_config_file_encoding
	IniWrite("system_fix_config_file_encoding", Config_File, "System", system_fix_config_file_encoding)
	return
}

Menu_Toggle_Switch_Layouts_By_Send:
{
	Menu Tray, ToggleCheck, %A_ThisMenuItem%
	system_switch_layouts_by_send := not system_switch_layouts_by_send
	IniWrite("system_switch_layouts_by_send", Config_File, "System", system_switch_layouts_by_send)
	return
}

Menu_Toggle_Show_Borders:
{
	Menu Tray, ToggleCheck, %A_ThisMenuItem%
	flag_show_borders := not flag_show_borders
	IniWrite("flag_show_borders", Config_File, "Flag", flag_show_borders)
	if (flag_show_borders) {
		Gui FLAG_: +Border
	}
	else {
		Gui FLAG_: -Border
	}
	Gui FLAG_: Show, w%flag_width% h%flag_height%
	return
}

Menu_Toggle_Always_On_Top:
{
	Menu Tray, ToggleCheck, %A_ThisMenuItem%
	flag_always_on_top := not flag_always_on_top
	IniWrite("flag_always_on_top", Config_File, "Flag", flag_always_on_top)
	if (flag_always_on_top) {
		Gui FLAG_: +AlwaysOnTop
	}
	else {
		Gui FLAG_: -AlwaysOnTop
	}
	return
}

Menu_Toggle_Fixed_Position:
{
	Menu Tray, ToggleCheck, %A_ThisMenuItem%
	flag_fixed_position := not flag_fixed_position
	IniWrite("flag_fixed_position", Config_File, "Flag", flag_fixed_position)
	if (flag_always_on_top) {
		Gui FLAG_: +AlwaysOnTop
	}
	else {
		Gui FLAG_: -AlwaysOnTop
	}
	return
}

Menu_Toggle_Hide_In_Fullscreen_Mode:
{
	Menu Tray, ToggleCheck, %A_ThisMenuItem%
	flag_hide_in_fullscreen_mode := not flag_hide_in_fullscreen_mode
	IniWrite("flag_hide_in_fullscreen_mode", Config_File, "Flag", flag_hide_in_fullscreen_mode)
	if (flag_always_on_top) {
		Gui FLAG_: +AlwaysOnTop
	}
	else {
		Gui FLAG_: -AlwaysOnTop
	}
	return
}

Menu_App_Site:
{
	Run %info_app_site%
	return
}

Menu_App_Update:
{
	Run %info_updater% -app_pid="%App_PID%"
	return
}

Menu_Generate_Dictionaries:
{
	Generate_Dictionaries("dictionary_")
	return
}

Menu_Options:
{
	Run notepad.exe "%Config_File%"
	return
}

Menu_Reload_App:
{
	Reload
	return
}

Menu_Exit_App:
{
	ExitApp
	return
}

Generate_Dictionaries(ByRef Prefix := "")
{ ; функция создания словарей для текущих раскладок
	static Notepad_PID, Notepad_ID, Win_Title, Keys
	global system_switch_layouts_by_send
	;
	Run % "notepad.exe /W",,, Notepad_PID
	
	WinWait ahk_pid %Notepad_PID%
	WinGet Notepad_ID, ID, ahk_pid %Notepad_PID%
	
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
	
	WinActivate %Win_Title%
	WinWaitActive %Win_Title%
	
	static Layout_Index, Layout_Data
	static Dictionary_Name, k, v
	;
	for Layout_Index, Layout_Data in Layout.Layouts_List {
		WinActivate %Win_Title%
		WinWaitActive %Win_Title%
		IfWinActive %Win_Title%
		{
			while (Layout.Get_HKL(Win_Title) != Layout_Data.HKL and A_Index < 5) {
				Layout.Change(Layout_Data.HKL, Win_Title, system_switch_layouts_by_send)
				Sleep 50
			}
			if (Layout.Get_HKL(Win_Title) = Layout_Data.HKL) {
				Dictionary_Name := Prefix . Layout_Data.Full_Name
				StringLower Dictionary_Name, Dictionary_Name
				SendRaw %Dictionary_Name%=
				for k, v in Keys {
					Send {%v%}
				}
				Send {SC039}
				for k, v in Keys {
					Send +{%v%}
				}
				SendRaw % "`n"
			}
		}
	}
}

App_Close:
{
	SystemCursor("On")
	ExitApp
	return
}

#Include ..\Includes\FUNC_Normalize.ahk
#Include ..\Includes\FUNC_IniWrite.ahk
#Include ..\Includes\FUNC_ToolTip.ahk
#Include ..\Includes\FUNC_MenuIcon.ahk
#Include ..\Includes\FUNC_SystemCursor.ahk

#Include ..\Includes\FUNC_hexToDecimal.ahk ; необходим для CLASS_Task_Sheduler.ahk

#Include ..\Includes\CLASS_Script.ahk
#Include ..\Includes\CLASS_Task_Sheduler.ahk ; требует FUNC_hexToDecimal.ahk
#Include ..\Includes\CLASS_Windows.ahk
#Include ..\Includes\CLASS_Window.ahk
#Include ..\Includes\CLASS_Layout.ahk
#Include ..\Includes\CLASS_EditText.ahk

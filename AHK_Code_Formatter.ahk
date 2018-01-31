#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn, All, MsgBox ; Enable warnings to assist with detecting common errors.
SendMode, Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir, %A_ScriptDir% ; Ensures a consistent starting directory.

#SingleInstance, Force

; Your code here...

$_case_dictionary := __get_case_dictionary()
$_case_dictionary =%$_case_dictionary%
( LTrim RTrim Join`n
	%A_Space%
	StrReplace
)

$_comma_key_words_dictionary := __get_comma_key_words_dictionary()
$_comma_key_words_dictionary =%$_comma_key_words_dictionary%
( LTrim RTrim Join`n
	%A_Space%
	#Warn
	ListLines
	#KeyHistory
	#NoEnv
	Process
	#HotkeyInterval
	#MaxHotkeysPerInterval
	#SingleInstance
)

; Clipboard := $_case_dictionary
Clipboard := RegExReplace($_comma_key_words_dictionary, "\n", ",")

MsgBox,,, case_dictionary:`n-------------`n%$_case_dictionary%`n-------------`n, 1
MsgBox,,, comma_key_words_dictionary:`n-------------`n%$_comma_key_words_dictionary%`n-------------`n, 1

F11::
{
	$_code_text := __get_text()
	$_code_text := __fix_key_words_case($_code_text, $_case_dictionary)
	$_code_text := __fix_commas($_code_text, $_comma_key_words_dictionary)
	$_code_text := __paste_text($_code_text)
	return
}

Exit

__get_case_dictionary($_api_file := "")
{
	local
	$_api_file := $_api_file ? "" : A_ProgramFiles . "\AutoHotkey\SciTE\ahk.api"
	$_dictionary := "", $_key_word_count := 0
	if FileExist($_api_file) {
		Loop, Read, %$_api_file%
		{
			$_key_word_count++
			$_text_line := Trim(A_LoopReadLine)
			if ($_text_line = "") {
				continue
			}
			RegExMatch($_text_line, "^(([#.]|_{1,})?\w+).*", $_match_)
			if ($_key_word := Trim($_match_1)) {
				$_dictionary .= $_key_word_count = 1 ? "" : "`n"
				$_dictionary .= $_key_word
			}
		}
		Sort, $_dictionary, U
		return $_dictionary
	}
}

__escape($_string)
{
	local
	$_escape := ["\", ".", "*", "?", "+", "[", "]", "{", "}", "|", "(", ")", "^", "$"]
	for $_index, $_char in $_escape
	{
		$_string := StrReplace($_string, $_char, "\" . $_char)
	}
	return $_string
}

__get_text()
{
	Clipboard := ""
	Sleep, 50
	Send, ^c
	ClipWait, 1
	if (StrLen(Clipboard) > 0) {
		return Clipboard
	}
}

__paste_text($_string)
{
	Clipboard := ""
	Sleep, 50
	Clipboard := $_string
	ClipWait, 1
	if (StrLen(Clipboard) > 0) {
		Send, ^v
		return Clipboard
	}
}

__fix_case($_text_line, $_case_dictionary)
{
	local
	Loop, Parse, $_case_dictionary, `n, `r
	{
		$_key_word := A_LoopField
		$_has_symbols := RegExMatch($_key_word, "^([^\w]+)", $_symbols_)
		$_pattern := "i)" . ($_has_symbols ? __escape($_symbols_1) . "\b" . __escape($_key_word) . "\b" : "\b" . __escape($_key_word) . "\b")
		$_text_line := RegExReplace($_text_line, $_pattern, __escape($_key_word))
	}
	return $_text_line
}

__fix_key_words_case($_code_text, $_case_dictionary)
{
	local
	$_new_code_text := ""
	Loop, Parse, $_code_text, `n, `r
	{
		$_text_line := A_LoopField
		$_text_line := __fix_case($_text_line, $_case_dictionary)
		$_new_code_text .= A_Index = 1 ? "" : "`n"
		$_new_code_text .= $_text_line
	}
	return $_new_code_text
}

__get_comma_key_words_dictionary($_api_file := "")
{
	local
	$_api_file := $_api_file ? "" : A_ProgramFiles . "\AutoHotkey\SciTE\ahk.api"
	$_exlude := "\b(for)\b"
	$_dictionary := "", $_key_word_count := 0
	if FileExist($_api_file) {
		Loop, Read, % $_api_file
		{
			$_key_word_count++
			$_text_line := Trim(A_LoopReadLine)
			if ($_text_line = "") {
				continue
			}
			RegExMatch($_text_line, "^(.*?)\[?,", $_match_)
			if ($_key_word := Trim($_match_1)) {
				if RegExMatch($_key_word, $_exlude) {
					continue
				}
				if !RegExMatch($_key_word, "\(|\[") {
					$_dictionary .= $_key_word_count = 1 ? "" : "`n"
					$_dictionary .= $_key_word
				}
			}
		}
		Sort, $_dictionary, U
		return $_dictionary
	}
}

__fix_commas($_code_text, $_comma_key_words_dictionary)
{
	local
	$_new_code_text := ""
	Loop, Parse, $_code_text, `n, `r
	{
		$_text_line := A_LoopField
		if RegExMatch($_text_line, "^([;~]?(?:[\t ]+)?)(([^\w]+)?\b\w+\b)([\t ]{1,})([^\s])", $_match_) {
			$_key_word := $_match_2
			$_has_symbols := RegExMatch($_key_word, "^([^\w]+)", $_symbols_)
			$_pattern := "i)" . ($_has_symbols ? __escape($_symbols_1) . "\b" . __escape($_key_word) . "\b" : "\b" . __escape($_key_word) . "\b")
			;
			if RegExMatch($_comma_key_words_dictionary, $_pattern, $_match_) {
				if RegExMatch($_text_line, "i)" . "^([;~]?(?:[\t ]+)?)" . __escape($_key_word) . "\b" . "([\t ]{1,})([^\s]+)", $_match_) {
					$_params_or_something := $_match_3
					$_math_symbols_regex := "\+\+|\-\-|\-\=|\+\=|\*\=|\/\=|\:\=|\.="
					if !RegExMatch($_params_or_something, $_math_symbols_regex) {
						$_text_line := RegExReplace($_text_line, "i)" . "^([;~]?(?:[\t ]+)?)" . __escape($_key_word) . "\b" . "([\t ]{1,})([^\s])", "$_1" . __escape($_key_word) . ",$_2$_3", 1)
						$_text_line := RegExReplace($_text_line, "i)" . __escape($_key_word) . "\b" . ",([\t ]+;)", __escape($_key_word) . "$_1", 1)
					}
				}
			}
		}
		if RegExMatch($_text_line, ",[ \t]+,") {
			Loop, 2
			{
				$_text_line := RegExReplace($_text_line, ",[ \t]+,", ",,")
			}
		}
		$_new_code_text .= A_Index = 1 ? "" : "`n"
		$_new_code_text .= $_text_line
	}
	return $_new_code_text
}

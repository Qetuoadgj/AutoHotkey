#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn, All, MsgBox ; Enable warnings to assist with detecting common errors.
SendMode, Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir, %A_ScriptDir% ; Ensures a consistent starting directory.

; #Persistent
#SingleInstance, Ignore

; #SingleInstance, Off
; Script_Name := Script.Name()
; Script_Args := Script.Args()
; Script.Force_Single_Instance([RegExReplace(Script_Name, "_x(32|64)", "") . "*"])
; Script.Run_As_Admin(Script_Args)

ComSpecPID := 0
OnExit, ExitSub

ffmpeg := ""
Loop, Files, ffmpeg.exe, FR
{
	ffmpeg := A_LoopFileLongPath
}

MsgBox,,, ffmpeg:`n%ffmpeg%, 1

if (ffmpeg != "") {
	gosub, CreateGUI
	;
	return
}

ExitApp
; Exit

F11::
{
	ExitApp
	return
}

LongPath(Path)
{
	Loop, Files, %Path%, FD
	{
		return A_LoopFileLongPath
	}
	return Path
}

/*
GetFileEncoding(FilePath)
{
	static File, Encoding
	File := FileOpen(FilePath, "r")
	Encoding := File.Encoding
	File.Close()
	return %Encoding%
}
*/

StrPutVar(string, ByRef var, encoding)
{
	; Ensure capacity.
	VarSetCapacity( var, StrPut(string, encoding)
	; StrPut returns char count, but VarSetCapacity needs bytes.
	* ((encoding="utf-16"||encoding="cp1200") ? 2 : 1) )
	; Copy or convert the string.
	return StrPut(string, &var, encoding)
}

Convert:
{
	InputFileTitle := ""
	for i, a in A_Args {
		if FileExist(a) {
			InputFileLongPath := LongPath(a)
			SplitPath, InputFileLongPath, InputFileFullName, InputFileDir, InputFileExtension, InputFileNameNoExt, InputFileDrive
			if (InputFileExtension = "MKV") {
				MsgBox,,, %i%. %InputFileLongPath%, 1
				; ------ конвертация в AVI ------
				StrPutVar(InputFileTitle, InputFileTitle, "CP1251")
				OutputFileLongPath := InputFileLongPath . ".avi"
				SplitPath, OutputFileLongPath, OutputFileFullName, OutputFileDir, OutputFileExtension, OutputFileNameNoExt, OutputFileDrive
				; MsgBox, MediaInfoFileEncoding: %MediaInfoFileEncoding%`nInputFileTitle: %InputFileTitle%
				/*
				video_format		:= "-f " . "avi"				; "avi"
				video_codec			:= "-c:v " . "mpeg4"			; "mpeg4"
				video_bitrate		:= "-b:v " . "574k"				; "4000k"
				audio_codec			:= "-c:a " . "libmp3lame"		; "libmp3lame"
				audio_bitrate		:= "-b:a " . "128k"				; "320k"
				audio_samplerate	:= "-ar 44100"					; ""
				audio_channels		:= "-ac 2"						; ""
				audio_volume		:= "-vol " . Round(256 / 1, 0)	; "-vol 256"
				lang_settings		:= "-map 0:0 -map 0:2"			; выбор звуковой дорожки по умолчанию
				lang_settings		:= ""
				*/
				; -map 0:m:language:eng
				; "%ffmpeg%" -i "%InputFileLongPath%" -f avi -c:v %video_codec% -b:v %video_bitrate% -c:a %audio_codec% -b:a %audio_bitrate% -ar %audio_samplerate% -metadata title="%InputFileTitle%" "%OutputFileLongPath%"
				; "%ffmpeg%" -i "%InputFileLongPath%" %lang_settings% -c:v %video_codec% -b:v %video_bitrate% -c:a %audio_codec% -b:a %audio_bitrate% %audio_samplerate% %audio_volume% %audio_channels% -metadata title="%InputFileTitle%" -f %video_format% "%OutputFileLongPath%"
				CmdCommand = 
				( Ltrim RTrim Join&
					@echo off
					title %InputFileFullName% --^> %OutputFileFullName% : %video_bitrate%
					"%ffmpeg%" -i "%InputFileLongPath%" %lang_settings% %video_codec% %video_bitrate% %audio_codec% %audio_bitrate% %audio_samplerate% %audio_volume% %audio_channels% -metadata title="%InputFileTitle%" %video_format% "%OutputFileLongPath%"
					timeout 3
				)
				; MsgBox, %CmdCommand%
				FileRecycle, %OutputFileLongPath%
				RunWait, %ComSpec% /c %CmdCommand%,,, ComSpecPID
			}
		}
	}
	ExitApp
	return
}

ExitSub:
{
	ComSpecID := WinExist("ahk_exe cmd.exe ahk_pid " . ComSpecPID)
	WinClose, ahk_id %ComSpecID%
	;
	Script_Name := ""
	MsgBox, 262144, %Script_Name%, % "OK", 1
	ExitApp
}

CreateGUI:
{
	Gui, Add, Text, x280 y16 w90 h23 +0x200, Container
	Gui, Add, Text, x280 y64 w90 h23 +0x200, Codec
	Gui, Add, GroupBox, x272 y0 w210 h49, Format
	Gui, Add, ComboBox, x378 y16 w95 vGUI_VIDEO_FORMAT, % "avi||"
	Gui, Add, GroupBox, x272 y48 w210 h73, Video
	Gui, Add, ComboBox, x378 y64 w95 vGUI_VIDEO_CODEC, % "mpeg4||"
	Gui, Add, Text, x280 y88 w90 h23 +0x200, Bitrate
	Gui, Add, ComboBox, x378 y88 w95 vGUI_VIDEO_BITRATE, % "Min|574||750|1000|1500|2000|2500|3000" ; 574k ; File size = bitrate (kilobits per second) x duration
	Gui, Add, GroupBox, x0 y0 w266 h169, Audio
	Gui, Add, Text, x8 y16 w120 h23 +0x200, Codec
	Gui, Add, ComboBox, x136 y16 w120 vGUI_AUDIO_CODEC, % "libmp3lame||"
	Gui, Add, Text, x8 y40 w120 h23 +0x200, Bitrate
	Gui, Add, ComboBox, x136 y40 w120 vGUI_AUDIO_BITRATE, % "Source|128||192|320" ; 128k
	Gui, Add, Text, x8 y64 w120 h23 +0x200, Sample Rate
	Gui, Add, Text, x8 y88 w120 h23 +0x200, Channels
	Gui, Add, ComboBox, x136 y64 w120 vGUI_AUDIO_SAMPLERATE, % "Source|16000|22050|44100||48000|96000" ; -ar 44100
	Gui, Add, ComboBox, x136 y88 w120 vGUI_AUDIO_CHANNELS, % "Source|1|2||5" ; -ac 2
	Gui, Add, Text, x8 y112 w120 h23 +0x200 , Volume
	Gui, Add, ComboBox, x136 y112 w120 vGUI_AUDIO_VOLUME, % "0.50|0.75|Source||1.25|1.50|2.00" 
	Gui, Add, ComboBox, x136 y136 w120 vGUI_AUDIO_LANG, % "Default||1|2|3|4|5|6|7|8|9|10" ; -ac 2
	Gui, Add, Text, x8 y136 w120 h23 +0x200, Language
	Gui, Add, Button, x272 y127 w208 h40 gGetGUIValues, &OK
	;
	Gui, Show, w484 h171, Window
	return
}

GetGUIValues:
{
	defaults := ["Default", "Source", 0, "", "Min"]
	Gui, Submit, Hide
	;
	; GUI_VIDEO_FORMAT
	; GUI_VIDEO_CODEC
	; GUI_VIDEO_BITRATE
	; GUI_AUDIO_CODEC
	; GUI_AUDIO_SAMPLERATE
	; GUI_AUDIO_BITRATE
	; GUI_AUDIO_CHANNELS
	; GUI_AUDIO_VOLUME
	; GUI_AUDIO_LANG
	;	
	video_format		:= Normalize(GUI_VIDEO_FORMAT, defaults, "avi", "-f ", "")					; "avi"
	video_codec			:= Normalize(GUI_VIDEO_CODEC, defaults, "-c:v mpeg4", "-c:v ", "")			; "mpeg4"
	video_bitrate		:= Normalize(Round(GUI_VIDEO_BITRATE, 0), defaults, "", "-b:v ", "k")		; "574k"
	;
	audio_codec			:= Normalize(GUI_AUDIO_CODEC, defaults, "-c:a libmp3lame", "-c:a ", "")		; "libmp3lame"
	audio_bitrate		:= Normalize(Round(GUI_AUDIO_BITRATE, 0), defaults, "", "-b:a ", "k")		; "128k"
	audio_samplerate	:= Normalize(Round(GUI_AUDIO_SAMPLERATE, 0), defaults, "", "-ar ", "")		; "-ar 44100"
	audio_channels		:= Normalize(Round(GUI_AUDIO_CHANNELS, 0), defaults, "", "-ac ", "")		; "-ac 2"
	audio_volume		:= Normalize(Round(GUI_AUDIO_VOLUME * 256, 0), defaults, "", "-vol ", "")	; "-vol 256"
	;
	lang_settings		:= Normalize(GUI_AUDIO_LANG, defaults, "", "-map 0:0 -map 0:", "")			; "-map 0:0 -map 0:2
	;
	msgText =
	( LTrim Rtrim Join`r`n
		video_format:`t%video_format%
		video_codec:`t%video_codec%
		video_bitrate:`t%video_bitrate%
		
		audio_codec:`t%audio_codec%
		audio_bitrate:`t%audio_bitrate%
		audio_samplerate:`t%audio_samplerate%
		audio_channels:`t%audio_channels%
		audio_volume:`t%audio_volume%
		
		lang_settings:`t%lang_settings%
	)
	MsgBox, 262145,, %msgText% ;, 5
	IfMsgBox, Cancel
	{
		Gui, Show, w484 h171, Window
		return
	}
	;
	; "%ffmpeg%" -i "%InputFileLongPath%" %lang_settings% %video_codec% %video_bitrate% %audio_codec% %audio_bitrate% %audio_samplerate% %audio_volume% %audio_channels% -metadata title="%InputFileTitle%" %video_format% "%OutputFileLongPath%"
	;
	gosub, StartFilesProcessing
	return
}

Normalize(Value, DefTest, DefVal, Suffix := "", Prefix := "")
{
	if IsObject(DefTest) {
		for k, v in DefTest {
			if (Trim(Value) = Trim(v)) {
				return DefVal
			}
		}
	}
	else {
		if (Trim(Value) = Trim(DefTest)) {
			return DefVal
		}
	}
	return Suffix . Trim(Value) . Prefix
}

StartFilesProcessing:
{
	gosub, Convert
	return
}

GuiEscape:
GuiClose:
{
    ExitApp
	return
}

; #Include D:\Google Диск\AutoHotkey\Includes\CLASS_Script.ahk

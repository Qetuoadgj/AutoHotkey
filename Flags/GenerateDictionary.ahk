;~ https://github.com/Qetuoadgj/AutoHotkey/tree/master/Flags

#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
;~ #Warn ; Enable warnings to assist with detecting common errors.
SendMode,Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir,%A_ScriptDir% ; Ensures a consistent starting directory.

#SingleInstance,Force
ForceSingleInstance()

Keys:=["SC029","SC002","SC003","SC004","SC005","SC006","SC007","SC008","SC009","SC00A","SC00B","SC00C","SC00D","SC010","SC011","SC012","SC013","SC014","SC015","SC016","SC017","SC018","SC019","SC01A","SC01B","SC01E","SC01F","SC020","SC021","SC022","SC023","SC024","SC025","SC026","SC027","SC028","SC02B","SC02C","SC02D","SC02E","SC02F","SC030","SC031","SC032","SC033","SC034","SC035"]
F11::
	For k,v in Keys {
		Send,{%v%}
	}
	For k,v in Keys {
		Send,+{%v%}
	}
Return
;~ `1234567890-=qwertyuiop[]asdfghjkl;'\zxcvbnm,./~!@#$%^&*()_+QWERTYUIOP{}ASDFGHJKL:"|ZXCVBNM<>?
;~ ¸1234567890-=éöóêåíãøùçõúôûâàïğîëäæı\ÿ÷ñìèòüáş.¨!"¹;%:?*()_+ÉÖÓÊÅÍÃØÙÇÕÚÔÛÂÀÏĞÎËÄÆİ/ß×ÑÌÈÒÜÁŞ,
;~ ¸1234567890-=éöóêåíãøùçõ¿ô³âàïğîëäæº\ÿ÷ñìèòüáş.¨!"¹;%:?*()_+ÉÖÓÊÅÍÃØÙÇÕ¯Ô²ÂÀÏĞÎËÄÆª/ß×ÑÌÈÒÜÁŞ,
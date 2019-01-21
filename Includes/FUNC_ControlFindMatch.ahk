ControlFindMatch(ClassNNRegEx, ControlTextRegEx := "", WinTitle := "A", ReturnValue := "ClassNN", SearchInList := 0)
{
	local
	WinGet, CtrlList, ControlList, %WinTitle% ; Get controls
	Loop, Parse, CtrlList, `n
	{
		Control := A_LoopField
		if (RegExMatch(A_LoopField, ClassNNRegEx)) { ; RegEx match dynamic ClassNN
			if (SearchInList) {
				ControlGet, ControlText, List,, %Control%, %WinTitle%
				Loop, Parse, ControlText, `n, `r
				{
					if (RegExMatch(A_LoopField, ControlTextRegEx)) { ; RegEx match control text
						if (ReturnValue = "hWnd") {
							ControlGet, ReturnValue, Hwnd,, %Control%, %WinTitle%
							return ReturnValue
						}
						else if (ReturnValue = "ClassNN") {
							return Control
						}
						return Control
					}
				}
			}
			else {
				ControlGetText, ControlText, %Control%, %WinTitle%
				if (RegExMatch(ControlText, ControlTextRegEx)) { ; RegEx match control text
					if (ReturnValue = "hWnd") {
						ControlGet, ReturnValue, Hwnd,, %Control%, %WinTitle%
						return ReturnValue
					}
					else if (ReturnValue = "ClassNN") {
						return Control
					}
					return Control
				}
			}
		}
	}
}

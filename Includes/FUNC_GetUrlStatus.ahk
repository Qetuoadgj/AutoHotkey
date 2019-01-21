; --------------------------------------------------------------------------------------------
GetUrlStatus(URL, Timeout = -1)
{ ; проверка статуса URL
	local
	ComObjError(0)
	WinHttpReq := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	
	WinHttpReq.Open("HEAD", URL, True)
	WinHttpReq.Send()
	WinHttpReq.WaitForResponse(Timeout) ; return: Success = -1, Timeout = 0, No response = Empty String
	
	return WinHttpReq.Status()
}
; --------------------------------------------------------------------------------------------
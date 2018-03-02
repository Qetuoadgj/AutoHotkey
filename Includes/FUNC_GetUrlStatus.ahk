; --------------------------------------------------------------------------------------------
GetUrlStatus(URL, Timeout = -1)
{ ; �������� ������� URL
	ComObjError(0)
	static WinHttpReq := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	
	WinHttpReq.Open("HEAD", URL, True)
	WinHttpReq.Send()
	WinHttpReq.WaitForResponse(Timeout) ; return: Success = -1, Timeout = 0, No response = Empty String
	
	return WinHttpReq.Status()
}
; --------------------------------------------------------------------------------------------
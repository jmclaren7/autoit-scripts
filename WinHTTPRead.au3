;===============================================================================
;
; Description:
;
; Parameter(s):     Required :
;                   Optional :
; Return Value(s):  On Success -
;                   On Failure -
; Author(s):
;
;===============================================================================
Func _WinHTTPRead($sURL, $Agent)
	; Open needed handles
	Local $hOpen = _WinHttpOpen($Agent)
	Local $Connect = StringTrimLeft(StringLeft($sURL,StringInStr($sURL,"/",0,3)-1),7)
	Local $hConnect = _WinHttpConnect($hOpen, $Connect)

	; Specify the reguest:
	Local $RequestURL = StringTrimLeft($sURL,StringInStr($sURL,"/",0,3))
	Local $hRequest = _WinHttpOpenRequest($hConnect, Default, $RequestURL)

	;_WinHttpAddRequestHeaders ($hRequest, "Cache-Control: max-age=0")
	;_WinHttpAddRequestHeaders ($hRequest, "Upgrade-Insecure-Requests: 1")
	_WinHttpAddRequestHeaders ($hRequest, "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3")
	;_WinHttpAddRequestHeaders ($hRequest, "Accept-Encoding: gzip, deflate")
	;_WinHttpAddRequestHeaders ($hRequest, "Accept-Language: en-US,en;q=0.9,en-GB;q=0.8")

	; Send request
	_WinHttpSendRequest($hRequest)

	; Wait for the response
	_WinHttpReceiveResponse($hRequest)

	Local $sHeader = _WinHttpQueryHeaders($hRequest) ; ...get full header

	Local $bData, $bChunk
	While 1
		$bChunk = _WinHttpReadData($hRequest, 2)
		If @error Then ExitLoop
		$bData = _WinHttpBinaryConcat($bData, $bChunk)
	WEnd

	; Clean
	_WinHttpCloseHandle($hRequest)
	_WinHttpCloseHandle($hConnect)
	_WinHttpCloseHandle($hOpen)

	Return $bData

EndFunc
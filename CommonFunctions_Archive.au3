#include-once
;===============================================================================
;
; Description:      GetUnixTimeStamp - Get time as Unix timestamp value for a specified date
;                   to get the current time stamp call GetUnixTimeStamp with no parameters
;                   beware the current time stamp has system UTC included to get timestamp with UTC + 0
;                   substract your UTC , exemple your UTC is +2 use GetUnixTimeStamp() - 2*3600
; Parameter(s):     Requierd : None
;                   Optional :
;                               - $year => Year ex : 1970 to 2038
;                               - $mon  => Month ex : 1 to 12
;                               - $days => Day ex : 1 to Max Day OF Month
;                               - $hour => Hour ex : 0 to 23
;                               - $min  => Minutes ex : 1 to 60
;                               - $sec  => Seconds ex : 1 to 60
; Return Value(s):  On Success - Returns Unix timestamp
;                   On Failure - No Failure if valid parameters are valid
; Author(s):        azrael-sub7
; User Calltip:     GetUnixTimeStamp() (required: <_AzUnixTime.au3>)
;
;===============================================================================
Func _GetUnixTimeStamp($year = 0, $mon = 0, $days = 0, $hour = 0, $Min = 0, $sec = 0)
	If $year = 0 Then $year = Number(@YEAR)
	If $mon = 0 Then $mon = Number(@MON)
	If $days = 0 Then $days = Number(@MDAY)
	If $hour = 0 Then $hour = Number(@HOUR)
	If $Min = 0 Then $Min = Number(@MIN)
	If $sec = 0 Then $sec = Number(@SEC)
	Local $NormalYears = 0
	Local $LeepYears = 0
	For $i = 1970 To $year - 1 Step +1
		If Mod($i, 400) = 0 Or Mod($i, 4) = 0 Then
			$LeepYears = $LeepYears + 1
		Else
			$NormalYears = $NormalYears + 1
		EndIf
	Next
	Local $yearNum = (366 * $LeepYears * 24 * 3600) + (365 * $NormalYears * 24 * 3600)
	Local $MonNum = 0
	For $i = 1 To $mon - 1 Step +1
		$MonNum = $MonNum + _LastDayInMonth($year, $i)
	Next
	Return $yearNum + ($MonNum * 24 * 3600) + (($days - 1) * 24 * 3600) + $hour * 3600 + $Min * 60 + $sec
EndFunc   ;==>_GetUnixTimeStamp

;===============================================================================
;
; Description:      UnixTimeStampToTime - Converts UnixTime to Date
; Parameter(s):     Required : $UnixTimeStamp => UnixTime ex : 1102141493
;                   Optional : None
; Return Value(s):  On Success - Returns Array
;                               - $Array[0] => Year ex : 1970 to 2038
;                               - $Array[1] => Month ex : 1 to 12
;                               - $Array[2] => Day ex : 1 to Max Day OF Month
;                               - $Array[3] => Hour ex : 0 to 23
;                               - $Array[4] => Minutes ex : 1 to 60
;                               - $Array[5] => Seconds ex : 1 to 60
;                   On Failure  - No Failure if valid parameter is a valid UnixTimeStamp
; Author(s):        azrael-sub7
; User Calltip:     UnixTimeStampToTime() (required: <_AzUnixTime.au3>)
;===============================================================================
Func _UnixTimeStampToTime($UnixTimeStamp)
	Dim $pTime[6]
	$pTime[0] = Floor($UnixTimeStamp / 31436000) + 1970 ; pTYear

	Local $pLeap = Floor(($pTime[0] - 1969) / 4)
	Local $pDays = Floor($UnixTimeStamp / 86400)
	$pDays = $pDays - $pLeap
	$pDaysSnEp = Mod($pDays, 365)

	$pTime[1] = 1 ;$pTMon
	$pTime[2] = $pDaysSnEp ;$pTDays

	If $pTime[2] > 59 And _BoolLeapYear($pTime[0]) = True Then $pTime[2] += 1

	While 1
		If ($pTime[2] > 31) Then
			$pTime[2] = $pTime[2] - _LastDayInMonth($pTime[1])
			$pTime[1] = $pTime[1] + 1
		Else
			ExitLoop
		EndIf
	WEnd

	Local $pSec = $UnixTimeStamp - ($pDays + $pLeap) * 86400

	$pTime[3] = Floor($pSec / 3600) ; $pTHour
	$pTime[4] = Floor(($pSec - ($pTime[3] * 3600)) / 60) ;$pTmin
	$pTime[5] = ($pSec - ($pTime[3] * 3600)) - ($pTime[4] * 60) ; $pTSec

	Return $pTime
EndFunc   ;==>_UnixTimeStampToTime

;===============================================================================
;
; Description:      BoolLeapYear - Check if Year is Leap Year
; Parameter(s):     Requierd : $year => Year to check ex : 2011
;                   Optional : None
; Return Value(s):  True if $year is Leap Year else False
; Author(s):        azrael-sub7
; User Calltip:     BoolLeapYear() (required: <_AzUnixTime.au3>)
; Credits :         Wikipedia Leap Year
;===============================================================================
Func _BoolLeapYear($year)
	If Mod($year, 400) = 0 Then
		Return True ;is_leap_year
	ElseIf Mod($year, 100) = 0 Then
		Return False ;is_not_leap_y
	ElseIf Mod($year, 4) = 0 Then
		Return True ;is_leap_year
	Else
		Return False ;is_not_leap_y
	EndIf
EndFunc   ;==>_BoolLeapYear

;===============================================================================
;
; Description:      _LastDayInMonth
;                   if the function is called with no parameters it returns maximum days for current system set month
;                   else it returns maximum days for the specified month in specified year
; Parameter(s):     Requierd : None
;                   Optional :
;                               - $year : year : 1970 to 2038
;                               - $mon : month : 1 to 12
; Return Value(s):
; Author(s):        azrael-sub7
; User Calltip:
;===============================================================================
Func _LastDayInMonth($year = @YEAR, $mon = @MON)
	If Number($mon) = 2 Then
		If _BoolLeapYear($year) = True Then
			Return 29 ;is_leap_year
		Else
			Return 28 ;is_not_leap_y
		EndIf
	Else
		If $mon < 8 Then
			If Mod($mon, 2) = 0 Then
				Return 30
			Else
				Return 31
			EndIf
		Else
			If Mod($mon, 2) = 1 Then
				Return 30
			Else
				Return 31
			EndIf
		EndIf
	EndIf
EndFunc   ;==>_LastDayInMonth
;===============================================================================
; Function Name:    _TreeList()
; Description:		Returns a list of files and directories in a tree structure
; Call With:		_TreeList($Path, $mode = 1)
; Parameter(s): 	$Path - Path to list
;					$Mode - 1 = Files and Directories, 2 = Only Directories
; Return Value(s):  On Success - Array of files and directories
; 					On Failure - Empty array
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		06/02/2011  --  v1.0
;===============================================================================
Func _TreeList($Path, $Mode = 1)
	Local $aFileList_Original = _FileListToArray($Path, "*", 0)
	Local $aFileList[1], $FullPath

	For $i = 1 To UBound($aFileList_Original) - 1
		$FullPath = $Path & "\" & $FileList_Original[$i]
		If StringInStr(FileGetAttrib($FullPath), "D") Then
			Local $aFoundDirectory = _TreeList($FullPath, $Mode)
			_ArrayConcatenate($aFileList, $aFoundDirectory, 1)
		Else
			ReDim $FileList[UBound($aFileList) + 1]
			$FileList[UBound($aFileList) - 1] = $FullPath
		EndIf
	Next

	Return $FileList
EndFunc   ;==>_TreeList
;===============================================================================
; Function Name:    _sini()
; Description:		Easily create or work with 2d arrays, such as the ones produced by INIReadSection()
; Call With:		_sini(ByRef $Array, $Key[, $Value[, $Extended]])
; Parameter(s): 	$Array - A previously declared array, if not array, it will be made as one
;					$Key - The value to look for in the first column/dimention or the "Key" in an INI section
;		(Optional)	$Value - The value to write to the array
;		(Optional)	$Extended - Special options turned on by adding a letter to this string (See notes)
;
; Return Value(s):  On Success - The value found or set
; 					On Failure - "" and sets @error to 1 if value is not found ($Extended can override this)
;
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		01/29/2010  --  v1.0
; Notes:            $Array[0][0] Contains the number of stored parameters
;					Special $Extended Codes:
;						d=value passed is used as default value IF key doesnt already have a value
;						D=d+Check for default value in global var $default_xxx
;						e=encrypt/decrypt value
;						E=e+Use the computers hardware key to encrypt/decrypt
; Example:			_sini($Settings,"trayicon","1","d")
;===============================================================================
Func _sini(ByRef $Array, $Key, $Value = Default, $Extended = "")
	Local $Alert = 0
	If $Value = Default Then $Alert = 1

	If Not IsArray($Array) Then Dim $Array[1][2]
	If StringInStr($Extended, "E", 1) Then $Pass = DriveGetSerial(StringLeft(@WindowsDir, 2)) & @CPUArch & @OSBuild & $Key
	If StringInStr($Extended, "e", 1) Then $Pass = "a1e2i3o4u5y6" & $Key

	For $i = 1 To UBound($Array) - 1 ;Check for existing key
		If $Array[$i][0] = $Key Then
			If $Value = Default Or StringInStr($Extended, "D", 1) Or ($Value = "" And StringInStr($Extended, "d") = 0) Then ;Read Existing Value
				If StringInStr($Extended, "e") Then
					$decrypt = 0 ;_StringEncrypt(0,$array[$i][1],$Pass,2)
					If $decrypt = 0 Then $decrypt = ""
					Return $decrypt
				Else
					Return $Array[$i][1]
				EndIf
			Else
				If StringInStr($Extended, "e") Then               ;Change Existing Value
					$Array[$i][1] = 0 ;_StringEncrypt(1,$Value,$Pass,2)
				Else
					$Array[$i][1] = $Value
				EndIf
				$Array[0][0] = UBound($Array) - 1
				Return $Value
			EndIf
		EndIf
	Next

	If ($Value = "" Or $Value = Default) And StringInStr($Extended, "D", 1) Then $Value = Eval("default_" & $Key)

	If $Value = Default Then
		MsgBox(48, "Error In " & @ScriptName, "Missing Value For Setting """ & $Key & """" & @CRLF & "Press Ok To Continue")
	Else
		$iUBound = UBound($Array)
		ReDim $Array[$iUBound + 1][2]
		$Array[$iUBound][0] = $Key
		$Array[$iUBound][1] = $Value
		If StringInStr($Extended, "e") Then $Array[$iUBound][1] = 0 ;_StringEncrypt(1,$Value,$Pass,2)
		$Array[0][0] = UBound($Array) - 1
		Return $Value
	EndIf

	SetError(1)
	Return ""
EndFunc   ;==>_sini

;===============================================================================
; Function Name:   	_ConsoleWrite()
; Description:		Console & File Loging
; Call With:		_ConsoleWrite($Text,$SameLine)
; Parameter(s): 	$Text - Text to print
;					$Level - The level the given message *is*
;					$SameLine - (Optional) Will continue to print on the same line if set to 1, replace line if set to 2
;
; Return Value(s):  The Text Originaly Sent
; Notes:			Checks if global $LogToFile=1 or $CmdLineRaw contains "-debuglog" to see if log file should be writen
;					If Text = "OPENLOG" then log file is displayed (casesense)
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		05/05/2022 --  V1.3 Added $iSameLine option value "2" which will replace the current line
;					06/12/2019 --  v1.2 Added back -debuglog switch and updated notes
;					06/1/2012  --  v1.1
;===============================================================================
Func _ConsoleWrite($sMessage, $iLevel = 1, $iSameLine = 0)
	Local $hHandle, $sData

	If Eval("LogFilePath") = "" Then Global $LogFilePath = StringTrimRight(@ScriptFullPath, 4) & "_Log.txt"
	If Eval("LogFileMaxSize") = "" Then Global $LogFileMaxSize = 0
	If Eval("LogToFile") = "" Then Global $LogToFile = False
	If StringInStr($CmdLineRaw, "-debuglog") Then Global $LogToFile = True
	If Eval("LogLevel") = "" Then Global $LogLevel = 3 ; The level of message to log - If no level set to 3

	If $sMessage == "OPENLOG" Then Return ShellExecute($LogFilePath)

	If $iLevel <= $LogLevel Then
		$sMessage = StringReplace($sMessage, @CRLF & @CRLF, @CRLF) ;Remove Double CR
		If StringRight($sMessage, StringLen(@CRLF)) = @CRLF Then $sMessage = StringTrimRight($sMessage, StringLen(@CRLF)) ; Remove last CR

		; Generate Timestamp
		Local $sTime = @YEAR & "-" & @MON & "-" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC & "> "

		; Force CRLF
		$sMessage = StringRegExpReplace($sMessage, "((?<!\x0d)\x0a|\x0d(?!\x0a))", @CRLF)

		; Adds spaces for alignment after initial line
		$sMessage = StringReplace($sMessage, @CRLF, @CRLF & _StringRepeat(" ", StringLen($sTime)))

		If $iSameLine = 0 Then $sMessage = @CRLF & $sTime & $sMessage
		If $iSameLine = 2 Then $sMessage = @CR & $sTime & $sMessage

		ConsoleWrite($sMessage)

		If $LogToFile Then
			If $LogFileMaxSize <> 0 And FileGetSize($LogFilePath) > $LogFileMaxSize * 1024 Then
				$sMessage = FileRead($LogFilePath) & $sMessage
				$sMessage = StringTrimLeft($sMessage, StringInStr($sMessage, @CRLF, 0, 5))
				$hHandle = FileOpen($LogFilePath, 2)
			Else
				$hHandle = FileOpen($LogFilePath, 1)
			EndIf
			FileWrite($hHandle, $sMessage)
			FileClose($hHandle)

		EndIf
	EndIf

	Return $sMessage
EndFunc   ;==>_ConsoleWrite

;===============================================================================
; Function:		_GetBroadcast
; Purpose:		Get the UDP broadcast ip address for the adapter address specified
; Syntax:		_GetBroadcast($sIP)
; Parameters:	$sIP = IP address that is currently adisgned to an adapter
; Returns:  	Success - Broadcast address
;				Failure - 0
; Notes:
; Author:
; Date/Version:   	10/15/2014  --  v1.1
;===============================================================================
Func _GetBroadcast($sIP)
	$objWMIService = ObjGet("winmgmts:{impersonationLevel=Impersonate}!\\" & @ComputerName & "\root\cimv2")
	If Not IsObj($objWMIService) Then Exit
	$colAdapters = $objWMIService.ExecQuery("SELECT * FROM Win32_NetworkAdapterConfiguration WHERE IPEnabled = True")
	For $objAdapter In $colAdapters
		If Not ($objAdapter.IPAddress) = " " Then
			For $i = 0 To UBound($objAdapter.IPAddress) - 1
				If $objAdapter.IPAddress($i) = $sIP Then
					Local $BC = ""
					$IP = StringSplit($objAdapter.IPAddress($i), ".")
					$MASK = StringSplit($objAdapter.IPSubnet($i), ".")
					If $IP[0] <> 4 Then Return SetError(1, 0, 0)
					If $MASK[0] <> 4 Then Return SetError(2, 0, 0)
					For $i = 1 To 4
						$BC &= BitXOR(BitXOR($MASK[$i], 255), BitAND($IP[$i], $MASK[$i])) & "."
					Next
					Return StringTrimRight($BC, 1)
				EndIf
			Next
		EndIf
	Next
	Return 0
EndFunc   ;==>_GetBroadcast

;===============================================================================
; Function:		_SocketToIP
; Purpose:		Get the IP a socket is connected to
; Syntax:		_SocketToIP($iSocket)
; Parameters:	$iSocket
; Returns:  	Success -
;				Failure -
; Notes:
; Author:
; Date/Version:   	10/15/2014  --  v1.1
;===============================================================================
Func _SocketToIP($iSocket)
	Local $aRet
	Local $sSockAddress = DllStructCreate("short;ushort;uint;char[8]")

	$aRet = DllCall("Ws2_32.dll", "int", "getpeername", "int", $iSocket, _
			"ptr", DllStructGetPtr($sSockAddress), "int*", DllStructGetSize($sSockAddress))
	If Not @error And $aRet[0] = 0 Then
		$aRet = DllCall("Ws2_32.dll", "str", "inet_ntoa", "int", DllStructGetData($sSockAddress, 3))
		If Not @error Then $aRet = $aRet[0]
	Else
		$aRet = 0
	EndIf

	$sSockAddress = 0

	Return $aRet
EndFunc   ;==>_SocketToIP

;===============================================================================
; Function Name:    _ImageWait()
; Description:		Use image search to wait for an image to apear on the screen
; Call With:		_ImageWait($iFlag)
; Parameter(s):
; Return Value(s):  On Success - 1 (Found image)
; 					On Failure - 0 (Timeout)
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		10/15/2014  --  v1.1
;===============================================================================
Func _ImageWait($FindImage, $hWnd = Default, $iTolerance = Default, $iTimeout = Default, $x1 = Default, $y1 = Default, $x2 = Default, $y2 = Default)
	$Timer = TimerInit()
	While 1
		$Return = _ImageSearch($FindImage, $hWnd, $iTolerance, Default, $x1, $y1, $x2, $y2)
		If Not @error Then Return $Return

		If $iTimeout > 0 And TimerDiff($Timer) > $iTimeout Then
			SetError(1)
			Return 0
		EndIf

		_Sleep(500)
	WEnd
EndFunc   ;==>_ImageWait

;===============================================================================
; Function Name:    _ImageSearch()
; Description:		Searches the chosen area of the screen for an image based on the selected image file
; Call With:		_ImageSearch($FindImage[,$hWnd[,$Tolerance[,$Draw[,$x1[,$y1[,$x2[,$y2]]]]]]])
; Parameter(s): 	$FindImage - File name/path of image to search for
;					$hWnd - (Optional) Handle to window to conduct the search in (speeds up searching)
;					$Tolerance - (Optional) Tolerance for variations between the image file and the screen
;									Note: Checkes pixel for pixel; slight changes in reletive position of pixels are not tolerated
;					$Draw - (Optional) Calls on user function "DrawBox" to draw a green line around the area being searched
;									Note: Can cause performance issues, line lingers after being drawn, for debugging primarily
;					$x1 - (Optional) Left pixel dimention (default: 0)
;					$y1 - (Optional) Top  pixel dimention (default: 0)
;					$x2 - (Optional) Right pixel dimention (default: desktop width)
;					$y2 - (Optional) Bottom pixel dimention (default: desktop height)
; Return Value(s):	On Failure - Returns empty array and sets @error to 1 when the image isnt found
;								 Returns empty array and sets @error to 2 when the call to the image search dll failed
;					On Success - Returns an array containing location values for the searched image
;									$Array[0] = X position
;									$Array[1] = Y postion
;									$Array[2] = Width of image
;									$Array[3] = Height of image
;									$Array[4] = Center position of image found (x)
;									$Array[5] = Center position of image found (y)
; Notes:			This function returns vaules that are considerate of "PixelCoordMode", note that when using
;						relative coords inacuracys are posible while window is being moved
;					Call this function with $FindImage equal to "close" to close the open dll
;					Set "$ImageSearch_hDll" as a global variable in your script to specify you own dll name/path
; Author(s):        DLL Author Unknown
;					JohnMC - JohnsCS.com
; Date/Version:		11/20/2012  --  v1.1
;===============================================================================
Func _ImageSearch($FindImage, $hWnd = "", $Tolerance = 0, $Draw = 0, $x1 = 0, $y1 = 0, $x2 = @DesktopWidth, $y2 = @DesktopHeight)
	Local $Default_Dll = "_ImageSearchDLL.dll", $aCoords[6]

	If $hWnd <> "" Then
		$wpos = WinGetPos($hWnd)
		$x1 = $wpos[0]
		$y1 = $wpos[1]
		$x2 = $wpos[0] + $wpos[2]
		$y2 = $wpos[1] + $wpos[3]
	EndIf

	If $Draw = 1 Then _DrawBox($x1, $y1, $x2, $y2)

	If Not FileExists($FindImage) Then
		Return SetError(3, 0, $aCoords)
	EndIf

	If Not IsDeclared("ImageSearch_hDll") Then
		Global $ImageSearch_hDll = DllOpen($Default_Dll)
	EndIf

	If $FindImage = "close" Then
		DllClose($ImageSearch_hDll)
		Return
	EndIf

	If $Tolerance > 0 Then $FindImage = "*" & $Tolerance & " " & $FindImage

	Local $aReturn = DllCall($ImageSearch_hDll, "str", "ImageSearch", "int", $x1, "int", $y1, "int", $x2, "int", $y2, "str", $FindImage)

	If @error Then
		Return SetError(2, 0, $aCoords)
	ElseIf $aReturn[0] = "0" Then
		Return SetError(1, 0, $aCoords)
	EndIf

	$aCoords = StringSplit(StringTrimLeft($aReturn[0], 2), "|", 2) ;Recycle $aReturn

	If AutoItSetOption("PixelCoordMode") = 0 Then ;Consideration for coords relative to window
		Local $aWinPos = WinGetPos($hWnd)
		$aCoords[0] = $aCoords[0] - $aWinPos[0]
		$aCoords[1] = $aCoords[1] - $aWinPos[1]
	ElseIf AutoItSetOption("PixelCoordMode") = 2 Then ;Consideration for coords relative to client area of active window
		If $hWnd = "" Then $hWnd = WinGetHandle("")
		Local $tpoint = DllStructCreate("int X;int Y")
		DllStructSetData($tpoint, "X", 0)
		DllStructSetData($tpoint, "Y", 0)
		DllCall("user32.dll", "bool", "ClientToScreen", "hwnd", $hWnd, "struct*", $tpoint)
		$aCoords[0] = $aCoords[0] - DllStructGetData($tpoint, "X")
		$aCoords[1] = $aCoords[1] - DllStructGetData($tpoint, "Y")
	EndIf

	ReDim $aCoords[6]
	$aCoords[4] = Int($aCoords[0] + ($aCoords[2] / 2)) ;Center X
	$aCoords[5] = Int($aCoords[1] + ($aCoords[3] / 2)) ;Center Y

	Return $aCoords
EndFunc   ;==>_ImageSearch

;===============================================================================
; Function Name:    _DrawBox()
; Description:		Draws a line (box) on the screen using the coorinates provided
; Call With:		_DrawBox($x1,$y1,$x2,$y2[,$Color])
; Parameter(s): 	$x1 - Left pixel dimention
;					$y1 - Top  pixel dimention
;					$x2 - Right pixel dimention
;					$y2 - Bottom pixel dimention
;					$Color - Hex color value, default is green
; Return Value(s):	N/A
; Notes:			Can cause performance issues if called often, line may linger after being drawn, for debugging primarily
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		11/20/2012  --  v1.1
;===============================================================================
Func _DrawBox($x1, $y1, $x2, $y2, $Color = 0x00FF00)
	Local $aDC = DllCall("user32.dll", "int", "GetDC", "hwnd", "")
	Local $hDll = DllOpen("gdi32.dll")

	For $i = $x1 To $y2
		DllCall($hDll, "long", "SetPixel", "long", $aDC[0], "long", $i, "long", $y1, "long", $Color)
		DllCall($hDll, "long", "SetPixel", "long", $aDC[0], "long", $i, "long", $y2, "long", $Color)
	Next

	For $i = $x1 To $y2
		DllCall($hDll, "long", "SetPixel", "long", $aDC[0], "long", $x1, "long", $i, "long", $Color)
		DllCall($hDll, "long", "SetPixel", "long", $aDC[0], "long", $x2, "long", $i, "long", $Color)
	Next

	DllClose($hDll)
EndFunc   ;==>_DrawBox

;===============================================================================
; Function Name:    _Speak()
; Description:		Speaks or creates audio file of the specified text
; Call With:		_Speak($Text[,$Speed,[$File]])
; Parameter(s): 	$Text - What to speak
;					$Speed - (Optional) How fast to speak
;					$File - (Optional) Filename to record to if specified (Wont speak outloud)
; Return Value(s):  On Success - 1
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		01/29/2010  --  v1.0
;===============================================================================
Func _Speak($Text, $Speed = -3, $File = "")
	Local $ObjVoice, $ObjFile

	$ObjVoice = ObjCreate("Sapi.SpVoice")
	If $File <> "" Then
		$ObjFile = ObjCreate("SAPI.SpFileStream.1")
		$ObjFile.Open($File, 3)
		$ObjVoice.AudioOutputStream = $ObjFile
	EndIf
	$ObjVoice.Speak('<rate speed="' & $Speed & '">' & $Text & '</rate>', 8)

	Return 1
EndFunc   ;==>_Speak


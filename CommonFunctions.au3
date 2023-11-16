;===============================================================================
; Common functions used in my scripts
; https://github.com/jmclaren7/autoit-scripts/blob/master/CommonFunctions.au3
;===============================================================================
#include-once
#include <Array.au3>
#include <Security.au3>
#include <String.au3>
#include <AutoItConstants.au3>
#include <File.au3>
#include <GUIConstantsEx.au3>
;===============================================================================

; #FUNCTION# ====================================================================================================================
; Name ..........: _WMI
; Description ...: Run a WMI query with th eoption of returning the first object (default) or all objects
; Syntax ........: _WMI($Query[, $Single = True])
; Parameters ....: $Query               - an unknown value.
;                  $Single              - [optional] Return the first object, Default is True.
; Return values .: Object(s)
; Author ........: JohnMC - JohnsCS.com
; Date/Version ..: 11/15/2023  --  v1.1
; ===============================================================================================================================
Func _WMI($Query, $Single = True)
	If Not IsDeclared("_objWMIService") Then
		Local $Object = ObjGet("winmgmts:\root\CIMV2")
		If @error Or Not IsObject($Object) Then Return SetError(1, 0, 0)
		Global $_objWMIService = $Object
	EndIf

	Local $colItems = $_objWMIService.ExecQuery($Query)
	If @error Or Not IsObject($colItems) Then Return SetError(2, 0, 0)

	If $Single Then
		Local $objItem

		For $objItem in $colItems
			Return $objItem
		Next

	Else
		Return $colItems

	EndIf

EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _INetSmtpMailCom
; Description ...: Send an email using a Windows API with authentication and encryption which isn't available in the AutoIt UDF _INetSmtpMail
; Syntax ........: _INetSmtpMailCom($sSMTPServer, $sFromName, $sFromAddress, $sToAddress[, $sSubject = ""[, $sBody = ""[,
;                  $sUsername = ""[, $sPassword = ""[, $sCCAddress = ""[, $sBCCAddress = ""[, $iPort = 587[, $bSSL = False[,
;                  $bTLS = True]]]]]]]]])
; Parameters ....: $sSMTPServer         - a string value.
;                  $sFromName           - a string value.
;                  $sFromAddress        - a string value.
;                  $sToAddress          - a string value.
;                  $sSubject            - [optional] a string value. Default is "".
;                  $sBody               - [optional] a string value. Default is "".
;                  $sUsername           - [optional] a string value. Default is "".
;                  $sPassword           - [optional] a string value. Default is "".
;                  $sCCAddress          - [optional] a string value. Default is "".
;                  $sBCCAddress         - [optional] a string value. Default is "".
;                  $iPort               - [optional] an integer value. Default is 587.
;                  $bSSL                - [optional] a boolean value. Default is False.
;                  $bTLS                - [optional] a boolean value. Default is True.
; Return values .: None
; Author ........: AutoIT Forum, modified by JohnMC - JohnsCS.com
; Date/Version ..: 11/15/2023  --  v1.1
; ===============================================================================================================================
Func _INetSmtpMailCom($sSMTPServer, $sFromName, $sFromAddress, $sToAddress, $sSubject = "", $sBody = "", $sUsername = "", $sPassword = "", $sCCAddress = "", $sBCCAddress = "", $iPort = 587, $bSSL = False, $bTLS = True)
	Local $oMail = ObjCreate("CDO.Message")

	$oMail.From = '"' & $sFromName & '" <' & $sFromAddress & '>'
	$oMail.To = $sToAddress
	$oMail.Subject = $sSubject

	If $sCCAddress Then $oMail.Cc = $sCCAddress
	If $sBCCAddress Then $oMail.Bcc = $sBCCAddress

	If StringInStr($sBody, "<") And StringInStr($sBody, ">") Then
		$oMail.HTMLBody = $sBody
	Else
		$oMail.Textbody = $sBody & @CRLF
	EndIf

	$oMail.Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2
	$oMail.Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/smtpserver") = $sSMTPServer
	$oMail.Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = $iPort

	; Authenticated SMTP
	If $sUsername <> "" Then
		$oMail.Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/smtpauthenticate") = 1
		$oMail.Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/sendusername") = $sUsername
		$oMail.Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/sendpassword") = $sPassword
	EndIf

	; Set security parameters
	If $bSSL Then $oMail.Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/smtpusessl") = True
	If $bTLS Then $oMail.Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/sendtls") = True

	; Update settings
	$oMail.Configuration.Fields.Update
	$oMail.Fields.Update

	; Send the Message
	$oMail.Send
	If @error Then Return SetError(2, 0, 0)

	$oMail = ""

EndFunc   ;==>_INetSmtpMailCom

; #FUNCTION# ====================================================================================================================
; Name ..........: _StringExtract
; Description ...:
; Syntax ........: _StringExtract($sString, $sStartSearch, $sEndSearch[, $iStartTrim = 0[, $iEndTrim = 0]])
; Parameters ....: $sString             - a string value.
;                  $sStartSearch        - a string value.
;                  $sEndSearch          - a string value.
;                  $iStartTrim          - [optional] an integer value. Default is 0.
;                  $iEndTrim            - [optional] an integer value. Default is 0.
; Return values .: None
; Author ........: Your Name
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _StringExtract($sString, $sStartSearch, $sEndSearch, $iStartTrim = 0, $iEndTrim = 0)
	$iStartPos = StringInStr($sString, $sStartSearch)
	If Not $iStartPos Then Return SetError(1, 0, 0)
	$iStartPos = $iStartPos + StringLen($sStartSearch)

	$iCount = StringInStr($sString, $sEndSearch, 0, 1, $iStartPos)
	If Not $iCount Then Return SetError(2, 0, 0)
	$iCount = $iCount - $iStartPos

	$sNewString = StringMid($sString, $iStartPos + $iStartTrim, $iCount + $iEndTrim - $iStartTrim)

	Return $sNewString

EndFunc   ;==>_StringExtract

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
Func _GetUnixTimeStamp($year = 0, $mon = 0, $days = 0, $hour = 0, $min = 0, $sec = 0)
	If $year = 0 Then $year = Number(@YEAR)
	If $mon = 0 Then $mon = Number(@MON)
	If $days = 0 Then $days = Number(@MDAY)
	If $hour = 0 Then $hour = Number(@HOUR)
	If $min = 0 Then $min = Number(@MIN)
	If $sec = 0 Then $sec = Number(@SEC)
	Local $NormalYears = 0
	Local $LeepYears = 0
	For $i = 1970 To $year - 1 Step +1
		If _BoolLeapYear($i) = True Then
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
	Return $yearNum + ($MonNum * 24 * 3600) + (($days - 1) * 24 * 3600) + $hour * 3600 + $min * 60 + $sec
EndFunc   ;==>_GetUnixTimeStamp

;===============================================================================
;
; Description:      UnixTimeStampToTime - Converts UnixTime to Date
; Parameter(s):     Requierd : $UnixTimeStamp => UnixTime ex : 1102141493
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
;
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
; Function Name:    __StringProper
; Description:		Improved version of _StringProper, wont capitalize after apostrophes
; Call With:		__StringProper($s_String)
; Parameter(s):
; Return Value(s):  On Success -
; 					On Failure -
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		10/15/2014  --  v1.0
;===============================================================================
Func __StringProper($s_String)
	Local $iX = 0
	Local $CapNext = 1
	Local $s_nStr = ""
	Local $s_CurChar
	For $iX = 1 To StringLen($s_String)
		$s_CurChar = StringMid($s_String, $iX, 1)
		Select
			Case $CapNext = 1
				If StringRegExp($s_CurChar, '[a-zA-Z�-�����]') Then
					$s_CurChar = StringUpper($s_CurChar)
					$CapNext = 0
				EndIf
			Case Not StringRegExp($s_CurChar, '[a-zA-Z�-�����]') And $s_CurChar <> "'"
				$CapNext = 1
			Case Else
				$s_CurChar = StringLower($s_CurChar)
		EndSelect
		$s_nStr &= $s_CurChar
	Next
	Return $s_nStr
EndFunc   ;==>__StringProper
;===============================================================================
; Function Name:    _FileInUse()
; Description:      Checks if file is in use
; Call With:        _FileInUse($sFilename, $iAccess = 0)
; Parameter(s):     $sFilename = File name
;                   $iAccess = 0 = GENERIC_READ - other apps can have file open in readonly mode
;                   $iAccess = 1 = GENERIC_READ|GENERIC_WRITE - exclusive access to file,
;                   fails if file open in readonly mode by app
; Return Value(s):  1 - file in use (@error contains system error code)
;                   0 - file not in use
;                   -1 dllcall error (@error contains dllcall error code)
; Author(s):        Siao, rover
; Date/Version:		10/15/2014  --  v1.0
;===============================================================================
Func _FileInUse($sFilename, $iAccess = 0)
	Local $aRet, $hFile, $iError, $iDA
	Local Const $GENERIC_WRITE = 0x40000000
	Local Const $GENERIC_READ = 0x80000000
	Local Const $FILE_ATTRIBUTE_NORMAL = 0x80
	Local Const $OPEN_EXISTING = 3
	$iDA = $GENERIC_READ
	If BitAND($iAccess, 1) <> 0 Then $iDA = BitOR($GENERIC_READ, $GENERIC_WRITE)
	$aRet = DllCall("Kernel32.dll", "hwnd", "CreateFile", _
			"str", $sFilename, _ ;lpFileName
			"dword", $iDA, _ ;dwDesiredAccess
			"dword", 0x00000000, _ ;dwShareMode = DO NOT SHARE
			"dword", 0x00000000, _ ;lpSecurityAttributes = NULL
			"dword", $OPEN_EXISTING, _ ;dwCreationDisposition = OPEN_EXISTING
			"dword", $FILE_ATTRIBUTE_NORMAL, _ ;dwFlagsAndAttributes = FILE_ATTRIBUTE_NORMAL
			"hwnd", 0) ;hTemplateFile = NULL
	$iError = @error
	If @error Or IsArray($aRet) = 0 Then Return SetError($iError, 0, -1)
	$hFile = $aRet[0]
	If $hFile = -1 Then ;INVALID_HANDLE_VALUE = -1
		$aRet = DllCall("Kernel32.dll", "int", "GetLastError")
		;ERROR_SHARING_VIOLATION = 32 0x20
		;The process cannot access the file because it is being used by another process.
		If @error Or IsArray($aRet) = 0 Then Return SetError($iError, 0, 1)
		Return SetError($aRet[0], 0, 1)
	Else
		;close file handle
		DllCall("Kernel32.dll", "int", "CloseHandle", "hwnd", $hFile)
		Return SetError(@error, 0, 0)
	EndIf
EndFunc   ;==>_FileInUse
;===============================================================================
; Function Name:    _FileInUseWait
; Description:		Checkes to see if a file has open handles
; Call With:		_FileInUse($sFilePath, $iAccess = 0)
; Parameter(s):
; Return Value(s):  On Success -
; 					On Failure -
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		10/15/2014  --  v1.0
;===============================================================================
Func _FileInUseWait($sFilePath, $Timeout = 0, $Sleep = 2000)
	$Timeout = $Timeout * 1000
	$Time = TimerInit()
	While 1
		If _FileInUse($sFilePath) Then
			_ConsoleWrite("  File locked")
		Else
			Return 1
		EndIf
		If $Timeout > 0 And $Timeout < TimerDiff($Time) Then
			_ConsoleWrite("  Timeout, file locked")
			Return 0
		EndIf
		Sleep($Sleep)
	WEnd
EndFunc   ;==>_FileInUseWait
;===============================================================================
; Function Name:    _RunWait
; Description:		Improved version of RunWait that plays nice with my console logging
; Call With:		_RunWait($Run, $Working="")
; Parameter(s):
; Return Value(s):  On Success - Return value of Run() (Should be PID)
; 					On Failure - Return value of Run()
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		01/16/2016  --  v1.1
;===============================================================================
Func _RunWait($sProgram, $Working = "", $Show = @SW_HIDE, $Opt = $STDERR_MERGED, $Live = False)
	Local $sData, $iPid

	$iPid = Run($sProgram, $Working, $Show, $Opt)
	If @error Then
		_ConsoleWrite("_RunWait: Couldn't Run " & $sProgram)
		Return SetError(1, 0, 0)
	EndIf

	$sData = _ProcessWaitClose($iPid, $Live)

	Return SetError(0, $iPid, $sData)
EndFunc   ;==>_RunWait
;===============================================================================
; Function Name:    _ProcessWaitClose
; Description:		ProcessWaitClose that handles stdout from the running process
;					Proccess must have been started with $STDERR_CHILD + $STDOUT_CHILD
; Call With:		_ProcessWaitClose($iPid)
; Parameter(s):
; Return Value(s):  On Success -
; 					On Failure -
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		09/8/2023  --  v1.3
;===============================================================================
Func _ProcessWaitClose($iPid, $Live = False, $Diag = False)
	Local $sData, $sStdRead

	While 1
		$sStdRead = StdoutRead($iPid)
		If @error Or $sStdRead = "" Then StderrRead($iPid)
		If @error And Not ProcessExists($iPid) Then ExitLoop
		$sStdRead = StringReplace($sStdRead, @CR & @LF & @CR & @LF, @CR & @LF)

		If $Diag Then
			$sStdRead = StringReplace($sStdRead, @CRLF, "_@CRLF")
			$sStdRead = StringReplace($sStdRead, @CR, "@CR" & @CR)
			$sStdRead = StringReplace($sStdRead, @LF, "@LF" & @LF)
			$sStdRead = StringReplace($sStdRead, "_@CRLF", "@CRLF" & @CRLF)
		EndIf

		If $sStdRead <> @CRLF Then
			$sData &= $sStdRead
			If $Live And $sStdRead <> "" Then
				If StringRight($sStdRead, 2) = @CRLF Then $sStdRead = StringTrimRight($sStdRead, 2)
				If StringRight($sStdRead, 1) = @LF Then $sStdRead = StringTrimRight($sStdRead, 1)
				_ConsoleWrite($sStdRead)
			EndIf
		EndIf

		Sleep(5)
	WEnd

	Return $sData
EndFunc   ;==>_ProcessWaitClose
;===============================================================================
; Function Name:    _TreeList()
; Description:
; Call With:		_TreeList()
; Parameter(s):
; Return Value(s):  On Success -
; 					On Failure -
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		06/02/2011  --  v1.0
;===============================================================================
Func _TreeList($path, $mode = 1)
	Local $FileList_Original = _FileListToArray($path, "*", 0)
	Local $FileList[1]

	For $i = 1 To UBound($FileList_Original) - 1
		Local $file_path = $path & "\" & $FileList_Original[$i]
		If StringInStr(FileGetAttrib($file_path), "D") Then
			$new_array = _TreeList($file_path, $mode)
			_ArrayConcatenate($FileList, $new_array, 1)
		Else
			ReDim $FileList[UBound($FileList) + 1]
			$FileList[UBound($FileList) - 1] = $file_path
		EndIf
	Next

	Return $FileList
EndFunc   ;==>_TreeList
;===============================================================================
; Function Name:    _StringStripWS()
; Description:		Strips all white chars, excluing char(32) the reglar space
; Call With:		_StringStripWS($String)
; Parameter(s): 	$String - String To Strip
; Return Value(s):  On Success - Striped String
; 					On Failure - Full String
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		01/29/2010  --  v1.0
;===============================================================================
Func _StringStripWS($String)
	Return StringRegExpReplace($String, "[" & Chr(0) & Chr(9) & Chr(10) & Chr(11) & Chr(12) & Chr(13) & "]", "")
EndFunc   ;==>_StringStripWS
;===============================================================================
; Function Name:    _mousecheck()
; Description:		Checks for mouse movement
; Call With:		_mousecheck($Sleep)
; Parameter(s): 	$Sleep - Miliseconds between mouse checks, 0=Compare At Next Call
; Return Value(s):  On Success - 1 (Mouse Moved)
; 					On Failure - 0 (Mouse Didnt Move)
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		01/29/2010  --  v1.0
;===============================================================================
Func _MouseCheck($Sleep = 300)
	Local $MOUSECHECK_POS1, $MOUSECHECK_POS2

	If $Sleep = 0 Then Global $MOUSECHECK_POS1
	If IsArray($MOUSECHECK_POS1) = 0 And $Sleep = 0 Then $MOUSECHECK_POS1 = MouseGetPos()
	Sleep($Sleep)
	$MOUSECHECK_POS2 = MouseGetPos()
	If Abs($MOUSECHECK_POS1[0] - $MOUSECHECK_POS2[0]) > 2 Or Abs($MOUSECHECK_POS1[1] - $MOUSECHECK_POS2[1]) > 2 Then
		If $Sleep = 0 Then $MOUSECHECK_POS1 = $MOUSECHECK_POS2
		Return 1
	EndIf

	Return 0
EndFunc   ;==>_MouseCheck
;===============================================================================
; Function Name:    _KeyValue()
; Description:		Work with 2d arrays treated as key value pairs such as the ones produced by INIReadSection()
; Call With:		_KeyValue(ByRef $Array, $Key[, $Value[, $Extended]])
; Parameter(s): 	$Array - A previously declared array, if not array, it will be made as one
;					$Key - The value to look for in the first column/dimention or the "Key" in an INI section
;		(Optional)	$Value - The value to write to the array
;		(Optional)	$Delete - If True, delete the specified key
;
; Return Value(s):  On Success - The value found or set or true if a value was deleted
; 					On Failure - "" and sets @error to 1
;
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		10/05/2023  --  v1.0
; Notes:            $Array[0][0] Contains the number of stored parameters
; Example:			_KeyValue($Settings, "trayicon", "1")
;===============================================================================
Func _KeyValue(ByRef $aArray, $Key, $Value = Default, $Delete = Default)
	Local $i

	If $Delete = Default Then $Delete = False

	; Make $Array an array if not already
	If Not IsArray($aArray) Then Dim $aArray[1][2]

	; Loop through array to check for existing key
	For $i = 1 To UBound($aArray) - 1
		If $aArray[$i][0] = $Key Then
			; Read existing value
			If $Value = Default Then
				Return $aArray[$i][1]

				; Update existing value
			Else
				$aArray[$i][1] = $Value
				$aArray[0][0] = UBound($aArray) - 1
				Return $Value
			EndIf

			; Delete existing value
			If $Delete Then
				Local $aNewArray[]
				; Loop through array and copy all keys/values not matching the specified key
				For $i = 1 To UBound($aArray) - 1
					; Skip the key to be deleted
					If $aArray[$i][0] = $Key Then ContinueLoop

					; Resize array and add new key/value
					ReDim $aArray[UBound($aNewArray) + 1][2]
					$aArray[UBound($aNewArray)][0] = $aArray[$i][0]
					$aArray[UBound($aNewArray)][1] = $aArray[$i][1]
				Next

				$aNewArray[0][0] = UBound($aArray) - 1

				; Return array with key/value removed
				$aArray = $aNewArray
				Return True
			EndIf
		EndIf
	Next

	; Add new key/value if it's been specified
	If $Value <> Default Then
		ReDim $aArray[UBound($aArray) + 1][2]
		$aArray[UBound($aArray) - 1][0] = $Key
		$aArray[UBound($aArray) - 1][1] = $Value
		$aArray[0][0] = UBound($aArray) - 1

		Return $Value
	EndIf

	; Return error because a key doesn't exist and nothing else to do
	SetError(1)
	Return ""
EndFunc   ;==>_KeyValue
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
; Function Name:    _TimeStamp()
; Description:		Returns time since 0 unlike the unknown timestamp behavior of timer_init
; Call With:		_TimeStamp([$Flag])
; Parameter(s): 	$Flag - (Optional) Default is 0 (Miliseconds)
;						1 = Return Total Seconds
;						2 = Return Total Minutes
; Return Value(s):  On Success - Time
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		01/29/2010  --  v1.0
;===============================================================================
Func _TimeStamp($Flag = 0)
	Local $Time

	$Time = @YEAR * 365 * 24 * 60 * 60 * 1000
	$Time = $Time + @YDAY * 24 * 60 * 60 * 1000
	$Time = $Time + @HOUR * 60 * 60 * 1000
	$Time = $Time + @MIN * 60 * 1000
	$Time = $Time + @SEC * 1000
	$Time = $Time + @MSEC

	If $Flag = 1 Then Return Int($Time / 1000) ;Return Seconds
	If $Flag = 2 Then Return Int($Time / 1000 / 60) ;Return Minutes
	Return Int($Time) ;Return Miliseconds
EndFunc   ;==>_TimeStamp
;===============================================================================
; Function Name:    _ProcessWaitNew()
; Description:		Wait for a new proccess to be created before continuing
; Call With:		_ProcessWaitNew($proc,$timeout=0)
; Parameter(s): 	$Process - PID or proccess name
;					$Timeout - (Optional) Miliseconds Before Giving Up
; Return Value(s):  On Success - 1
; 					On Failure - 0 (Timeout)
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		01/29/2010  --  v1.0
;===============================================================================
Func _ProcessWaitNew($Process, $Timeout = 0)
	Local $Count1 = _ProcessCount(), $Count2
	Local $StartTime = _TimeStamp()

	While 1
		$Count2 = _ProcessCount()
		If $Count2 > $Count1 Then Return 1
		If $Count2 < $Count1 Then $Count1 = $Count2

		If $Timeout > 0 And $StartTime < _TimeStamp() - $Timeout Then ExitLoop
		Sleep(100)
	WEnd

	Return 0
EndFunc   ;==>_ProcessWaitNew
;===============================================================================
; Function Name:    _ProcessCount()
; Description:		Returns the number of processes with the same name
; Call With:		_ProcessCount([$Process[,$OnlyUser]])
; Parameter(s): 	$Process - PID or process name
;					$OnlyUser - Only evaluate processes from this user
; Return Value(s):  On Success - Count
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		01/29/2010  --  v1.0
;===============================================================================
Func _ProcessCount($Process = @AutoItPID, $OnlyUser = "")
	Local $Count = 0, $Array = ProcessList($Process)

	For $i = 1 To $Array[0][0]
		If $Array[$i][1] = $Process Then
			If $OnlyUser <> "" And $OnlyUser <> _ProcessOwner($Array[$i][1]) Then ContinueLoop
			$Count = $Count + 1
		EndIf
	Next

	Return $Count
EndFunc   ;==>_ProcessCount
;===============================================================================
; Function Name:    _ProcessOwner()
; Description:		Gets username of the owner of a PID
; Call With:		_ProcessOwner($PID[,$Hostname])
; Parameter(s): 	$PID - PID of proccess
;					$Hostname - (Optional) The computers name to check on
; Return Value(s):  On Success - Username of owner
; 					On Failure - 0
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		01/29/2010  --  v1.0
;===============================================================================
Func _ProcessOwner($PID, $Hostname = ".")
	Local $User, $objWMIService, $colProcess, $objProcess

	$objWMIService = ObjGet("winmgmts://" & $Hostname & "/root/cimv2")
	$colProcess = $objWMIService.ExecQuery("Select * from Win32_Process Where ProcessID ='" & $PID & "'")

	For $objProcess In $colProcess
		If $objProcess.ProcessID = $PID Then
			$User = 0
			$objProcess.GetOwner($User)
			Return $User
		EndIf
	Next
EndFunc   ;==>_ProcessOwner
;===============================================================================
; Function Name:    _ProcessCloseOthers()
; Description:		Closes other proccess of the same name
; Call With:		_ProcessCloseOthers([$Process[,$ExcludingUser[,$OnlyUser]]])
; Parameter(s): 	$Process - (Optional) Name or PID
;					$ExcludingUser - (Optional) Username of owner to exclude
;					$OnlyUser - (Optional) Username of proccesses owner to close
; Return Value(s):  On Success - 1
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		01/29/2010  --  v1.0
;===============================================================================
Func _ProcessCloseOthers($Process = @ScriptName, $ExcludingUser = "", $OnlyUser = "")
	Local $Array = ProcessList($Process)

	For $i = 1 To $Array[0][0]
		If ($Array[$i][1] <> @AutoItPID) Then
			If $ExcludingUser <> "" And _ProcessOwner($Array[$i][1]) <> $ExcludingUser Then
				ProcessClose($Array[$i][1])
			ElseIf $OnlyUser <> "" And _ProcessOwner($Array[$i][1]) = $OnlyUser Then
				ProcessClose($Array[$i][1])
			ElseIf $OnlyUser = "" And $ExcludingUser = "" Then
				ProcessClose($Array[$i][1])
			EndIf
		EndIf
	Next
EndFunc   ;==>_ProcessCloseOthers
;===============================================================================
; Function Name:    _OnlyInstance()
; Description:		Checks to see if we are the only instance running
; Call With:		_OnlyInstance($iFlag)
; Parameter(s): 	$iFlag
;						0 = Continue Anyway
;						1 = Exit Without Notification
;						2 = Exit After Notifying
;						3 = Prompt What To Do
;						4 = Close Other Proccesses
; Return Value(s):  On Success - 1 (Found Another Instance)
; 					On Failure - 0 (Didnt Find Another Instance)
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		10/15/2014  --  v1.1
;===============================================================================
Func _OnlyInstance($iFlag)
	Local $ERROR_ALREADY_EXISTS = 183, $Handle, $LastError, $Message

	If @Compiled = 0 Then Return 0

	$Handle = DllCall("kernel32.dll", "int", "CreateMutex", "int", 0, "long", 1, "str", @ScriptName)
	$LastError = DllCall("kernel32.dll", "int", "GetLastError")
	If $LastError[0] = $ERROR_ALREADY_EXISTS Then
		SetError($LastError[0], $LastError[0], 0)
		Switch $iFlag
			Case 0
				Return 1
			Case 1
				ProcessClose(@AutoItPID)
			Case 2
				MsgBox(262144 + 48, @ScriptName, "The Program Is Already Running")
				ProcessClose(@AutoItPID)
			Case 3
				If MsgBox(262144 + 256 + 48 + 4, @ScriptName, "The Program (" & @ScriptName & ") Is Already Running, Continue Anyway?") = 7 Then ProcessClose(@AutoItPID)
			Case 4
				_ProcessCloseOthers()
		EndSwitch
		Return 1
	EndIf
	Return 0
EndFunc   ;==>_OnlyInstance
;===============================================================================
; Function Name:    _MsgBox()
; Description:		Displays a msgbox without haulting script by using /AutoIt3ExecuteLine
; Call With:		_MsgBox($Flag,$Title,$Text,$Timeout=0)
; Parameter(s): 	All the same options as standard message box
; Return Value(s):  On Success - PID of new proccess
; 					On Failure - 0
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		01/29/2010  --  v1.1
;===============================================================================
Func _MsgBox($Flag, $Title, $Text, $Timeout = 0)
	If $Title = "" Then $Title = @ScriptName
	If $Flag = "" Or IsInt($Flag) = 0 Then $Flag = 0
	Return Run('"' & @AutoItExe & '"' & ' /AutoIt3ExecuteLine "msgbox(' & $Flag & ',''' & $Title & ''',''' & $Text & ''',''' & $Timeout & ''')"')
EndFunc   ;==>_MsgBox
;===============================================================================
; Function Name:    _GetDriveFromSerial()
; Description:		Find a drives letter based on the drives serial
; Call With:		_GetDriveFromSerial($Serial)
; Parameter(s): 	$Serial - Serial of the drive
; Return Value(s):  On Success - Drive letter with ":"
; 					On Failure - 0
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		01/29/2010  --  v1.0
;===============================================================================
Func _GetDriveFromSerial($Serial)
	Local $Drivelist
	$Drivelist = StringSplit("c:,d:,e:,f:,g:,h:,i:,j:,k:,l:,m:,n:,o:,p:,q:,r:,s:,t:,u:,v:,w:,x:,y:,z:", ",")
	For $i = 1 To $Drivelist[0]
		If (DriveGetSerial($Drivelist[$i]) = $Serial And DriveStatus($Drivelist[$i]) = "READY") Then Return $Drivelist[$i]
	Next
	Return 0
EndFunc   ;==>_GetDriveFromSerial

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
;===============================================================================
; Function Name:    _Sleep()
; Description:		Simple modification to sleep to allow for adlib functions to run
; Call With:		_Sleep($iTime)
; Parameter(s): 	$iTime - Time in MS
; Return Value(s):  none
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		10/15/2014  --  v1.0
;===============================================================================
Func _Sleep($iTime)
	$iTime = Round($iTime / 10)
	For $i = 1 To $iTime
		Sleep(10)
	Next
EndFunc   ;==>_Sleep
;===============================================================================
; Function Name:    _IsInternet()
; Description:		Gets internet connection state as determined by Windows
; Call With:		_IsInternet()
; Parameter(s): 	none
; Return Value(s):  Success - 1
;					Failure - 0
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		10/15/2014  --  v1.0
;===============================================================================
Func _IsInternet()
	Local $Ret = DllCall("wininet.dll", 'int', 'InternetGetConnectedState', 'dword*', 0x20, 'dword', 0)

	If (@error) Then
		Return SetError(1, 0, 0)
	EndIf

	Local $wError = _WinAPI_GetLastError()

	Return SetError((Not ($wError = 0)), $wError, $Ret[0])
EndFunc   ;==>_IsInternet
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
	$timer = TimerInit()
	While 1
		$Return = _ImageSearch($FindImage, $hWnd, $iTolerance, Default, $x1, $y1, $x2, $y2)
		If Not @error Then Return $Return

		If $iTimeout > 0 And TimerDiff($timer) > $iTimeout Then
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
; Function Name:    _WinGetClientPos
; Description:		Retrieves the position and size of the client area of given window
; Call With:		_WinGetClientPos($hWin)
; Parameter(s): 	$hWnd - Handle to window
;					$Absolute - 1 = Get coordinates relative to the screen (deafult)
;								0 = Get coordinates relative to the window
; Return Value(s):	On Success - Returns an array containing location values for client area of the specified window
;									$Array[0] = X position
;									$Array[1] = Y position
;									$Array[2] = Width
;									$Array[3] = Height
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		11/21/2012  --  v1.2
;===============================================================================
Func _WinGetClientPos($hWnd, $Absolute = 1)
	Local $aPos[4], $aSize[4], $aWinPos[4]

	Local $tpoint = DllStructCreate("int X;int Y")
	DllStructSetData($tpoint, "X", 0)
	DllStructSetData($tpoint, "Y", 0)
	DllCall("user32.dll", "bool", "ClientToScreen", "hwnd", $hWnd, "struct*", $tpoint)

	$aSize = WinGetClientSize($hWnd)

	$aPos[0] = DllStructGetData($tpoint, "X")
	$aPos[1] = DllStructGetData($tpoint, "Y")
	$aPos[2] = $aSize[0]
	$aPos[3] = $aSize[1]

	If $Absolute = 0 Then
		$aWinPos = WinGetPos($hWnd)
		$aPos[0] = $aPos[0] - $aWinPos[0]
		$aPos[1] = $aPos[1] - $aWinPos[1]
	EndIf

	Return $aPos
EndFunc   ;==>_WinGetClientPos
;===============================================================================
; Function Name:    _WinMoveClient
; Description:		Position and size the client area of given window
; Call With:		_WinMoveClient()
; Parameter(s):
; Return Value(s):	Success - Handle to the window
;					Failure - 0
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		10/15/2014  --  v1.0
;===============================================================================
Func _WinMoveClient($sTitle, $sText, $X, $Y, $Width = Default, $Height = Default, $Speed = Default)

	Local $WinPos = WinGetPos($sTitle, $sText)
	Local $ClientSize = WinGetClientSize($sTitle, $sText)

	If $Width <> Default Then $Width = $Width + $WinPos[2] - $ClientSize[0]
	If $Height <> Default Then $Height = $Height + $WinPos[3] - $ClientSize[1]

	Return WinMove($sTitle, $sText, $X, $Y, $Width, $Height, $Speed)
EndFunc   ;==>_WinMoveClient
;=============================================================================================
; Name:				 _HighPrecisionSleep()
; Description:		Sleeps down to 0.1 microseconds
; Syntax:			_HighPrecisionSleep( $iMicroSeconds, $hDll=False)
; Parameter(s):		$iMicroSeconds        - Amount of microseconds to sleep
;					$hDll  - Can be supplied so the UDF doesn't have to re-open the dll all the time.
; Return value(s):	None
; Author:			Andreas Karlsson (monoceres)
; Remarks:			Even though this has high precision you need to take into consideration that it will take some time for autoit to call the function.
;=============================================================================================
Func _HighPrecisionSleep($iMicroSeconds, $dll = "")
	Local $hStruct, $bLoaded
	If $dll <> "" Then $HPS_hDll = $dll
	If Not IsDeclared("HPS_hDll") Then
		Global $HPS_hDll
		$HPS_hDll = DllOpen("ntdll.dll")
		$bLoaded = True
	EndIf
	$hStruct = DllStructCreate("int64 time;")
	DllStructSetData($hStruct, "time", -1 * ($iMicroSeconds * 10))
	DllCall($HPS_hDll, "dword", "ZwDelayExecution", "int", 0, "ptr", DllStructGetPtr($hStruct))
EndFunc   ;==>_HighPrecisionSleep
;===============================================================================
; Function:		_ProcessGetWin
; Purpose:		Return information on the Window owned by a process (if any)
; Syntax:		_ProcessGetWin($iPID)
; Parameters:	$iPID = integer process ID
; Returns:  	On success returns an array:
; 					[0] = Window Title (if any)
;					[1] = Window handle
;				If $iPID does not exist, returns empty array and @error = 1
; Notes:		Not every process has a window, indicated by an empty array and
;   			@error = 0, and not every window has a title, so test [1] for the handle
;   			to see if a window existed for the process.
; Author:		PsaltyDS at www.autoitscript.com/forum
;===============================================================================
Func _ProcessGetWin($iPid)
	Local $avWinList = WinList(), $avRET[2]
	For $n = 1 To $avWinList[0][0]
		If WinGetProcess($avWinList[$n][1]) = $iPid Then
			$avRET[0] = $avWinList[$n][0] ; Title
			$avRET[1] = $avWinList[$n][1] ; HWND
			ExitLoop
		EndIf
	Next
	If $avRET[1] = "" Then SetError(1)
	Return $avRET
EndFunc   ;==>_ProcessGetWin
;===============================================================================
; Function Name:    _ProcessListProperties()
; Description:   Get various properties of a process, or all processes
; Call With:       _ProcessListProperties( [$Process [, $sComputer]] )
; Parameter(s):  (optional) $Process - PID or name of a process, default is "" (all)
;          (optional) $sComputer - remote computer to get list from, default is local
; Requirement(s):   AutoIt v3.2.4.9+
; Return Value(s):  On Success - Returns a 2D array of processes, as in ProcessList()
;            with additional columns added:
;            [0][0] - Number of processes listed (can be 0 if no matches found)
;            [1][0] - 1st process name
;            [1][1] - 1st process PID
;            [1][2] - 1st process Parent PID
;            [1][3] - 1st process owner
;            [1][4] - 1st process priority (0 = low, 31 = high)
;            [1][5] - 1st process executable path
;            [1][6] - 1st process CPU usage
;            [1][7] - 1st process memory usage
;            [1][8] - 1st process creation date/time = "MM/DD/YYY hh:mm:ss" (hh = 00 to 23)
;            [1][9] - 1st process command line string
;            ...
;            [n][0] thru [n][9] - last process properties
; On Failure:     	Returns array with [0][0] = 0 and sets @Error to non-zero (see code below)
; Author(s):      	PsaltyDS at http://www.autoitscript.com/forum
; Date/Version:   	12/01/2009  --  v2.0.4
; Notes:        	If an integer PID or string process name is provided and no match is found,
;             		then [0][0] = 0 and @error = 0 (not treated as an error, same as ProcessList)
;          			This function requires admin permissions to the target computer.
;          			All properties come from the Win32_Process class in WMI.
;            		To get time-base properties (CPU and Memory usage), a 100ms SWbemRefresher is used.
;===============================================================================
Func _ProcessListProperties($Process = "", $sComputer = ".")
	Local $sUserName, $sMsg, $sUserDomain, $avProcs, $dtmDate
	Local $avProcs[1][2] = [[0, ""]], $n = 1

	; Convert PID if passed as string
	If StringIsInt($Process) Then $Process = Int($Process)

	; Connect to WMI and get process objects
	$oWMI = ObjGet("winmgmts:{impersonationLevel=impersonate,authenticationLevel=pktPrivacy, (Debug)}!\\" & $sComputer & "\root\cimv2")
	If IsObj($oWMI) Then
		; Get collection processes from Win32_Process
		If $Process == "" Then
			; Get all
			$colProcs = $oWMI.ExecQuery("select * from win32_process")
		ElseIf IsInt($Process) Then
			; Get by PID
			$colProcs = $oWMI.ExecQuery("select * from win32_process where ProcessId = " & $Process)
		Else
			; Get by Name
			$colProcs = $oWMI.ExecQuery("select * from win32_process where Name = '" & $Process & "'")
		EndIf

		If IsObj($colProcs) Then
			; Return for no matches
			If $colProcs.count = 0 Then Return $avProcs

			; Size the array
			ReDim $avProcs[$colProcs.count + 1][10]
			$avProcs[0][0] = UBound($avProcs) - 1

			; For each process...
			For $oProc In $colProcs
				; [n][0] = Process name
				$avProcs[$n][0] = $oProc.name
				; [n][1] = Process PID
				$avProcs[$n][1] = $oProc.ProcessId
				; [n][2] = Parent PID
				$avProcs[$n][2] = $oProc.ParentProcessId
				; [n][3] = Owner
				If $oProc.GetOwner($sUserName, $sUserDomain) = 0 Then $avProcs[$n][3] = $sUserDomain & "\" & $sUserName
				; [n][4] = Priority
				$avProcs[$n][4] = $oProc.Priority
				; [n][5] = Executable path
				$avProcs[$n][5] = $oProc.ExecutablePath
				; [n][8] = Creation date/time
				$dtmDate = $oProc.CreationDate
				If $dtmDate <> "" Then
					; Back referencing RegExp pattern from weaponx
					Local $sRegExpPatt = "\A(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})(?:.*)"
					$dtmDate = StringRegExpReplace($dtmDate, $sRegExpPatt, "$2/$3/$1 $4:$5:$6")
				EndIf
				$avProcs[$n][8] = $dtmDate
				; [n][9] = Command line string
				$avProcs[$n][9] = $oProc.CommandLine

				; increment index
				$n += 1
			Next
		Else
			SetError(2) ; Error getting process collection from WMI
		EndIf
		; release the collection object
		$colProcs = 0

		; Get collection of all processes from Win32_PerfFormattedData_PerfProc_Process
		; Have to use an SWbemRefresher to pull the collection, or all Perf data will be zeros
		Local $oRefresher = ObjCreate("WbemScripting.SWbemRefresher")
		$colProcs = $oRefresher.AddEnum($oWMI, "Win32_PerfFormattedData_PerfProc_Process").objectSet
		$oRefresher.Refresh

		; Time delay before calling refresher
		Local $iTime = TimerInit()
		Do
			Sleep(20)
		Until TimerDiff($iTime) >= 100
		$oRefresher.Refresh

		; Get PerfProc data
		For $oProc In $colProcs
			; Find it in the array
			For $n = 1 To $avProcs[0][0]
				If $avProcs[$n][1] = $oProc.IDProcess Then
					; [n][6] = CPU usage
					$avProcs[$n][6] = $oProc.PercentProcessorTime
					; [n][7] = memory usage
					$avProcs[$n][7] = $oProc.WorkingSet
					ExitLoop
				EndIf
			Next
		Next
	Else
		SetError(1) ; Error connecting to WMI
	EndIf

	; Return array
	Return $avProcs
EndFunc   ;==>_ProcessListProperties
;===============================================================================
; Function:		_IsIP
; Purpose:		Validate if string is an IP address
; Syntax:		_ProcessGetWin($iPID)
; Parameters:	$sIP = String to validate as IP address
; Returns:  	Success - 1=IP 2=Subnet
;				Failure - 0 ()
; Notes:
; Author:
; Date/Version:   	10/15/2014  --  v2.0.4
;===============================================================================
Func _IsIP($sIP, $P_strict = 0)
	$t_ip = $sIP
	$port = StringInStr($t_ip, ":") ;check for : (for the port)
	If $port Then ;has a port attached
		$t_ip = StringLeft($sIP, $port - 1) ;remove the port from the rest of the ip
		If $P_strict Then ;return 0 if port is wrong
			$zport = Int(StringTrimLeft($sIP, $port)) ;retrieve the port
			If $zport > 65000 Or $zport < 0 Then Return 0 ;port is wrong
		EndIf
	EndIf
	$zip = StringSplit($t_ip, ".")
	If $zip[0] <> 4 Then Return 0 ;incorect number of segments
	If Int($zip[1]) > 255 Or Int($zip[1]) < 1 Then Return 0 ;xxx.ooo.ooo.ooo
	If Int($zip[2]) > 255 Or Int($zip[1]) < 0 Then Return 0 ;ooo.xxx.ooo.ooo
	If Int($zip[3]) > 255 Or Int($zip[3]) < 0 Then Return 0 ;ooo.ooo.xxx.ooo
	If Int($zip[4]) > 255 Or Int($zip[4]) < 0 Then Return 0 ;ooo.ooo.ooo.xxx
	$BC = 1 ; is it 255.255.255.255 ?
	For $i = 1 To 4
		If $zip[$i] <> 255 Then $BC = 0 ;no
		;255.255.255.255 can never be a ip but anything else that ends with .255 can be
		;ex:10.10.0.255 can actually be an ip address and not a broadcast address
	Next
	If $BC Then Return 0 ;a broadcast address is not really an ip address...
	If $zip[4] = 0 Then ;subnet not ip
		If $port Then
			Return 0 ;subnet with port?
		Else
			Return 2 ;subnet
		EndIf
	EndIf
	Return 1 ;;string is a ip
EndFunc   ;==>_IsIP
;==============================================================================================
; Description:		FileRegister($ext, $cmd, $verb[, $def[, $icon = ""[, $desc = ""]]])
;					Registers a file type in Explorer
; Parameter(s):		$ext - 	File Extension without period eg. "zip"
;					$cmd - 	Program path with arguments eg. '"C:\test\testprog.exe" "%1"'
;							(%1 is 1st argument, %2 is 2nd, etc.)
;					$verb - Name of action to perform on file
;							eg. "Open with ProgramName" or "Extract Files"
;					$def - 	Action is the default action for this filetype
;							(1 for true 0 for false)
;							If the file is not already associated, this will be the default.
;					$icon - Default icon for filetype including resource # if needed
;							eg. "C:\test\testprog.exe,0" or "C:\test\filetype.ico"
;					$desc - File Description eg. "Zip File" or "ProgramName Document"
;===============================================================================================
Func _FileRegister($ext, $cmd, $verb, $def = 0, $icon = "", $desc = "")
	$loc = RegRead("HKCR\." & $ext, "")
	If @error Then
		RegWrite("HKCR\." & $ext, "", "REG_SZ", $ext & "file")
		$loc = $ext & "file"
	EndIf
	$curdesc = RegRead("HKCR\" & $loc, "")
	If @error Then
		If $desc <> "" Then
			RegWrite("HKCR\" & $loc, "", "REG_SZ", $desc)
		EndIf
	Else
		If $desc <> "" And $curdesc <> $desc Then
			RegWrite("HKCR\" & $loc, "", "REG_SZ", $desc)
			RegWrite("HKCR\" & $loc, "olddesc", "REG_SZ", $curdesc)
		EndIf
		If $curdesc = "" And $desc <> "" Then
			RegWrite("HKCR\" & $loc, "", "REG_SZ", $desc)
		EndIf
	EndIf
	$curverb = RegRead("HKCR\" & $loc & "\shell", "")
	If @error Then
		If $def = 1 Then
			RegWrite("HKCR\" & $loc & "\shell", "", "REG_SZ", $verb)
		EndIf
	Else
		If $def = 1 Then
			RegWrite("HKCR\" & $loc & "\shell", "", "REG_SZ", $verb)
			RegWrite("HKCR\" & $loc & "\shell", "oldverb", "REG_SZ", $curverb)
		EndIf
	EndIf
	$curcmd = RegRead("HKCR\" & $loc & "\shell\" & $verb & "\command", "")
	If Not @error Then
		RegRead("HKCR\" & $loc & "\shell\" & $verb & "\command", "oldcmd")
		If @error Then
			RegWrite("HKCR\" & $loc & "\shell\" & $verb & "\command", "oldcmd", "REG_SZ", $curcmd)
		EndIf
	EndIf
	RegWrite("HKCR\" & $loc & "\shell\" & $verb & "\command", "", "REG_SZ", $cmd)
	If $icon <> "" Then
		$curicon = RegRead("HKCR\" & $loc & "\DefaultIcon", "")
		If @error Then
			RegWrite("HKCR\" & $loc & "\DefaultIcon", "", "REG_SZ", $icon)
		Else
			RegWrite("HKCR\" & $loc & "\DefaultIcon", "", "REG_SZ", $icon)
			RegWrite("HKCR\" & $loc & "\DefaultIcon", "oldicon", "REG_SZ", $curicon)
		EndIf
	EndIf
EndFunc   ;==>_FileRegister
;===============================================================================
; Description:		FileUnRegister($ext, $verb)
;					UnRegisters a verb for a file type in Explorer
; Parameter(s):		$ext - File Extension without period eg. "zip"
;					$verb - Name of file action to remove
;							eg. "Open with ProgramName" or "Extract Files"
;===============================================================================
Func _FileUnRegister($ext, $verb)
	$loc = RegRead("HKCR\." & $ext, "")
	If Not @error Then
		$oldicon = RegRead("HKCR\" & $loc & "\shell", "oldicon")
		If Not @error Then
			RegWrite("HKCR\" & $loc & "\DefaultIcon", "", "REG_SZ", $oldicon)
		Else
			RegDelete("HKCR\" & $loc & "\DefaultIcon", "")
		EndIf
		$oldverb = RegRead("HKCR\" & $loc & "\shell", "oldverb")
		If Not @error Then
			RegWrite("HKCR\" & $loc & "\shell", "", "REG_SZ", $oldverb)
		Else
			RegDelete("HKCR\" & $loc & "\shell", "")
		EndIf
		$olddesc = RegRead("HKCR\" & $loc, "olddesc")
		If Not @error Then
			RegWrite("HKCR\" & $loc, "", "REG_SZ", $olddesc)
		Else
			RegDelete("HKCR\" & $loc, "")
		EndIf
		$oldcmd = RegRead("HKCR\" & $loc & "\shell\" & $verb & "\command", "oldcmd")
		If Not @error Then
			RegWrite("HKCR\" & $loc & "\shell\" & $verb & "\command", "", "REG_SZ", $oldcmd)
			RegDelete("HKCR\" & $loc & "\shell\" & $verb & "\command", "oldcmd")
		Else
			RegDelete("HKCR\" & $loc & "\shell\" & $verb)
		EndIf
	EndIf
EndFunc   ;==>_FileUnRegister
;===============================================================================
; Function:		_SetDefaultContextItem
; Purpose:		Set default context item for file type
; Syntax:		_SetDefaultContextItem($sExtention)
; Parameters:	$sExtention = File extention
;				$sVerb = Verb to set as default
; Returns:  	Success - 1
;				Failure - 0
; Notes:
; Author:
; Date/Version:   	10/15/2014  --  v1.1
;===============================================================================
Func _SetDefaultContextItem($sExtention, $sVerb)
	Local $sRegistryLocation = RegRead("HKCR\." & $sExtention, "")
	If @error Then Return 0

	RegWrite("HKCR\" & $sRegistryLocation & "\shell", "", "REG_SZ", $sVerb)
	If @error Then Return 0
	Return 1
EndFunc   ;==>_SetDefaultContextItem
;===============================================================================
; Function:		_GetDefaultContextItem
; Purpose:		Get default context item for file type
; Syntax:		_GetDefaultContextItem($sExtention)
; Parameters:	$sExtention = File extention
; Returns:  	Success - Current Verb
;				Failure - 0
; Notes:
; Author:
; Date/Version:   	10/15/2014  --  v1.1
;===============================================================================
Func _GetDefaultContextItem($sExtention)
	Local $sRegistryLocation = RegRead("HKCR\." & $sExtention, "")
	If @error Then Return 0

	Local $sVerb = RegRead("HKCR\" & $sRegistryLocation & "\shell", "")
	If @error Then Return 0

	Return $sVerb
EndFunc   ;==>_GetDefaultContextItem
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

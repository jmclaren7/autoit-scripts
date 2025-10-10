#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_UseX64=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <Array.au3>
#include <AutoItConstants.au3>
#include <StringConstants.au3>


Global $hDLL = DllOpen("user32.dll")
$aSSIDs = _GetSSIDs()
ConsoleWrite("SSIDs: " & UBound($aSSIDs) - 1 & @CRLF)
For $i = 0 To UBound($aSSIDs) - 1
    $Data = _GetDataFromSSID($aSSIDs[$i])
    _ArrayDisplay($Data)
	Exit
Next

Func _GetSSIDs()
    Local $iPID = Run(@ComSpec & " /c " & 'netsh wlan show profiles', @ScriptDir, @SW_HIDE, $STDOUT_CHILD + $STDERR_CHILD)
    ProcessWaitClose($iPID)
    Local $sOutput = StdoutRead($iPID)
    ;Local $aOutput = DllCall($hDLL, 'Int', 'OemToChar', 'str', $sOutput, 'str', '')
	;$sOutput = $aOutput[2]
    Local $aSSIDs = StringRegExp($sOutput, '(?m)\h+:\h+(.*?)$', $STR_REGEXPARRAYGLOBALMATCH)
    Return $aSSIDs
EndFunc   ;==>_GetSSIDs

Func _GetDataFromSSID($sSSID) ;returns "1" if key is not present
	Local $aData[9]

    Local $iPID = Run(@ComSpec & " /c " & 'netsh wlan show profiles name="' & $sSSID & '" key=clear', @ScriptDir, @SW_HIDE, $STDOUT_CHILD + $STDERR_CHILD)
    ProcessWaitClose($iPID)
    Local $sOutput = StdoutRead($iPID)

    ;Local $aOutput = DllCall($hDLL, 'Int', 'OemToChar', 'str', $sOutput, 'str', '')
	;$sOutput = $aOutput[2]



    ;$aRegExp = StringRegExp($sOutput, '"((?:""|[^"])*)"', $STR_REGEXPARRAYGLOBALMATCH)
	;$aPassword = StringRegExp($sOutput, '(*ANYCRLF)Key Content(*ANYCRLF)', $STR_REGEXPARRAYGLOBALMATCH)

	;ConsoleWrite($sOutput & @CRLF)

	$aData[0] = $sSSID

	$aRegEx = StringRegExp($sOutput, 'SSID name\h+: "(.+)"', $STR_REGEXPARRAYFULLMATCH)
	$aData[1] = @error ? ("Error") : ($aRegEx[1])

	$aRegEx = StringRegExp($sOutput, 'Authentication\h+: (.+)', $STR_REGEXPARRAYFULLMATCH)
	$aData[2] = @error ? ("Error") : ($aRegEx[1])

	$aRegEx = StringRegExp($sOutput, 'Cipher\h+: (.+)', $STR_REGEXPARRAYFULLMATCH)
	$aData[3] = @error ? ("Error") : ($aRegEx[1])
	$aData[3] = $aData[3] = "CCMP" ? ($aData[3]) : ("AES")

	$aRegEx = StringRegExp($sOutput, 'Key Content\h+: (.{10,})', $STR_REGEXPARRAYFULLMATCH)
	$aData[4] = @error ? ("Error") : ($aRegEx[1])

	$aRegEx = StringRegExp($sOutput, 'Connection mode\h+: (.+)', $STR_REGEXPARRAYFULLMATCH)
	$aData[5] = @error ? ("Error") : ($aRegEx[1])



	Return $aData
EndFunc   ;==>_GetKeyFromSSID
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=_Icon.ico
#AutoIt3Wrapper_Change2CUI=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <FileConstants.au3>
#include <Process.au3>
#include "CommonFunctions.au3"

Global $LogToFile = True

$Title = "Import reservations to DHCP server"
_ConsoleWrite("Start - " & $Title)


$File = FileOpenDialog ($Title, "", "Typical (*.txt;*.csv)|All (*.*)", $FD_FILEMUSTEXIST)
If @error Then Exit
$aLines = FileReadToArray ($File)
If @error Then Exit

For $i = 0 To UBound($aLines)-1 ; Loop lines read from file
	If $aLines[$i] = "" Or StringLeft($aLines[$i],1) = "#" Then ContinueLoop
	$aSplitLine = _StringSplitQ($aLines[$i])
	If UBound($aSplitLine) <> 12 Then
		Msgbox(0, $Title, "Error in file on line "&$i)
		_ArrayDisplay($aSplitLine)
		Exit
	EndIf
Next

_ConsoleWrite("Record Count: " & UBound($aLines))
If MsgBox(1, $Title, UBound($aLines)&" lines in file, all with correct value count, continue?") <> 1 Then Exit

For $i = 0 To UBound($aLines)-1
	If $aLines[$i] = "" Or StringLeft($aLines[$i],1) = "#" Then ContinueLoop
	$aSplitLine = _StringSplitQ($aLines[$i])

	$Server = $aSplitLine[4]
	$Scope = $aSplitLine[2]
	$IP = $aSplitLine[3]
	$MAC = $aSplitLine[4]
	$Name = $aSplitLine[5]
	$Description = $aSplitLine[6]
	$IP = $aSplitLine[3]

	$MAC = StringReplace($MAC, "-", "")
	$MAC = StringReplace($MAC, ":", "")

	$RunLine = "netsh dhcp server "&$Server&" scope "&$Scope&" add reservedip "&$IP&" "&$MAC&" """&$Name&""" """&$Description&""" ""BOTH"""
	_ConsoleWrite($RunLine)
	_RunDos ($RunLine)

Next

Msgbox(0, $Title, "Done.")


Func _StringSplitQ($String)
	$Split = StringRegExp($String, '["].*?["]|[^ ]+', $STR_REGEXPARRAYGLOBALMATCH)
	For $i = 0 To UBound($Split)-1
		If StringLeft($Split[$i], 1) = """" AND StringRight($Split[$i], 1) = """" Then
			$Split[$i] = StringTrimLeft(StringTrimRight($Split[$i], 1), 1)
		EndIf
	Next

	Return $Split
EndFunc
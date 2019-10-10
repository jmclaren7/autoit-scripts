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


$File = FileOpenDialog ($Title, "", "Comma Separated Values (*.csv)|All (*.*)", $FD_FILEMUSTEXIST)
If @error Then Exit
$Array = FileReadToArray ($File)
If @error Then Exit

For $i = 0 To UBound($Array)-1
	If $Array[$i] = "" Or StringLeft($Array[$i],1) = "#" Then ContinueLoop
	StringReplace($Array[$i], ",", "")
	If @error or @extended <> 5 Then
		Msgbox(0, $Title, "Error in file")
		Exit
	EndIf
Next

_ConsoleWrite("Record Count: " & UBound($Array))

For $i = 0 To UBound($Array)-1
	If $Array[$i] = "" Or StringLeft($Array[$i],1) = "#" Then ContinueLoop

	$Split = StringSplit($Array[$i], ",")
	$Server = $Split[1]
	$Scope = $Split[2]
	$IP = $Split[3]
	$MAC = $Split[4]
	$Name = $Split[5]
	$Description = $Split[6]

	$MAC = StringReplace($MAC, "-", "")
	$MAC = StringReplace($MAC, ":", "")

	$RunLine = "netsh dhcp server "&$Server&" scope "&$Scope&" add reservedip "&$IP&" "&$MAC&" """&$Name&""" """&$Description&""" ""BOTH"""
	_ConsoleWrite($RunLine)
	_RunDos ($RunLine)

Next

Msgbox(0, $Title, "Done.")

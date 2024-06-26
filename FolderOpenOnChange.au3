#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=_Icon.ico
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Description=OpenFolderOnChange
#AutoIt3Wrapper_Res_Fileversion=1.0.0.10
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_Language=1033
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <File.au3>
#include <String.au3>
#include <WinAPIShellEx.au3>
#include <Array.au3>


OnAutoItExitRegister("_Exit")

_ConsoleWrite("Start")

Opt("TrayMenuMode", 1 + 2)
Opt("TrayOnEventMode", 1)

Global $SettingsFile = @AppDataDir & "\OpenFolderOnChange.ini"

Global $Title = IniRead($SettingsFile, "settings", "title", "default")
_ConsoleWrite("INI Value: " & $Title)
If $Title = "default" Then
	$Title = "Open Folder On Change"
	IniWrite($SettingsFile, "settings", "title", $Title)
EndIf

Global $MonitorFolder = IniRead($SettingsFile, "settings", "monitorfolder", "default")
_ConsoleWrite("INI Value: " & $MonitorFolder)
If $MonitorFolder = "default" Then
	While Not _PromptSetup()
	WEnd
EndIf

TrayCreateItem("   " & $Title)
TrayItemSetState(-1, 128)
TrayCreateItem("")
$iSettings = TrayCreateMenu("Settings")
$tSetFolder = TrayCreateItem("Select Folder", $iSettings)
TrayItemSetOnEvent(-1, "_PromptSetup")
$tSetFolder = TrayCreateItem("Open Settings INI", $iSettings)
TrayItemSetOnEvent(-1, "_OpenINI")
TrayCreateItem("")
$tOpenFolder = TrayCreateItem("Open Folder")
TrayItemSetOnEvent(-1, "_OpenFolder")
TrayCreateItem("")
$tExit = TrayCreateItem("Exit")
TrayItemSetOnEvent(-1, "_Exit")

TraySetToolTip($Title & @CRLF & $MonitorFolder)

$LastCount = -1
Local $aLastFiles[0]

_ConsoleWrite("Main")
While 1
	$aFiles = _FileListToArray($MonitorFolder)
	$ListError = @error
	If $ListError = 4 Then
		_ConsoleWrite("Error 4 (Empty)")
		Local $aFiles[1]
		$aFiles[0] = 0
		$ListError = 0
	EndIf


	If Not $ListError Then
		$Count = $aFiles[0]
		_ArrayDelete($aFiles, 0)
		_ConsoleWrite("Count " & $Count)

		If $Count > $LastCount And $LastCount <> -1 Then
			_ConsoleWrite("Count Increased")
			$aDiff = _ArraySubtract($aFiles, $aLastFiles)

			_OpenFolder($MonitorFolder, $aDiff)

		EndIf

		$LastCount = $Count
		$aLastFiles = $aFiles

	Else
		_ConsoleWrite("_FileListToArray Error (" & @error & ")")

	EndIf

	Sleep(4000)
WEnd

Func _ArraySubtract($aArray1, $aArray2)
	For $a = UBound($aArray1) - 1 To 0 Step -1
		For $b = 0 To UBound($aArray2) - 1
			If $aArray1[$a] = $aArray2[$b] Then
				_ArrayDelete($aArray1, $a)
				ExitLoop
			EndIf
		Next
	Next

	Return $aArray1
EndFunc   ;==>_ArraySubtract
Func _OpenINI()
	ShellExecute($SettingsFile)
EndFunc   ;==>_OpenINI


Func _OpenFolder($sOpenPath = $MonitorFolder, $aNames = 0)
	;Use eval to deal with using this function as a tray event
	If Eval("sOpenPath") = "" Then $sOpenPath = $MonitorFolder
	If Eval("aNames") = "" Then $aNames = 0

	_WinAPI_ShellOpenFolderAndSelectItems($sOpenPath, $aNames)

	$FolderName = StringTrimLeft($sOpenPath, StringInStr($sOpenPath, "\", 0, -1))
	If WinActive($FolderName) Then
		Send("{F5}")
		_ConsoleWrite("Sent F5")
	EndIf
EndFunc   ;==>_OpenFolder

Func _PromptSetup()
	$NewFolder = FileSelectFolder("dialog text", "")
	If $NewFolder <> "" Then
		_ConsoleWrite("New Value: " & $NewFolder)
		IniWrite($SettingsFile, "settings", "monitorfolder", $NewFolder)
		$MonitorFolder = $NewFolder
		TraySetToolTip($MonitorFolder)
		Return $NewFolder
	Else
		Return SetError(1, 0, False)
	EndIf

EndFunc   ;==>_PromptSetup

Func _Exit()

	Exit
EndFunc   ;==>_Exit

Func _FileCount($sTargetDir, $sWildPattern = "*.*")
	If Not FileExists($sTargetDir) Then Return SetError(1)
	If $sWildPattern = Default Then $sWildPattern = "*.*"
	If StringRight($sTargetDir, 1) <> "\" Then $sTargetDir &= '\'

	Local $hFound, $sNext, $iCount = 0

	$hFound = FileFindFirstFile($sTargetDir & $sWildPattern)

	If $hFound = -1 Then
		FileClose($hFound)
		Return $iCount
	EndIf

	While True
		$sNext = FileFindNextFile($hFound)
		If @error Then
			ExitLoop
		ElseIf Not @extended Then
			$iCount += 1
		EndIf
	WEnd

	FileClose($hFound)
	Return $iCount
EndFunc   ;==>_FileCount

;===============================================================================
; Function Name:   	_ConsoleWrite()
; Description:		Console & File Loging
; Call With:		_ConsoleWrite($Text,$SameLine)
; Parameter(s): 	$Text - Text to print
;					$Level - The level the given message *is*
;					$SameLine - (Optional) Will continue to print on the same line if set to 1
;
; Return Value(s):  The Text Originaly Sent
; Notes:			Will see if global var $DEBUGLOG=1 or $CmdLineRaw contains "-debuglog" to see if log file should be writen
;					If Text = "OPENLOG" then log file is displayed (casesense)
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		06/1/2012  --  v1.1
;===============================================================================
Func _ConsoleWrite($sMessage, $iLevel = 1, $iSameLine = 0)
	Local $hHandle, $sData

	If Eval("LogFilePath") = "" Then Global $LogFilePath = StringTrimRight(@ScriptFullPath, 4) & "_Log.txt"
	If Eval("LogFileMaxSize") = "" Then Global $LogFileMaxSize = 0
	If Eval("LogToFile") = "" Then Global $LogToFile = False
	If Eval("LogLevel") = "" Then Global $LogLevel = 3 ; The level of message to log - If no level set to 3
	If $sMessage == "OPENLOG" Then Return ShellExecute($LogFilePath)

	If $iLevel <= $LogLevel Then
		$sMessage = StringReplace($sMessage, @CRLF & @CRLF, @CRLF) ;Remove Double CR
		If StringRight($sMessage, StringLen(@CRLF)) = @CRLF Then $sMessage = StringTrimRight($sMessage, StringLen(@CRLF)) ; Remove last CR

		Local $sTime = @YEAR & "-" & @MON & "-" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC & "> " ; Generate Timestamp
		$sMessage = StringReplace($sMessage, @CRLF, @CRLF & _StringRepeat(" ", StringLen($sTime))) ; Uses spaces after initial line if string had returns

		If Not $iSameLine Then $sMessage = @CRLF & $sTime & $sMessage

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

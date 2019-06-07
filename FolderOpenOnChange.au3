#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\..\Google Drive\Autoit\_Icon.ico
#AutoIt3Wrapper_Res_Description=OpenFolderOnChange
#AutoIt3Wrapper_Res_Fileversion=1.0.0.0
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_Language=1033
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <File.au3>
#include <String.au3>
#include <WinAPIShellEx.au3>
#include <Array.au3>


OnAutoItExitRegister ("_Exit")

_ConsoleWrite("Start")

Opt("TrayMenuMode", 1+2)
Opt("TrayOnEventMode", 1)

$tExit = TrayCreateItem("Exit")
TrayItemSetOnEvent(-1, "_Exit")
$tSetFolder = TrayCreateItem("Set Folder To Monitor")
TrayItemSetOnEvent(-1, "_PromptSetup")

$Title = "Open Folder On Change"
$SettingsFile = @AppDataDir & "\OpenFolderOnChange.ini"

Global $MonitorFolder = IniRead($SettingsFile,"settings", "monitorfolder", "Q:\Scans")
_ConsoleWrite("INI Value: "&$MonitorFolder)
If $MonitorFolder = "default" Then _PromptSetup()


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
	Endif


	If Not $ListError Then
		$Count = $aFiles[0]
		_ArrayDelete ( $aFiles, 0)
		_ConsoleWrite("Count "&$Count)

		If $Count > $LastCount AND $LastCount <> -1 Then
			_ConsoleWrite("Count Increased")
			$aDiff = _ArraySubtract($aFiles, $aLastFiles)
			_WinAPI_ShellOpenFolderAndSelectItems ($MonitorFolder, $aDiff)

			$FolderName = StringTrimLeft($MonitorFolder,StringInStr($MonitorFolder,"\",0,-1))
			If WinActive($FolderName) Then
				Send("{F5}")
				_ConsoleWrite("Sent F5")
			EndIf

		EndIf

		$LastCount = $Count
		$aLastFiles = $aFiles

	Else
		_ConsoleWrite("_FileListToArray Error ("&@error&")")

	Endif

	Sleep(4000)
Wend

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
Endfunc


Func _PromptSetup()
	$NewFolder = FileSelectFolder ( "dialog text", "")
	If $NewFolder <> "" Then
		_ConsoleWrite("New Value: "&$NewFolder)
		IniWrite($SettingsFile,"settings", "monitorfolder", $NewFolder)
		$MonitorFolder = $NewFolder
		Return $NewFolder
	Else
		Return SetError(1,0,False)
	EndIf

EndFunc

Func _Exit()

	Exit
Endfunc

Func _FileCount($sTargetDir, $sWildPattern = "*.*")
	If Not FileExists($sTargetDir) Then Return SetError(1)
	If $sWildPattern = Default Then $sWildPattern = "*.*"
	If StringRight($sTargetDir,1) <> "\" Then $sTargetDir &= '\'

	Local $hFound , $sNext, $iCount = 0

	$hFound = FileFindFirstFile($sTargetDir & $sWildPattern)

	If $hfound = -1 Then
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
EndFunc

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
Func _ConsoleWrite($sMessage, $iLevel=1, $iSameLine=0)
	Local $hHandle, $sData

	if Eval("LogFilePath")="" Then Global $LogFilePath = StringTrimRight(@ScriptFullPath,4)&"_Log.txt"
	if Eval("LogFileMaxSize")="" Then Global $LogFileMaxSize = 0
	if Eval("LogToFile")="" Then Global $LogToFile = False
	if Eval("LogLevel")="" Then Global $LogLevel = 3 ; The level of message to log - If no level set to 3
	If $sMessage=="OPENLOG" Then Return ShellExecute($LogFilePath)

	If $iLevel<=$LogLevel then
		$sMessage=StringReplace($sMessage,@CRLF&@CRLF,@CRLF) ;Remove Double CR
		If StringRight($sMessage,StringLen(@CRLF))=@CRLF Then $sMessage=StringTrimRight($sMessage,StringLen(@CRLF)) ; Remove last CR

		Local $sTime=@YEAR&"-"&@MON&"-"&@MDAY&" "&@HOUR&":"&@MIN&":"&@SEC&"> " ; Generate Timestamp
		$sMessage=StringReplace($sMessage,@CRLF,@CRLF&_StringRepeat(" ",StringLen($sTime))) ; Uses spaces after initial line if string had returns

		if NOT $iSameLine then $sMessage=@CRLF&$sTime&$sMessage

		ConsoleWrite($sMessage)

		If $LogToFile Then
			if $LogFileMaxSize<>0 AND FileGetSize($LogFilePath) > $LogFileMaxSize*1024 then
				$sMessage=FileRead($LogFilePath) & $sMessage
				$sMessage=StringTrimLeft($sMessage,StringInStr($sMessage, @CRLF, 0, 5))
				$hHandle=FileOpen($LogFilePath,2)
			Else
				$hHandle=FileOpen($LogFilePath,1)
			endif
			FileWrite($hHandle,$sMessage)
			FileClose($hHandle)

		endif
	endif

	Return $sMessage
EndFunc ;==> _ConsoleWrite
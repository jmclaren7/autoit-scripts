#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Res_Fileversion=1.0.0.45
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_Language=1033
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <Constants.au3>
#Include <String.au3>
#NoTrayIcon

Global $Title = @ScriptName
Global $LogToFile = True
Global $LogFileMaxSize = 1024

_ConsoleWrite("Start - " & $Title)

;Command line parameters
If $CmdLine[0] >= 1 Then
	$Parameter1 = $CmdLine[1]
Else
	$Parameter1 = ""
EndIf

;INI
$SettingsFile = StringTrimRight(@ScriptName, 4) & ".ini"
$SettingsFileFullPath = @ScriptDir & "\" & $SettingsFile

While 1
	$UserFoldersPath = IniRead($SettingsFileFullPath, "Settings", "UsersFolderPath", "notset")
	If $UserFoldersPath <> "notset" AND FileExists($UserFoldersPath) Then
		If StringRight($UserFoldersPath, 1) = "\" AND StringRight($UserFoldersPath, 2) <> ":\" Then
			$UserFoldersPath = StringTrimRight($UserFoldersPath, 1)
		EndIf
		ExitLoop
	Else
		$Msg = MsgBox(1, $Title, "Users folder path not set or invalid (" & $UserFoldersPath & "), click ok to select a folder to use", 10)
		If $Msg <> 1 Then Exit
		$NewFolderPath = FileSelectFolder("Select a folder for users", "", 0, "")
		If @error Then Exit
		If FileExists($NewFolderPath) Then
			IniWrite($SettingsFileFullPath, "Settings", "UsersFolderPath", $NewFolderPath)
			MsgBox(0, $Title, "Folder path saved")
		Endif
	EndIf
Wend

$ExcludeUsers = IniRead($SettingsFileFullPath, "Settings", "ExcludeUsers", "notset")
If $ExcludeUsers = "notset" Then IniWrite($SettingsFileFullPath, "Settings", "ExcludeUsers", "")

;Execute the AD query to get user list and disabled status
$Command = 'dsquery group -samid "Domain Users"  | dsget group -members | dsget user -samid -disabled'
$iPid = Run(@ComSpec & " /c " & $Command, "", @SW_MINIMIZE, $STDERR_MERGED)

Local $sData
While 1
	$sData &= StdoutRead($iPid)
    If @error Then ExitLoop
Wend

;Create array from query output
$aData = StringSplit($sData, @CRLF, $STR_ENTIRESPLIT)
_ConsoleWrite("Raw Output:")
_ConsoleWrite($sData)

;Loop array of users
_ConsoleWrite("Loop array")
For $i=2 to $aData[0]-1
	$User = $aData[$i]

	;Trim raw lines that contain trailing and leading spaces
	$User = StringStripWS($User, $STR_STRIPLEADING+$STR_STRIPTRAILING)

	;Skip disabled users and trim disabled status
	If StringRight($User, 3) = " no" Then
		$User = StringStripWS(StringTrimRight($User, 3), $STR_STRIPLEADING+$STR_STRIPTRAILING)

	Elseif StringRight($User, 3) = "yes" Then
		$User = StringStripWS(StringTrimRight($User, 3), $STR_STRIPLEADING+$STR_STRIPTRAILING)
		_ConsoleWrite($User & " - skipped because deactivated")
		ContinueLoop
	Else
		_ConsoleWrite("Invalid line, $User=""" & $User & """")
		ContinueLoop
	EndIf

	;Skip empty usernames
	If $User = "" Then ContinueLoop

	;Skip users that exist in skip list
	If StringInStr($ExcludeUsers, $User) Then
		_ConsoleWrite($User & " - skipped because exclude list")
		ContinueLoop
	EndIf

	;Full path of the users folder to check
	$UserFolder = $UserFoldersPath & "\" & $User

	;If users folder already exists do nothing
	If FileExists ($UserFolder) Then
		_ConsoleWrite($User & " - folder exists")

	;Otherwise, create the users folder and set permisions
	Else
		;Check parameters so that we only actualy make any changes if the right parameter exists
		If $Parameter1 = "update" Then
			DirCreate($UserFolder)
			;Set permisions to write (not full)
			RunWait(@ComSpec & ' /c CACLS "'&$UserFolder&'" /E /T /C /G "'&$User&'":C','',@sw_hide)
			_ConsoleWrite($User & " - folder created, return: "&@error)
		Else
			_ConsoleWrite($User & " - folder created (dry run)")
		Endif

	EndIf

Next

_ConsoleWrite("End")


;=================================================================================================
;Common Functions
;=================================================================================================
Func _ConsoleWrite($sMessage, $iLevel=1, $iSameLine=0)
	Local $hHandle, $sData

	if Eval("LogFilePath")="" Then Global $LogFilePath = StringTrimRight(@ScriptFullPath,4)&"_Log.txt"
	if Eval("LogFileMaxSize")="" Then Global $LogFileMaxSize = 0
	if Eval("LogToFile")="" Then Global $LogToFile = False
	if StringInStr($CmdLineRaw, "-debuglog") Then Global $LogToFile = True
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
#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=_Icon.ico
#AutoIt3Wrapper_Change2CUI=n
#AutoIt3Wrapper_Res_Fileversion=1.0.0.75
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_Language=1033
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#RequireAdmin
#NoTrayIcon

#include <Constants.au3>
#Include <String.au3>

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

If $Parameter1 = "update" Then
	$Update = True
Else
	_ConsoleWrite("Dry Run")
	$Update = False
EndIf

;INI
$SettingsFile = StringTrimRight(@ScriptName, 4) & ".ini"
$SettingsFileFullPath = @ScriptDir & "\" & $SettingsFile

While 1
	$LoopProgram = IniRead($SettingsFileFullPath, "Settings", "LoopProgram", "0")
	Global $LogLevel = IniRead($SettingsFileFullPath, "Settings", "LogLevel", "1")

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

	$ExcludeCharacters = IniRead($SettingsFileFullPath, "Settings", "ExcludeUsersWithCharacters", "")
	$aExcludeCharacters = StringSplit($ExcludeCharacters,"")
	_ConsoleWrite("Characters exluded: "&$aExcludeCharacters[0])

	$PSCommand = 'Get-ADGroupMember \"Domain users\" -recursive | Get-ADUser | Where { $_.Enabled -eq $True} | Select SamAccountName | Format-Table -HideTableHeaders'
	$PSCommand = 'powershell.exe -nologo -executionpolicy bypass -WindowStyle hidden -noprofile -command "&{' & $PSCommand & '}"'
	_ConsoleWrite($PSCommand)
	$iPid = Run(@ComSpec & ' /c ' & $PSCommand, "", @SW_MINIMIZE, $STDERR_MERGED)

	Local $sData
	While 1
		$sData &= StdoutRead($iPid)
		If @error Then ExitLoop
	Wend

	;Create array from query output
	$aData = StringSplit($sData, @CRLF, $STR_ENTIRESPLIT)
	_ConsoleWrite("Raw Output:" & @CRLF & $sData, 3)

	;Loop array of users
	_ConsoleWrite("Loop array", 2)
	For $i=2 to $aData[0]-1
		$User = $aData[$i]
		_ConsoleWrite($User & " - $i=" & $i & " $aData[0]=" & $aData[0], 2)

		;Trim raw lines that contain trailing and leading spaces
		$User = StringStripWS($User, $STR_STRIPLEADING+$STR_STRIPTRAILING)

		;Skip empty
		If $User = "" Then ContinueLoop

		;Skip if special characters
		For $r=1 to $aExcludeCharacters[0]
			If StringInStr($User, $aExcludeCharacters[$i]) Then
				_ConsoleWrite($User & " - skipped because special character", 2)
				ContinueLoop 2
			endif
		Next

		;Skip users that exist in skip list
		If StringInStr($ExcludeUsers, $User) Then
			_ConsoleWrite($User & " - skipped because exclude list", 2)
			ContinueLoop
		EndIf

		;Full path of the users folder to check
		$UserFolder = $UserFoldersPath & "\" & $User

		; If user folder doesnt exit, create it and set permisions
		If NOT FileExists ($UserFolder) Then
			_ConsoleWrite($User & " - user folder doesn't exist, creating folder")
			If $Update Then
				DirCreate($UserFolder)
				_ConsoleWrite($User & " - folder created, return: "&@error)
			EndIf

		Else
			_ConsoleWrite($User & " - folder exists")

		Endif

		If $Update Then
			;Set permisions to write (not full)
			$Command = 'iCACLS "'&$UserFolder&'" /T /C /Grant "'&$User&'":(OI)(CI)M'
			_ConsoleWrite($User & " - raw command: " & $Command, 2)
			RunWait(@ComSpec & ' /c ' & $Command,'',@SW_HIDE)
		Endif


		; If NestedFolder1 is set and does not exist, create folder
		$NestedFolder1 = IniRead($SettingsFileFullPath, "Settings", "NestedFolder1", "")
		$NestedFolder1FullPath = $UserFolder & "\" & $NestedFolder1
		If $NestedFolder1 Then
			_ConsoleWrite($User & " - $NestedFolder1="&$NestedFolder1, 2)
			If Not FileExists ($NestedFolder1FullPath) Then
				_ConsoleWrite($User & " - nested folder doesn't exist, creating folder", 2)
				If $Update Then DirCreate($NestedFolder1FullPath)
				_ConsoleWrite($User & " - folder created, return: "&@error, 2)

			Else
				_ConsoleWrite($User & " - nested folder exists", 2)

			EndIf

		Else
			_ConsoleWrite($User & " - nested folder not set", 2)

		EndIf


		; If NestedFolderUser1 is set and folder exists, update acl
		$NestedFolderUser1 = IniRead($SettingsFileFullPath, "Settings", "NestedFolderUser1", "")
		If $NestedFolderUser1 Then
			_ConsoleWrite($User & " - $NestedFolderUser1="&$NestedFolderUser1, 2)

			If FileExists ($NestedFolder1FullPath) Then
				_ConsoleWrite($User & " - nested folder exists, setting acl", 2)
					$Command = ' iCACLS "'&$NestedFolder1FullPath&'" /Grant "'&$NestedFolderUser1&'":W /T /C'
					_ConsoleWrite($User & " - raw command: "&$Command, 2)
					If $Update Then RunWait(@ComSpec & ' /c ' & $Command,'',@SW_HIDE)
			Else
				_ConsoleWrite($User & " - nested folder does not exists", 2)

			EndIf

		Else
			_ConsoleWrite($User & " - NestedFolderUser1 not set", 2)

		EndIf


	Next

	If $LoopProgram = 0 Then
		ExitLoop
	Else
		Sleep($LoopProgram * 1000)
	Endif

Wend

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
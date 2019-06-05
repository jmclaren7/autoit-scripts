#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\..\Google Drive\Autoit\_Icon.ico
#AutoIt3Wrapper_Res_Description=OpenFolderOnChange
#AutoIt3Wrapper_Res_Fileversion=1.0.0.0
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_Language=1033
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

Opt("TrayMenuMode", 1+2)
Opt("TrayOnEventMode", 1)

$tExit = TrayCreateItem("Exit")
TrayItemSetOnEvent(-1, "_Exit")
OnAutoItExitRegister ("_Exit")

$Title = "Open Folder On Change"
$SettingsFile = @AppDataDir & "\OpenFolderOnChange.ini"

$MonitorFolder = IniRead($SettingsFile,"settings", "monitorfolder", "default")
If $MonitorFolder = "default" Then _PromptSetup()

While 1
	;Get file count
	;Compare file count
		;Open folder if count increases

	Sleep(4000)
Wend

Func _PromptSetup()
	FileSelectFolder ( "dialog text", "")


EndFunc

Func _Exit()

Endfunc
#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=_Icon.ico
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Fileversion=2.0.0.4
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=p
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

Global $Title = StringTrimRight(@ScriptName, 4)
Global $Version = FileGetVersion(@ScriptFullPath)
Global $TitleVersion = $Title & " v" & StringLeft($Version, StringInStr($Version, ".", 0, -1) - 1)

If MsgBox(1, $TitleVersion, "Release and renew IP address?") <> 1 Then Exit

For $i=1 To 10

	_CMD("ipconfig /release")

	Sleep(4*1000)
	_CMD("ipconfig /renew")

	Sleep(8*1000)
	_CMD("powershell -Command stop-service -ServiceName ScreenConnect*")

	Sleep(2*1000)
	_CMD("powershell -Command start-service -ServiceName ScreenConnect*")

	$Msg = MsgBox(1, $TitleVersion, "Release and renew will try again in 60 seconds.", 60)
	If $Msg <> -1 And $Msg <> 1 Then Exit
Next

Func _CMD($Program, $Workingdir = Default, $Show_flag = Default, $Opt_flag = Default)
	Return Run(@ComSpec & " /c " & $Program, $Workingdir, $Show_flag, $Opt_flag)

EndFunc
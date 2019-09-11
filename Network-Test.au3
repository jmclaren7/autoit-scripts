#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=_Icon.ico
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Compile_Both=y
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Res_Comment=Network testing tool
#AutoIt3Wrapper_Res_Description=Network testing tool
#AutoIt3Wrapper_Res_Fileversion=1.0.0.17
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_ProductName=Network-Test
#AutoIt3Wrapper_Res_ProductVersion=1
#AutoIt3Wrapper_Res_CompanyName=JCS Consulting
#AutoIt3Wrapper_Res_LegalCopyright=JCS Consulting
#AutoIt3Wrapper_Res_LegalTradeMarks=JCS Consulting
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/pe /sf /sv /rm
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#pragma compile(AutoItExecuteAllowed, True)

#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <Array.au3>
#include <String.au3>
#include <WinAPIShellEx.au3>
#include "CommonFunctions.au3"

Opt("GUIOnEventMode", 1)
Opt("TrayMenuMode", 3)
Opt("TrayOnEventMode", 1)

Global $RunState = False
Global $MainSize = FileGetSize(@ScriptFullPath)
Global $Version = FileGetVersion (@ScriptFullPath)&"-"&$MainSize
Global $Title = "Network-Test v"&$Version
Global $LogFile = StringTrimRight(@ScriptName,4)&"_Log.txt"
Global $LogFilePath = @TempDir&"\"&$LogFile
Global $LogFileMaxSize = 1024*1024*5
Global $LogToFile = False

$TrayShow = TrayCreateItem("Show GUI")
TrayItemSetOnEvent ($TrayShow, "_ShowGUI" )
$TrayAbout = TrayCreateItem("About")
TrayItemSetOnEvent ($TrayAbout, "_AboutMsg" )
TrayCreateItem("")
$TrayExit = TrayCreateItem("Exit")
TrayItemSetOnEvent ($TrayExit, "_Exit" )

#Region ### START Koda GUI section ###
$NetTestGUI1 = GUICreate("", 609, 381, -1, -1)
$EditHost = GUICtrlCreateEdit("", 8, 27, 209, 249)
$EditLog = GUICtrlCreateEdit("", 224, 27, 377, 249, BitOR($GUI_SS_DEFAULT_EDIT,$ES_READONLY))
GUICtrlSetData(-1, "")
$Label1 = GUICtrlCreateLabel("Hosts (one per line)", 8, 8, 95, 17)
$Label2 = GUICtrlCreateLabel("Log", 224, 8, 22, 17)
$ButtonExit = GUICtrlCreateButton("Exit", 440, 339, 139, 25)
$ButtonStart = GUICtrlCreateButton("Start", 271, 295, 139, 25)
$Group1 = GUICtrlCreateGroup("Options", 8, 287, 241, 81)
$CheckBoxErrorOnly = GUICtrlCreateCheckbox("Only Log Errors", 24, 311, 97, 17)
$InputDelay = GUICtrlCreateInput("1000", 24, 335, 57, 21)
$Label3 = GUICtrlCreateLabel("Delay Between Pings (ms)", 87, 337, 127, 17)
$CheckboxLogFile = GUICtrlCreateCheckbox("Log To File", 136, 311, 97, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$ButtonStop = GUICtrlCreateButton("Stop", 271, 339, 139, 25)
GUICtrlSetState(-1, $GUI_DISABLE)
$ButtonOpenLog = GUICtrlCreateButton("Open Log Location", 440, 296, 139, 25)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

GUISetOnEvent($GUI_EVENT_CLOSE, "_HideGUI")
GUISetOnEvent($GUI_EVENT_MINIMIZE, "_HideGUI")
GUICtrlSetOnEvent ($ButtonStart, "_Start")
GUICtrlSetOnEvent ($ButtonStop, "_Stop")
GUICtrlSetOnEvent ($ButtonOpenLog, "_OpenLog")
GUICtrlSetOnEvent ($ButtonExit, "_Exit")

WinSetTitle ($NetTestGUI1, "", $Title)

Global $Log
_Log("Program Start")

$Adapter = _NetAdapterInfo()
GUICtrlSetData($EditHost,$Adapter[4]&@CRLF&"1.1.1.1"&@CRLF&"google.com")

While 1
	$Delay = Int(GUICtrlRead($InputDelay))
	If $Delay < 10 OR $Delay > 10000 Then
		_sleep(2000)
		$Delay = Int(GUICtrlRead($InputDelay))
		If $Delay < 10 Then
			GUICtrlSetData($InputDelay, 10)
		ElseIf $Delay > 10000 Then
			_sleep(1000)
			GUICtrlSetData($InputDelay, 10000)
		Endif
		$Delay = Int(GUICtrlRead($InputDelay))
	Endif

	If _IsChecked($CheckboxLogFile) Then
		$LogToFile = True
	Else
		$LogToFile = False
	EndIf

	If $RunState Then
		$Hosts = GUICtrlRead($EditHost)
		$Hosts = StringReplace($Hosts, @CRLF&@CRLF, "")
		$Hosts = StringSplit($Hosts, @CRLF, 1)
		For $i=1 To $Hosts[0]
			If Not $RunState Then ExitLoop

			$ThisHost = StringStripWS($Hosts[$i], 8)
			If $ThisHost = "" Then ContinueLoop

			$Latency = Ping($ThisHost, 200)
			If Not @error AND NOT _IsChecked($CheckBoxErrorOnly) Then
				_Log($ThisHost & ":  time=" & $Latency & "ms ")
			ElseIf @error Then
				Switch @error
					Case 1
						$Desc = "Host is offline"
					Case 2
						$Desc = "Host is unreachable"
					Case 3
						$Desc = "Bad destination"
					Case 4
						$Desc = "Unknown error"

				EndSwitch

				_Log($ThisHost & ":  error=" & $Desc)
			EndIf

			If $Latency > $Delay Then $Latency = $Delay
			_sleep(_Log($Delay-$Latency))
		Next
	EndIf

	sleep(10)
WEnd
;============================================================================================================
;============================================================================================================
Func _Start()
	_Log("Start")
	$RunState = True
	GUICtrlSetState($ButtonStop, $GUI_ENABLE)
	GUICtrlSetState($ButtonStart, $GUI_DISABLE)
EndFunc
Func _Stop()
	_Log("Stop")
	$RunState = False
	GUICtrlSetState($ButtonStop, $GUI_DISABLE)
	GUICtrlSetState($ButtonStart, $GUI_ENABLE)
EndFunc
Func _Log($Data)
	$Log = $Log & _ConsoleWrite($Data)
	GUICtrlSetData($EditLog, $Log)
	GUICtrlSendMsg($EditLog, "0xB7", 0, 0)
	Return $Data
EndFunc

Func _NetAdapterInfo()
	_Log("Collecting Adapter Information")
	Local $Data[6]
	Local $objWMIService = ObjGet('winmgmts:\\' & @ComputerName & '\root\CIMV2')
	Local $colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_NetworkAdapterConfiguration WHERE IPEnabled=true")
	For $objAdapter In $colItems
		If StringStripWS($objAdapter.DefaultIPGateway(0), 8) <> "" Then
				$Data[1] = $objAdapter.DNSDomain
				$Data[2] = $objAdapter.MACAddress
				$Data[3] = $objAdapter.IPAddress(0)
				$Data[4] = $objAdapter.DefaultIPGateway(0)
				$Data[5] = $objAdapter.IPSubnet(0)
				Return $Data
		EndIf
	Next

	Return SetError(1, 0, $Data)
EndFunc
Func _OpenLog()
	_Log("Opening Log Location")
	_WinAPI_ShellOpenFolderAndSelectItems ($LogFilePath)
EndFunc
Func _HideGUI()
	GUISetState(@SW_HIDE, $NetTestGUI1)
	TrayTip ( "Network-Test", "Still Running"&@CRLF&"Minimized To Tray", 2)
EndFunc
Func _ShowGUI()
	GUISetState(@SW_SHOW, $NetTestGUI1)
EndFunc
Func _Exit()
	Exit
EndFunc
Func _AboutMsg()
	Run(@AutoItExe & ' /AutoIt3ExecuteLine "MsgBox(4096, '''&$Title&''', ''Tool for logging pings.'')"')
EndFunc


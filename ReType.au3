#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Res_Fileversion=3.0.0.8
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#AutoIt3Wrapper_Icon=_Icon.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <GUIListBox.au3>
#include <StaticConstants.au3>
#include <TabConstants.au3>
#include <WindowsConstants.au3>

Opt("TrayIconHide", 1)
Opt("GUIOnEventMode", 1)

Global $TITLE="ReType"
Global $VERSION=FileGetVersion(@AutoItExe)
Global $GUITITLE=$TITLE&" v"&$VERSION

#Region ### START Koda GUI section ###
$Form1 = GUICreate($GUITITLE, 324, 181, -1, -1)
$Button1 = GUICtrlCreateButton("Send", 158, 154, 75, 17)
$Button2 = GUICtrlCreateButton("Close", 239, 154, 75, 17)
$Tab1 = GUICtrlCreateTab(2, 2, 321, 169, BitOR($TCS_BOTTOM,$TCS_FLATBUTTONS))
$TabSheet1 = GUICtrlCreateTabItem("Text")
$SendList = GUICtrlCreateEdit("", 6, 7, 314, 142, -1, 0)
$TabSheet2 = GUICtrlCreateTabItem("Settings")
$ExitCheckbox = GUICtrlCreateCheckbox("Exit When Done", 121, 51, 97, 17)
GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
$UpdelayInput = GUICtrlCreateInput("5", 179, 16, 21, 21)
$Label1 = GUICtrlCreateLabel("Up Delay (ms)", 116, 20, 68, 18)
GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
$Label2 = GUICtrlCreateLabel("Start Delay (s)", 9, 20, 76, 18)
GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
$StartDelayInput = GUICtrlCreateInput("4", 74, 16, 21, 21)
$SendRawCheckbox = GUICtrlCreateCheckbox("Send Raw Mode", 12, 51, 97, 17)
GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
$DownDelayInput = GUICtrlCreateInput("10", 291, 16, 21, 21)
$Label5 = GUICtrlCreateLabel("Down Delay (ms)", 217, 20, 75, 18)
GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
$Group3 = GUICtrlCreateGroup("Dashes", 10, 77, 137, 65)
$NoChangeRadio = GUICtrlCreateRadio("No Change", 15, 90, 69, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
$ConvertRadio = GUICtrlCreateRadio("Convert Dashes to Tabs", 15, 122, 129, 17)
GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
$RemoveDashesRadio = GUICtrlCreateRadio("Remove Dashes", 15, 106, 97, 17)
GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group1 = GUICtrlCreateGroup("Repeat", 160, 77, 153, 65)
$SendCountInput = GUICtrlCreateInput("1", 262, 90, 21, 21)
$Label3 = GUICtrlCreateLabel("Send Count", 169, 93, 76, 18)
GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
$Label4 = GUICtrlCreateLabel("Repeat Delay (ms)", 169, 117, 85, 28)
GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
$RepeatDelayInput = GUICtrlCreateInput("0", 262, 114, 40, 21)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$KeepOnTopCheckbox = GUICtrlCreateCheckbox("Keep On Top", 236, 51, 81, 17)
GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
GUICtrlCreateTabItem("")
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

GUICtrlSetOnEvent($Button1, "_GUI_Send")
GUICtrlSetOnEvent($Button2, "_GUI_Exit")
GUISetOnEvent($GUI_EVENT_CLOSE, "_GUI_Exit")

$CurrentKeepOnTop = 0

While 1
	If $CurrentKeepOnTop = 0 AND GUICtrlRead($KeepOnTopCheckbox) = $GUI_CHECKED Then
		WinSetOnTop ($Form1, "", 1)
		$CurrentKeepOnTop = 1
	Elseif $CurrentKeepOnTop = 1 AND GUICtrlRead($KeepOnTopCheckbox) = $GUI_UNCHECKED Then
		WinSetOnTop ($Form1, "", 0)
		$CurrentKeepOnTop = 0
	EndIf

	Sleep(50)
WEnd

;==================================================================================
Func _GUI_Send()
	GUISetState(@SW_HIDE)

	$SendString=GUICtrlRead($SendList)
	If GUICtrlRead($RemoveDashesRadio) = 1 Then
		$SendString = StringReplace($SendString, "-", "")
	ElseIf GUICtrlRead($ConvertRadio) = 1 Then
		$SendString = StringReplace($SendString, "-", "{TAB}")
	EndIf

	Opt("SendKeyDelay",GUICtrlRead($UpDelayInput))
	Opt("SendKeyDownDelay",GUICtrlRead($DownDelayInput))

	Sleep(GUICtrlRead($StartDelayInput) * 1000)

	$RepeatDelay = GUICtrlRead($RepeatDelayInput) * 1000
	For $i=1 To GUICtrlRead($SendCountInput)
		If GUICtrlRead($SendRawCheckbox) = 1 Then
			Send($SendString, 1)
		Else
			Send($SendString)
		EndIf

		Sleep($RepeatDelay)
	Next

	If GUICtrlRead($ExitCheckbox) = 1 Then Exit

	Sleep(500)
	GUISetState(@SW_SHOW)
EndFunc

func _GUI_Exit()
	exit
endfunc
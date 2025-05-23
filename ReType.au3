#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=_Icon.ico
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Fileversion=3.0.0.10
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiComboBoxEx.au3>
#include <GUIListBox.au3>
#include <StaticConstants.au3>
#include <TabConstants.au3>
#include <WindowsConstants.au3>

Opt("TrayIconHide", 1)

Global $TITLE="ReType"
Global $VERSION=FileGetVersion(@AutoItExe)
Global $GUITITLE=$TITLE&" v"&$VERSION

#Region ### START Koda GUI section ###
$Form1 = GUICreate($GUITITLE, 384, 214, -1, -1, BitOR($GUI_SS_DEFAULT_GUI,$WS_SIZEBOX,$WS_THICKFRAME), 0)
$Button1 = GUICtrlCreateButton("Send", 257, 184, 114, 19)
GUICtrlSetResizing(-1, $GUI_DOCKRIGHT+$GUI_DOCKBOTTOM+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$Tab1 = GUICtrlCreateTab(2, 2, 381, 202, BitOR($TCS_BOTTOM,$TCS_BUTTONS))
GUICtrlSetResizing(-1, $GUI_DOCKAUTO+$GUI_DOCKLEFT+$GUI_DOCKRIGHT+$GUI_DOCKTOP+$GUI_DOCKBOTTOM)
$TabSheet1 = GUICtrlCreateTabItem("Input")
$SendList = GUICtrlCreateEdit("", 6, 7, 373, 138)
GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKRIGHT+$GUI_DOCKTOP+$GUI_DOCKBOTTOM)
$History = GUICtrlCreateCombo("", 10, 153, 365, 25, $CBS_DROPDOWNLIST)
GUICtrlSetData(-1, "1|2|3")
GUICtrlSetResizing(-1, $GUI_DOCKBOTTOM+$GUI_DOCKHEIGHT)
$TabSheet2 = GUICtrlCreateTabItem("Settings")
$Group3 = GUICtrlCreateGroup("Dashes", 14, 105, 169, 73)
GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$NoChangeRadio = GUICtrlCreateRadio("No Change", 19, 120, 69, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$ConvertRadio = GUICtrlCreateRadio("Convert Dashes to Tabs", 19, 152, 129, 17)
GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$RemoveDashesRadio = GUICtrlCreateRadio("Remove Dashes", 19, 136, 97, 17)
GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group1 = GUICtrlCreateGroup("Repeat", 192, 117, 181, 61)
GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$SendCountInput = GUICtrlCreateInput("1", 298, 130, 21, 21)
GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$Label3 = GUICtrlCreateLabel("Count", 201, 133, 76, 18)
GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$Label4 = GUICtrlCreateLabel("Delay Between (ms)", 201, 153, 101, 20)
GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$RepeatDelayInput = GUICtrlCreateInput("0", 298, 153, 40, 21)
GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group2 = GUICtrlCreateGroup("Delays", 13, 8, 177, 97)
GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$Label2 = GUICtrlCreateLabel("Start Delay (s)", 18, 27, 72, 18)
GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$StartDelayInput = GUICtrlCreateInput("4", 91, 23, 30, 21)
GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$Label1 = GUICtrlCreateLabel("Up Delay (ms)", 19, 49, 68, 18)
GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$UpdelayInput = GUICtrlCreateInput("5", 92, 46, 30, 21)
GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$Label5 = GUICtrlCreateLabel("Down Delay (ms)", 18, 73, 83, 18)
GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$DownDelayInput = GUICtrlCreateInput("10", 104, 71, 30, 21)
GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group4 = GUICtrlCreateGroup("Misc", 193, 8, 181, 111)
GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$SendRawCheckbox = GUICtrlCreateCheckbox("Raw Mode", 202, 25, 69, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$AttachCheckbox = GUICtrlCreateCheckbox("Attach Mode", 202, 42, 77, 17)
GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$ExitCheckbox = GUICtrlCreateCheckbox("Exit When Done", 202, 60, 97, 17)
GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$HideCheckbox = GUICtrlCreateCheckbox("Hide While Sending", 202, 79, 109, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$KeepOnTopCheckbox = GUICtrlCreateCheckbox("Keep On Top", 202, 97, 81, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlCreateTabItem("")
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###


GUICtrlSetData($History, "")
GUICtrlSetData($DownDelayInput, "20")
GUICtrlSetData($UpdelayInput, "10")

If GUICtrlRead($KeepOnTopCheckbox) = $GUI_CHECKED Then WinSetOnTop($Form1, "", 1)

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			_Exit()

		Case $History
			;_GUICtrlComboBox_GetCurSel ( $hWnd )
			ConsoleWrite("test")
			$Text = ""
			_GUICtrlComboBox_GetLBText($History, _GUICtrlComboBox_GetCurSel($History), $Text)
			GUICtrlSetData($SendList, $Text)

		Case $Button1
			GUICtrlSetState($Button1, $GUI_DISABLE)
			If GUICtrlRead($HideCheckbox) = $GUI_CHECKED Then GUISetState(@SW_HIDE)
			If GUICtrlRead($KeepOnTopCheckbox) = $GUI_CHECKED Then
				WinSetOnTop($Form1, "", 1)
			Else
				WinSetOnTop($Form1, "", 0)
			EndIf

			If GUICtrlRead($AttachCheckbox) = $GUI_CHECKED Then
				Opt("SendAttachMode", 1)
			Else
				Opt("SendAttachMode", 0)
			EndIf

			$SendString = GUICtrlRead($SendList)

			$Text = ""
			_GUICtrlComboBox_GetLBText($History, _GUICtrlComboBox_GetTopIndex($History), $Text)
			If $SendString <> $Text Then
				_GUICtrlComboBox_InsertString($History, $SendString, 0)
				_GUICtrlComboBox_SetCurSel($History, 0)

				If _GUICtrlComboBox_GetCount($History) > 10 Then _GUICtrlComboBox_DeleteString ($History, 10)
			EndIf

			If GUICtrlRead($RemoveDashesRadio) = 1 Then
				$SendString = StringReplace($SendString, "-", "")
			ElseIf GUICtrlRead($ConvertRadio) = 1 Then
				$SendString = StringReplace($SendString, "-", "{TAB}")
			EndIf

			Opt("SendKeyDelay",GUICtrlRead($UpDelayInput))
			Opt("SendKeyDownDelay",GUICtrlRead($DownDelayInput))
			Sleep(GUICtrlRead($StartDelayInput) * 1000)

			$RepeatDelay = GUICtrlRead($RepeatDelayInput) * 1000
			$SendRaw = 0
			If GUICtrlRead($SendRawCheckbox) = $GUI_CHECKED Then $SendRaw = 1

			For $i = 1 To GUICtrlRead($SendCountInput)
				Send($SendString, $SendRaw)
				Sleep($RepeatDelay)
			Next

			If GUICtrlRead($ExitCheckbox) = $GUI_CHECKED Then Exit

			Sleep(500)
			GUISetState(@SW_SHOW)
			GUICtrlSetState($Button1, $GUI_ENABLE)

	EndSwitch

	Sleep(10)
WEnd

;==================================================================================
Func _GUI_Send()

EndFunc

func _Exit()
	exit
endfunc
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=_Icon.ico
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Fileversion=3.0.0.11
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
#include <TrayConstants.au3>
#include <WinAPISys.au3>
#include <WinAPIvkeysConstants.au3>

Opt("TrayIconHide", 0)
Opt("TrayAutoPause", 0)
Opt("TrayMenuMode", 1)
Opt("TrayOnEventMode", 1)

; Setup a tray icon menu
TrayCreateItem("Open")
TrayCreateItem("Exit")
TraySetClick($TRAY_CLICK_PRIMARYDOWN + $TRAY_CLICK_SECONDARYDOWN) ; 1 = show menu on left click


Global $TITLE="ReType"
Global $VERSION=FileGetVersion(@AutoItExe)
Global $GUITITLE=$TITLE&" v"&$VERSION

#Region ### START Koda GUI section ###
$Form1 = GUICreate($GUITITLE, 666, 316, -1, -1, BitOR($GUI_SS_DEFAULT_GUI,$WS_SIZEBOX,$WS_THICKFRAME), 0)
$SendButton = GUICtrlCreateButton("Send", 434, 287, 222, 23)
GUICtrlSetResizing(-1, $GUI_DOCKRIGHT+$GUI_DOCKBOTTOM+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$Group2 = GUICtrlCreateGroup("Delays / Repeat", 405, 1, 254, 97)
GUICtrlSetResizing(-1, $GUI_DOCKRIGHT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$Label3 = GUICtrlCreateLabel("Repeat Count", 414, 47, 70, 18)
GUICtrlSetResizing(-1, $GUI_DOCKRIGHT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$SendCountInput = GUICtrlCreateInput("", 487, 44, 40, 21)
GUICtrlSetResizing(-1, $GUI_DOCKRIGHT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$Label4 = GUICtrlCreateLabel("Repeat Delay", 414, 71, 71, 20)
GUICtrlSetResizing(-1, $GUI_DOCKRIGHT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$RepeatDelayInput = GUICtrlCreateInput("", 487, 68, 40, 21)
GUICtrlSetResizing(-1, $GUI_DOCKRIGHT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$Label1 = GUICtrlCreateLabel("Up Delay (ms)", 541, 23, 68, 18)
GUICtrlSetResizing(-1, $GUI_DOCKRIGHT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$Label5 = GUICtrlCreateLabel("Down Hold (ms)", 531, 47, 80, 18)
GUICtrlSetResizing(-1, $GUI_DOCKRIGHT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$DownDelayInput = GUICtrlCreateInput("", 612, 44, 40, 21)
GUICtrlSetResizing(-1, $GUI_DOCKRIGHT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
GUICtrlSetTip(-1, "Default: 10")
$UpdelayInput = GUICtrlCreateInput("", 612, 20, 40, 21)
GUICtrlSetResizing(-1, $GUI_DOCKRIGHT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
GUICtrlSetTip(-1, "Default: 10")
$StartDelayInput = GUICtrlCreateInput("", 487, 20, 40, 21)
GUICtrlSetResizing(-1, $GUI_DOCKRIGHT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$Label2 = GUICtrlCreateLabel("Start Delay (s)", 414, 23, 72, 18)
GUICtrlSetResizing(-1, $GUI_DOCKRIGHT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group4 = GUICtrlCreateGroup("Misc", 405, 133, 254, 84)
GUICtrlSetResizing(-1, $GUI_DOCKRIGHT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$ExitCheckbox = GUICtrlCreateCheckbox("Send Then Exit", 517, 169, 97, 17)
GUICtrlSetResizing(-1, $GUI_DOCKRIGHT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$HideCheckbox = GUICtrlCreateCheckbox("Hide While Sending", 517, 149, 117, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetResizing(-1, $GUI_DOCKRIGHT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$KeepOnTopCheckbox = GUICtrlCreateCheckbox("Keep On Top", 417, 149, 81, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetResizing(-1, $GUI_DOCKRIGHT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$AttachCheckbox = GUICtrlCreateCheckbox("Attach Mode", 417, 169, 77, 17)
GUICtrlSetResizing(-1, $GUI_DOCKRIGHT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$TrayCheckbox = GUICtrlCreateCheckbox("Start at Logon", 517, 189, 88, 17)
GUICtrlSetResizing(-1, $GUI_DOCKRIGHT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$SendRawCheckbox = GUICtrlCreateCheckbox("Raw Mode", 417, 189, 69, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetResizing(-1, $GUI_DOCKRIGHT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group5 = GUICtrlCreateGroup("Hot Keys", 405, 216, 254, 71)
GUICtrlSetResizing(-1, $GUI_DOCKRIGHT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$HotKeySendInput = GUICtrlCreateInput("", 533, 233, 121, 21)
GUICtrlSetResizing(-1, $GUI_DOCKRIGHT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$HotKeyClipInput = GUICtrlCreateInput("", 533, 258, 121, 21)
GUICtrlSetResizing(-1, $GUI_DOCKRIGHT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$Label6 = GUICtrlCreateLabel("Send (No Delay)", 412, 237, 82, 17)
GUICtrlSetResizing(-1, $GUI_DOCKRIGHT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$Label7 = GUICtrlCreateLabel("Send Clipboard", 417, 262, 76, 17)
GUICtrlSetResizing(-1, $GUI_DOCKRIGHT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$SetSendHotKeyButton = GUICtrlCreateButton("Set", 497, 233, 31, 21)
$SetSendClipHotkeyButton = GUICtrlCreateButton("Set", 497, 258, 31, 21)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group3 = GUICtrlCreateGroup("Dashes", 405, 98, 254, 35)
GUICtrlSetResizing(-1, $GUI_DOCKRIGHT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$NoChangeRadio = GUICtrlCreateRadio("No Change", 417, 112, 72, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetResizing(-1, $GUI_DOCKRIGHT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$ConvertRadio = GUICtrlCreateRadio("Convert to Tabs", 561, 112, 95, 17)
GUICtrlSetResizing(-1, $GUI_DOCKRIGHT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$RemoveDashesRadio = GUICtrlCreateRadio("Remove", 497, 112, 60, 17)
GUICtrlSetResizing(-1, $GUI_DOCKRIGHT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$SendEdit = GUICtrlCreateEdit("", 2, 2, 399, 310, -1, 0)
GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKRIGHT+$GUI_DOCKTOP+$GUI_DOCKBOTTOM)
$Button2 = GUICtrlCreateButton("...", 404, 287, 26, 23)
GUICtrlSetResizing(-1, $GUI_DOCKRIGHT+$GUI_DOCKBOTTOM+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

GUICtrlSetData($DownDelayInput, "20")
GUICtrlSetData($UpdelayInput, "10")
GUICtrlSetData($StartDelayInput, "2")
GUICtrlSetData($SendCountInput, "1")
GUICtrlSetData($RepeatDelayInput, "500")
GUICtrlSetData($HotKeySendInput, "")
GUICtrlSetData($HotKeyClipInput, "")


$OnTop = False


While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			_Exit()

		;Case $HistoryCombo
			;_GUICtrlComboBox_GetCurSel ( $hWnd )
			;ConsoleWrite("test")
			;$Text = ""
			;_GUICtrlComboBox_GetLBText($HistoryCombo, _GUICtrlComboBox_GetCurSel($HistoryCombo), $Text)
			;GUICtrlSetData($SendEdit, $Text)

		Case $SetSendHotKeyButton
			Local $sCaptured = _CaptureHotkey($Form1, $SetSendHotKeyButton)
			If $sCaptured <> "" Then GUICtrlSetData($HotKeySendInput, _HotkeyToFriendly($sCaptured))

		Case $SetSendClipHotkeyButton
			Local $sCaptured = _CaptureHotkey($Form1, $SetSendClipHotkeyButton)
			If $sCaptured <> "" Then GUICtrlSetData($HotKeyClipInput, _HotkeyToFriendly($sCaptured))

		Case $SendButton
			GUICtrlSetState($SendButton, $GUI_DISABLE)
			GUICtrlSetData($SendButton, "Sending...")

			; Hide Window
			If GUICtrlRead($HideCheckbox) = $GUI_CHECKED Then GUISetState(@SW_HIDE)

			; Get text from edit box
			$SendString = GUICtrlRead($SendEdit)

			; Attach Mode
			If GUICtrlRead($AttachCheckbox) = $GUI_CHECKED Then
				Opt("SendAttachMode", 1)
			Else
				Opt("SendAttachMode", 0)
			EndIf

			; History Combo Box
			;$Text = ""
			;_GUICtrlComboBox_GetLBText($HistoryCombo, _GUICtrlComboBox_GetTopIndex($HistoryCombo), $Text)
			;If $SendString <> $Text Then
			;	_GUICtrlComboBox_InsertString($HistoryCombo, $SendString, 0)
			;	_GUICtrlComboBox_SetCurSel($HistoryCombo, 0)
			;
			;	If _GUICtrlComboBox_GetCount($HistoryCombo) > 10 Then _GUICtrlComboBox_DeleteString ($HistoryCombo, 10)
			;EndIf

			; Dashes
			If GUICtrlRead($RemoveDashesRadio) = $GUI_CHECKED Then
				$SendString = StringReplace($SendString, "-", "")
			ElseIf GUICtrlRead($ConvertRadio) = $GUI_CHECKED Then
				$SendString = StringReplace($SendString, "-", "{TAB}")
			EndIf

			; Delays
			Opt("SendKeyDelay",GUICtrlRead($UpDelayInput))
			Opt("SendKeyDownDelay",GUICtrlRead($DownDelayInput))
			Sleep(GUICtrlRead($StartDelayInput) * 1000)

			; Repeat
			$RepeatDelay = GUICtrlRead($RepeatDelayInput) * 1000
			$RepeatCount = GUICtrlRead($SendCountInput)

			; Raw Mode
			If GUICtrlRead($SendRawCheckbox) = $GUI_CHECKED Then
				$SendRaw = 1
			Else
				$SendRaw = 0
			EndIf

			; Send the String
			For $i = 1 To $RepeatCount
				Send($SendString, $SendRaw)
				Sleep($RepeatDelay)
			Next

			; Exit When Done
			If GUICtrlRead($ExitCheckbox) = $GUI_CHECKED Then Exit

			; Restore Window
			Sleep(100)
			GUISetState(@SW_SHOW)
			GUICtrlSetState($SendButton, $GUI_ENABLE)
			GUICtrlSetData($SendButton, "Send")
	EndSwitch

	$OnTop_New = (GUICtrlRead($KeepOnTopCheckbox) = $GUI_CHECKED)
	If $OnTop_New <> $OnTop Then
		$OnTop = $OnTop_New
		If $OnTop Then
			WinSetOnTop($Form1, "", 1)
		Else
			WinSetOnTop($Form1, "", 0)
		EndIf
	EndIf
	Sleep(10)
WEnd

;==================================================================================
Func _GUI_Send()

EndFunc

func _Exit()
	exit
endfunc

; Captures a hotkey combination when a Set button is pressed
Func _CaptureHotkey($hWnd, $idButton)
	Local $sOriginalText = GUICtrlRead($idButton)
	GUICtrlSetData($idButton, "...")
	GUICtrlSetState($idButton, $GUI_DISABLE)

	; Wait for all keys to be released first
	Sleep(200)
	While _AnyKeyPressed()
		Sleep(50)
	WEnd

	; Wait for a key press
	Local $tKeys, $bCtrl, $bAlt, $bShift, $bWin, $iMainKey
	Local $iTimeout = 5000
	Local $iStart = TimerInit()

	While TimerDiff($iStart) < $iTimeout
		$tKeys = _WinAPI_GetKeyboardState()
		If @error Then ExitLoop

		; Check modifier states
		$bCtrl = BitAND(DllStructGetData($tKeys, 1, 1 + $VK_CONTROL), 128) <> 0
		$bAlt = BitAND(DllStructGetData($tKeys, 1, 1 + $VK_MENU), 128) <> 0
		$bShift = BitAND(DllStructGetData($tKeys, 1, 1 + $VK_SHIFT), 128) <> 0
		$bWin = BitAND(DllStructGetData($tKeys, 1, 1 + $VK_LWIN), 128) <> 0 Or _
				BitAND(DllStructGetData($tKeys, 1, 1 + $VK_RWIN), 128) <> 0

		; Find main key (non-modifier)
		$iMainKey = _GetPressedMainKey($tKeys)

		If $iMainKey > 0 Then
			; Build hotkey string
			Local $sHotkey = ""
			If $bWin Then $sHotkey &= "#"
			If $bCtrl Then $sHotkey &= "^"
			If $bAlt Then $sHotkey &= "!"
			If $bShift Then $sHotkey &= "+"
			$sHotkey &= _VKToKeyName($iMainKey)

			; Wait for key release
			While _AnyKeyPressed()
				Sleep(50)
			WEnd

			GUICtrlSetData($idButton, $sOriginalText)
			GUICtrlSetState($idButton, $GUI_ENABLE)
			Return $sHotkey
		EndIf

		Sleep(20)
	WEnd

	; Timeout or cancelled
	GUICtrlSetData($idButton, $sOriginalText)
	GUICtrlSetState($idButton, $GUI_ENABLE)
	Return ""
EndFunc

; Check if any key is currently pressed
Func _AnyKeyPressed()
	Local $tKeys = _WinAPI_GetKeyboardState()
	If @error Then Return False
	For $i = 1 To 255
		If BitAND(DllStructGetData($tKeys, 1, $i), 128) Then Return True
	Next
	Return False
EndFunc

; Get the main (non-modifier) key that is pressed
Func _GetPressedMainKey($tKeys)
	Local $aModifiers[8] = [$VK_CONTROL, $VK_MENU, $VK_SHIFT, $VK_LCONTROL, $VK_RCONTROL, _
							$VK_LMENU, $VK_RMENU, $VK_LSHIFT]
	Local $aModifiers2[4] = [$VK_RSHIFT, $VK_LWIN, $VK_RWIN, $VK_CAPITAL]

	For $i = 1 To 254
		If BitAND(DllStructGetData($tKeys, 1, $i + 1), 128) Then
			; Skip modifiers
			Local $bIsModifier = False
			For $j = 0 To 7
				If $i = $aModifiers[$j] Then
					$bIsModifier = True
					ExitLoop
				EndIf
			Next
			If Not $bIsModifier Then
				For $j = 0 To 3
					If $i = $aModifiers2[$j] Then
						$bIsModifier = True
						ExitLoop
					EndIf
				Next
			EndIf
			If Not $bIsModifier Then Return $i
		EndIf
	Next
	Return 0
EndFunc

; Convert virtual key code to key name for hotkey string
Func _VKToKeyName($iVK)
	Switch $iVK
		Case $VK_A To $VK_Z
			Return Chr($iVK)
		Case $VK_0 To $VK_9
			Return Chr($iVK)
		Case $VK_F1 To $VK_F12
			Return "{F" & ($iVK - $VK_F1 + 1) & "}"
		Case $VK_NUMPAD0 To $VK_NUMPAD9
			Return "{NUMPAD" & ($iVK - $VK_NUMPAD0) & "}"
		Case $VK_SPACE
			Return "{SPACE}"
		Case $VK_RETURN
			Return "{ENTER}"
		Case $VK_TAB
			Return "{TAB}"
		Case $VK_ESCAPE
			Return "{ESC}"
		Case $VK_BACK
			Return "{BACKSPACE}"
		Case $VK_DELETE
			Return "{DEL}"
		Case $VK_INSERT
			Return "{INS}"
		Case $VK_HOME
			Return "{HOME}"
		Case $VK_END
			Return "{END}"
		Case $VK_PRIOR
			Return "{PGUP}"
		Case $VK_NEXT
			Return "{PGDN}"
		Case $VK_UP
			Return "{UP}"
		Case $VK_DOWN
			Return "{DOWN}"
		Case $VK_LEFT
			Return "{LEFT}"
		Case $VK_RIGHT
			Return "{RIGHT}"
		Case $VK_OEM_1
			Return ";"
		Case $VK_OEM_PLUS
			Return "="
		Case $VK_OEM_COMMA
			Return ","
		Case $VK_OEM_MINUS
			Return "-"
		Case $VK_OEM_PERIOD
			Return "."
		Case $VK_OEM_2
			Return "/"
		Case $VK_OEM_3
			Return "``"
		Case $VK_OEM_4
			Return "["
		Case $VK_OEM_5
			Return "\"
		Case $VK_OEM_6
			Return "]"
		Case $VK_OEM_7
			Return "'"
		Case $VK_PAUSE
			Return "{PAUSE}"
		Case $VK_PRINT
			Return "{PRINTSCREEN}"
		Case $VK_SCROLL
			Return "{SCROLLLOCK}"
		Case Else
			Return SetError(1, 0, "")
			;Return "{VK " & Hex($iVK, 2) & "}"
	EndSwitch
EndFunc

; Convert AutoIt hotkey format to friendly format (e.g., "^!A" -> "Ctrl+Alt+A")
Func _HotkeyToFriendly($sHotkey)
	If $sHotkey = "" Then Return ""

	Local $sFriendly = ""
	Local $sKey = $sHotkey

	; Extract modifiers from the beginning
	While StringLen($sKey) > 0
		Local $sChar = StringLeft($sKey, 1)
		Switch $sChar
			Case "#"
				$sFriendly &= "Win+"
				$sKey = StringTrimLeft($sKey, 1)
			Case "^"
				$sFriendly &= "Ctrl+"
				$sKey = StringTrimLeft($sKey, 1)
			Case "!"
				$sFriendly &= "Alt+"
				$sKey = StringTrimLeft($sKey, 1)
			Case "+"
				$sFriendly &= "Shift+"
				$sKey = StringTrimLeft($sKey, 1)
			Case Else
				ExitLoop
		EndSwitch
	WEnd

	; Convert the key part
	If StringLeft($sKey, 1) = "{" And StringRight($sKey, 1) = "}" Then
		; It's a special key like {F1}, {SPACE}, etc.
		Local $sInner = StringMid($sKey, 2, StringLen($sKey) - 2)
		$sFriendly &= $sInner
	Else
		$sFriendly &= $sKey
	EndIf

	Return $sFriendly
EndFunc

; Convert friendly format to AutoIt hotkey format (e.g., "Ctrl+Alt+A" -> "^!A")
Func _FriendlyToHotkey($sFriendly)
	If $sFriendly = "" Then Return ""

	Local $sHotkey = ""
	Local $aParts = StringSplit($sFriendly, "+")

	For $i = 1 To $aParts[0]
		Local $sPart = $aParts[$i]
		Switch StringLower($sPart)
			Case "win"
				$sHotkey &= "#"
			Case "ctrl", "control"
				$sHotkey &= "^"
			Case "alt"
				$sHotkey &= "!"
			Case "shift"
				$sHotkey &= "+"
			Case Else
				; This is the main key
				If StringLen($sPart) = 1 Then
					$sHotkey &= $sPart
				Else
					; Special key - wrap in braces
					$sHotkey &= "{" & $sPart & "}"
				EndIf
		EndSwitch
	Next

	Return $sHotkey
EndFunc
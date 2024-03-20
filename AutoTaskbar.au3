#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Change2CUI=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <Array.au3>
#include <Process.au3>
#include <WinAPIProc.au3>
#include <WinAPIDlg.au3>
#include <WinAPISys.au3>
#include <WinAPISysWin.au3>
#include <APIDlgConstants.au3>
#include <GDIPlus.au3>
#include <GuiButton.au3>
#include <GuiImageList.au3>
#include <Constants.au3>

#include "CommonFunctions.au3"
#RequireAdmin
_Log("Start" & @CRLF)
OnAutoItExitRegister("_Exit")


; == Button and taskbar sizing/spacing values
$TaskBarHeight = 30
$TaskBarWidth = @DesktopWidth
$TaskBarLeft = 0
$TaskBarTop = @DesktopHeight - $TaskBarHeight
$ButtonLeft = 40
$ButtonHSpace = 8
$ButtonWidth = 95
$ButtonVSpace = 2
$ButtonHeight = $TaskBarHeight - ($ButtonVSpace * 2)


; == Setup GUI
$TaskBarForm = GUICreate("", $TaskBarWidth, $TaskBarHeight, 0, $TaskBarTop, $WS_POPUP, BitOR($WS_EX_TOOLWINDOW, $WS_EX_TOPMOST))
$PowerButton = GUICtrlCreateButton("", $ButtonHSpace, $ButtonVSpace, $ButtonHeight, $ButtonHeight, BitOR($BS_CENTER, $BS_VCENTER))
_GUICtrlSetImage(-1, "C:\Windows\System32\shell32.dll", -240, 16)
GUISetState(@SW_SHOW)


; == Get window information and make buttons
$aWindows = _GetVisibleWindows(False)
_Log("_GetVisibleWindows Time: " & @extended)

$ButtonPathIndex = 6
$ButtonStyleIndex = 9
$ButtonExStyleIndex = 11
$ButtonIDIndex = 15

_ArrayColInsert($aWindows, $ButtonIDIndex)
$aWindows[0][$ButtonIDIndex] = "ButtonID"
$i = 0
While 1
	$i += 1
	If $i > $aWindows[0][0] Then ExitLoop
	If $aWindows[$i][1] = $TaskBarForm Or _
	  BitAND($aWindows[$i][$ButtonStyleIndex], $WS_POPUP) Or _
	  BitAND($aWindows[$i][$ButtonExStyleIndex], $WS_EX_TOOLWINDOW) Then
		_ArrayDelete ($aWindows, $i)
		$aWindows[0][0] -= 1
		$i -= 1
		ContinueLoop
	EndIf

	$Label = $aWindows[$i][0]
	If StringLen($Label) > 13 Then $Label = StringLeft($Label, 11) & "..."
	;_Log("Label: " & $Label)

	;$aWindows[$i][$ButtonIDIndex] = GUICtrlCreateButton(" " & $Label, $ButtonLeft + ($ButtonHSpace / 2), $ButtonVSpace, $ButtonWidth, $ButtonHeight, $BS_LEFT)
	$aWindows[$i][$ButtonIDIndex] = GUICtrlCreateRadio(" " & $Label, $ButtonLeft + ($ButtonHSpace / 2), $ButtonVSpace, $ButtonWidth, $ButtonHeight, BitOR($GUI_SS_DEFAULT_RADIO,$BS_LEFT,$BS_PUSHLIKE))
	_GUICtrlSetImage(-1, $aWindows[$i][$ButtonPathIndex], 0, 16)
	;_Log("  _GUICtrlSetImage: " & @error & " " & @extended)

	$ButtonLeft += ($ButtonHSpace / 2) + $ButtonWidth
Wend
_ArrayDisplay($aWindows)


Local $hLastActiveWindow
Local $hLastActiveButton
Local $hActiveNowWindow
Local $LastActiveWindowIndex
Local $hHighlightedButton
Local $hGDITaskBarForm

While 1
	$hTemp = WinGetHandle("[active]")
	If $hTemp <> $TaskBarForm Then $hActiveNowWindow = $hTemp

	$nMsg = GUIGetMsg()
	If $nMsg > 0 Then _Log("GUI Event: " & $nMsg)
	Switch $nMsg
		Case $GUI_EVENT_CLOSE, $PowerButton
			Exit

		Case Else
			If $nMsg > 0 Then
				$Index = _ArraySearch($aWindows, $nMsg, 0, 0, 0, 0, 1, 15)
				If Not @error Then
					_Log("  Button: " & GUICtrlRead($nMsg))
					$hWindow = $aWindows[$Index][1]
					If $hActiveNowWindow = $hWindow Then
						_Log("  Minimize: " & WinSetState($hWindow, "", @SW_MINIMIZE))
						;WinSetState($hWindow, "", @SW_HIDE)
					Else
						_Log("  WinActivate: " & WinActivate($hWindow))
						;WinSetState($hWindow, "", @SW_RESTORE)

					EndIf
				Else
					_Log(" _ArraySearch Error: " & @error & " " & @extended & " " & @ScriptLineNumber)
				EndIf



			EndIf

	EndSwitch


	If $hActiveNowWindow <> $hLastActiveWindow Then
		_Log("Focus change")

		; Clear button highlight
		;_GUICtrlButton_SetState($aWindows[$LastActiveWindowIndex][$ButtonIDIndex], False)

		$ActiveWindowIndex = _ArraySearch($aWindows, $hActiveNowWindow, 0, 0, 0, 0, 1, 1)
		If Not @error Then
			_Log("Active Window: " & $aWindows[$ActiveWindowIndex][0])

			; Highlight button
 			;$ButtonPos = ControlGetPos($TaskBarForm, "", $aWindows[$ActiveWindowIndex][$ButtonIDIndex]) ; Left Top Width Height
			If Not @error Then
 				;$Label = GUICtrlRead($aWindows[$ActiveWindowIndex][$ButtonIDIndex])
				;GUICtrlDelete($aWindows[$ActiveWindowIndex][$ButtonIDIndex])
				;$aWindows[$ActiveWindowIndex][$ButtonIDIndex] = GUICtrlCreateButton($Label, $ButtonPos[0], $ButtonPos[1], $ButtonPos[2], $ButtonPos[3], BitOR($BS_LEFT, $WS_BORDER))
				;_GUICtrlSetImage(-1, $aWindows[$ActiveWindowIndex][$ButtonPathIndex], 0, 16)
			EndIf


			$LastActiveWindowIndex = $ActiveWindowIndex
		EndIf

		$hLastActiveWindow = $hActiveNowWindow
	EndIf

	Sleep(1)
WEnd



; =========================================================================
; =========================================================================
Func _Exit()
	_Log("End" & @CRLF)
EndFunc   ;==>_Exit

Func _GUICtrlSetImage($hButton, $sFileIco, $iIndIco = 0, $iSize = 16)
	Switch $iSize
		Case 16, 24, 32
			$iSize = $iSize
		Case Else
			$iSize = $iSize
	EndSwitch
	Local $hImage = _GUIImageList_Create($iSize, $iSize, 5, 3, 6)
	If @error Then Return SetError(1, @error, $hImage)
	_GUIImageList_AddIcon($hImage, $sFileIco, $iIndIco)
	If @error Then Return SetError(2, @error, $hImage)
	_GUICtrlButton_SetImageList($hButton, $hImage, 0)
	If @error Then Return SetError(3, @error, $hImage)
	Return $hImage
EndFunc   ;==>_GUICtrlSetImage

Global Const $SPI_SETWORKAREA               = 0x002F
Global Const $SPI_GETWORKAREA               = 0x0030
Global Const $SPIF_UPDATEINIFILE             = 0x0001
Global Const $SPIF_SENDWININICHANGE       = 0x0002
Global Const $SPIF_SENDCHANGE               = $SPIF_SENDWININICHANGE

Func _WorkingArea($iLeft = Default, $iTop = Default, $iWidth = Default, $iHeight = Default)
    Local Static $tWorkArea = 0
    If IsDllStruct($tWorkArea) Then
        _WinAPI_SystemParametersInfo($SPI_SETWORKAREA, 0, DllStructGetPtr($tWorkArea), $SPIF_SENDCHANGE)
        $tWorkArea = 0
    Else
        $tWorkArea = DllStructCreate($tagRECT)
        _WinAPI_SystemParametersInfo($SPI_GETWORKAREA, 0, DllStructGetPtr($tWorkArea))

        Local $tCurrentArea = DllStructCreate($tagRECT)
        Local $aArray[4] = [$iLeft, $iTop, $iWidth, $iHeight]
        For $i = 0 To 3
            If $aArray[$i] = Default Or $aArray[$i] < 0 Then
                $aArray[$i] = DllStructGetData($tWorkArea, $i + 1)
            EndIf
            DllStructSetData($tCurrentArea, $i + 1, $aArray[$i])
            $aArray[$i] = DllStructGetData($tWorkArea, $i + 1)
        Next
        _WinAPI_SystemParametersInfo($SPI_SETWORKAREA, 0, DllStructGetPtr($tCurrentArea), $SPIF_SENDCHANGE)
        $aArray[2] -= $aArray[0]
        $aArray[3] -= $aArray[1]
        Local $aReturn[4] = [$aArray[2], $aArray[3], $aArray[0], $aArray[1]]
        Return $aReturn
    EndIf
EndFunc   ;==>_WorkingArea

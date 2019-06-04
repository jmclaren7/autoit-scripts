#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\..\Google Drive\Autoit\_Icon.ico
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Res_Description=MeasureRemoteLatency
#AutoIt3Wrapper_Res_Fileversion=1.0.0.20
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_Language=1033
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include "CommonFunctions.au3"
#include <Array.au3>

$Version = FileGetVersion(@ScriptFullPath)
Global $Title = "Remote Latency Test v"&$Version

$Form1 = GUICreate($Title, 400, 305, 312, 269)
$Label1 = GUICtrlCreateLabel("", 0, 0, 200, 280, $WS_BORDER)
$Label2 = GUICtrlCreateLabel("", 200, 0, 200, 305, $WS_BORDER)
GUICtrlSetBkColor(-1, 0xFFFFFF)
$TestButton = GUICtrlCreateButton("Test", 0, 280, 200, 25)
GUISetState(@SW_SHOW)

Global $aLog[21]

;GUISetBkColor(0x00FF00, $Form1)
GUICtrlSetBkColor($Label2, 0x00FF00)
$TestAreaColor = 1

_UpdateLog("Start")

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $TestButton
			GUICtrlSetData ( $TestButton, "Move Mouse To Remote (4s)")
			Sleep(4*1000)
			$Mouse = MouseGetPos()
			$Color = Hex(PixelGetColor ($Mouse[0]-5, $Mouse[1]-5), 6)
			_UpdateLog($Color)

			If $Color = "0000FF" OR $Color = "00FF00" Then
				$LastColor = $Color
				GUICtrlSetData ( $TestButton, "Wait (1s)")
				Sleep(1*1000)
				GUICtrlSetData ( $TestButton, "Testing (6s)")

				$Average = 0
				$Timer = TimerInit ( )
				While 1
					MouseDown("right")
					Sleep(60)
					MouseUp("right")
					$ClickTimer = TimerInit ( )

					While 1 ;wait for color change
						$Mouse = MouseGetPos()
						$Color = Hex(PixelGetColor ($Mouse[0]-5, $Mouse[1]-5), 6)
						If $Color <> $LastColor Then
							$Latency = TimerDiff($ClickTimer)
							$Latency = Round($Latency)
							_UpdateLog($Latency)

							$LastColor = $Color
							If $Average = 0 Then
								$Average = $Latency
							Else
								$Average = Round(($Average + $Latency) / 2)
							EndIf

							sleep(200)
							ExitLoop

						Elseif TimerDiff($ClickTimer) > 400 Then
							_UpdateLog("Timeout")
							ExitLoop
						Endif

					WEnd

					If TimerDiff($Timer) > 6000 Then
						_UpdateLog("Average=" & $Average)
						ExitLoop
					EndIf

				Wend
			Else
				_UpdateLog("Test area not found")
			EndIf

			GUICtrlSetData ( $TestButton, "Test")

		Case $GUI_EVENT_SECONDARYUP
			If $TestAreaColor = 1 Then
				GUICtrlSetBkColor($Label2, 0x0000FF)
				$TestAreaColor = 2
			Else
				GUICtrlSetBkColor($Label2, 0x00FF00)
				$TestAreaColor = 1
			EndIf

	EndSwitch
WEnd

Func _UpdateLog($Line)
	_ConsoleWrite($Line)
	_ArrayPush ($aLog, $Line)
	$String = _ArrayToString($aLog, @CRLF)
	$String = StringReplace($String, @CRLF&@CRLF, "")
	If StringLeft($String, 2) = @CRLF Then $String = StringTrimLeft($String, 2)
	GUICtrlSetData ($Label1, $String)
EndFunc
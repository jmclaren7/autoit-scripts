#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=_Icon.ico
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Res_Description=MeasureRemoteLatency
#AutoIt3Wrapper_Res_Fileversion=1.0.0.32
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_Language=1033
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include "CommonFunctions.au3"
#include <Array.au3>
#Include <IE.au3>


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
			GUICtrlSetBkColor($Label2, 0x000000)
			GUICtrlSetData ( $TestButton, "Move Mouse To Remote (4s)")
			Sleep(4*1000)

			$aLatency = 0


			$Mouse = MouseGetPos()
			$Color = Hex(PixelGetColor ($Mouse[0]-5, $Mouse[1]-5), 6)
			_UpdateLog($Color)

			$ColorR = Dec(StringMid($Color, 1, 2))
			$ColorG = Dec(StringMid($Color, 3, 2))
			$ColorB = Dec(StringMid($Color, 5, 2))

			If $ColorR < 5 AND ($ColorG > 240 OR $ColorB > 240) Then
				$LastColor = $Color
				GUICtrlSetData ( $TestButton, "Wait (1s)")
				Sleep(1*1000)
				GUICtrlSetData ( $TestButton, "Testing (6s)")

				Local $aLatency[0]
				$Timer = TimerInit ( )
				While 1
					MouseDown("right")
					Sleep(80)
					MouseUp("right")
					$ClickTimer = TimerInit ( )

					While 1 ;wait for color change
						$Mouse = MouseGetPos()
						$Color = Hex(PixelGetColor ($Mouse[0]-5, $Mouse[1]-5), 6)
						If $Color <> $LastColor Then
							$ThisLatency = TimerDiff($ClickTimer)
							$ThisLatency = Round($ThisLatency)
							_UpdateLog($ThisLatency)

							$LastColor = $Color
							_ArrayAdd($aLatency, $ThisLatency)

							sleep(200)
							ExitLoop

						Elseif TimerDiff($ClickTimer) > 1500 Then
							_UpdateLog("Timeout")
							ExitLoop

						Endif

					WEnd

					If TimerDiff($Timer) > 6000 Then
						_UpdateLog("Done")
						ExitLoop
					EndIf

				Wend
			Else
				_UpdateLog("Test area not found")
				_UpdateLog($ColorR&", "&$ColorB&", "&$ColorG)
			EndIf

			$Latency = 0
			For $i=0 to UBound($aLatency)-1
				$Latency = $Latency + $aLatency[$i]
			Next
			If $Latency <> 0 Then $Latency = Round($Latency / UBound($aLatency))

			_UpdateLog("Average: " & $Latency & "ms")

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
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=icons\_Icon.ico
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Description=StayAwake!
#AutoIt3Wrapper_Res_Fileversion=1.0.0.11
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_Language=1033
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

Opt("TrayMenuMode", 1+2)
Opt("TrayOnEventMode", 1)

$tExit = TrayCreateItem("Exit")
TrayItemSetOnEvent(-1, "_Exit")
OnAutoItExitRegister ("_Exit")

Local $MoveSize[2] = [-2,2]

While 1
	$Pos1 = MouseGetPos ()
	_Sleep(20*1000)
	$Pos2 = MouseGetPos ()

	If Abs($Pos1[0] - $Pos2[0]) <= 2 And Abs($Pos1[1] - $Pos2[1]) <= 2 Then
		$randomX = $MoveSize[Random (0, 1, 1)]
		$randomY = $MoveSize[Random (0, 1, 1)]
		MouseMove($Pos2[0] + $randomX, $Pos2[1] + $randomY)

	Endif

Wend

Func _Sleep($iTime)
	$iTime = Round($iTime / 10)
	For $i = 1 To $iTime
		Sleep(10)
	Next
EndFunc

Func _Exit()
	Exit
Endfunc
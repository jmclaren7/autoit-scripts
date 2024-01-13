#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=_Icon.ico
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Description=AuthyHelper
#AutoIt3Wrapper_Res_Fileversion=1.0.0.9
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_SaveSource=y
#AutoIt3Wrapper_Res_Language=1033
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

; Authy does not have that ability to copy the one time code using just the keyboard
; This script helps add a ctrl+c hotkey that will copy the one time token currently on screen

Opt("TrayAutoPause", 0)
Opt("MouseCoordMode", 2)

TraySetIcon ("%USERPROFILE%\AppData\Local\authy\Authy Desktop.exe")

$WinTitle = "Twilio Authy"
$HotKetSet = False

While 1
	If WinActive($WinTitle) And Not $HotKetSet Then
		_ConsoleWrite("Set")
		HotKeySet("^c","AuthClickCopy")
		$HotKetSet = True

	Elseif Not WinActive($WinTitle) And $HotKetSet Then
		_ConsoleWrite("Unset")
		HotKeySet("^c")
		$HotKetSet = False

	EndIf

	Sleep(100)
Wend

Func AuthClickCopy()
	_ConsoleWrite("AuthClickCopy")
	ControlClick($WinTitle, "", "", "Left", 1, 350, 510)
Endfunc

Func _ConsoleWrite($Text)
	ConsoleWrite(@CRLF&$Text)

EndFunc








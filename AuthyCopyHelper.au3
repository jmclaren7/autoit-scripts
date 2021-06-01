#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=_Icon.ico
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Description=AuthyHelper
#AutoIt3Wrapper_Res_Fileversion=1.0.0.6
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

While 1
	If WinActive($WinTitle) Then
		_ConsoleWrite("Set")
		HotKeySet("^c","AuthCopy")
		While WinActive($WinTitle)

			Sleep(100)
		Wend
		_ConsoleWrite("Forget")
		HotKeySet("^c")
	EndIf

	Sleep(300)
Wend

Func AuthCopy()
	_ConsoleWrite("AuthCopy")
	AuthClickCopy()
Endfunc

Func AuthDelayCopy()
	_ConsoleWrite("AuthDelayCopy")
	HotKeySet("{LCTRL}")
	Send("{LCTRL}")
	HotKeySet("{LCTRL}","AuthDelayCopy")
	Sleep(100)
	AuthClickCopy()
Endfunc

Func AuthClickCopy()
	_ConsoleWrite("AuthClickCopy")
	ControlClick($WinTitle, "", "", "Left", 1, 340, 480)
Endfunc

Func _ConsoleWrite($Text)
	ConsoleWrite(@CRLF&$Text)

EndFunc








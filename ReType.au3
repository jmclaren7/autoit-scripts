#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Res_Fileversion=2.1.0.5
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>

Opt("TrayIconHide", 1)
Opt("GUIOnEventMode", 1)

Global $VERSION=FileGetVersion(@AutoItExe)

#Region ### START Koda GUI section ###
$Form1 = GUICreate("ReType: "&$VERSION, 274, 141)
$Group1 = GUICtrlCreateGroup("Enter Text", 4, 0, 265, 45)
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
$Input1 = GUICtrlCreateInput("", 8, 16, 257, 22)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group2 = GUICtrlCreateGroup("Options", 4, 44, 265, 73)
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
$Input2 = GUICtrlCreateInput("5", 60, 52, 21, 19)
$Label1 = GUICtrlCreateLabel("Speed (ms)", 8, 56, 52, 18)
GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
$Label2 = GUICtrlCreateLabel("Delay (sec)", 8, 76, 52, 18)
GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
$Input3 = GUICtrlCreateInput("4", 60, 72, 21, 19)
$Label3 = GUICtrlCreateLabel("Repeat", 89, 54, 36, 18)
GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
$Label4 = GUICtrlCreateLabel("Repeat"&@LF&"Delay (sec)", 88, 72, 45, 28)
GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
$Input4 = GUICtrlCreateInput("1", 134, 52, 21, 19)
$Input5 = GUICtrlCreateInput("0", 134, 72, 21, 19)
$Checkbox2 = GUICtrlCreateCheckbox("Send Raw Mode", 168, 76, 97, 17)
GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
$Radio1 = GUICtrlCreateRadio("Do Nothing", 8, 96, 69, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
$Radio2 = GUICtrlCreateRadio("Remove Dashes", 88, 96, 97, 17)
GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
$Radio3 = GUICtrlCreateRadio("Dash 2 Tab", 192, 96, 73, 17)
GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
$Input6 = GUICtrlCreateInput("5", 229, 52, 21, 19)
$Label5 = GUICtrlCreateLabel("Down Delay", 168, 52, 59, 18)
GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Button1 = GUICtrlCreateButton("Send", 112, 120, 75, 17, 0)
$Button2 = GUICtrlCreateButton("Cancel", 192, 120, 75, 17, 0)
$Checkbox1 = GUICtrlCreateCheckbox("Exit When Done", 4, 120, 97, 17)
#GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###


GUICtrlSetOnEvent($Button1, "gui_send")
GUICtrlSetOnEvent($Button2, "user_exit")
GUISetOnEvent($GUI_EVENT_CLOSE, "user_exit")

While 1
	sleep(10)

WEnd

;==================================================================================
Func gui_send()
	GUISetState(@SW_HIDE)

	$sendfinal=GUICtrlRead($Input1)
	If GUICtrlRead($Radio2) = 1 Then
		$sendfinal = StringReplace($sendfinal, "-", "")
	ElseIf GUICtrlRead($Radio3) = 1 Then
		$sendfinal = StringReplace($sendfinal, "-", "{TAB}")
	EndIf

	Opt("SendKeyDelay",GUICtrlRead($Input2))
	Sleep(GUICtrlRead($Input3) * 1000)
	$repdelay = GUICtrlRead($Input5) * 1000

	Opt("SendKeyDownDelay",10)

	For $i=1 To GUICtrlRead($Input4)
		Sleep($repdelay)
		If GUICtrlRead($Checkbox2) = 1 Then
			Send($sendfinal,1)
		Else
			Send($sendfinal)
		EndIf
	Next

	If GUICtrlRead($Checkbox1) = 1 Then Exit
	Sleep(500)
	GUISetState(@SW_SHOW)
EndFunc

func user_exit()
	exit
endfunc
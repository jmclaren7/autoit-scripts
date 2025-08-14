#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=_Icon.ico
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Res_Fileversion=0.0.0.8
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_Language=1033
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <AutoItConstants.au3>
#include <TrayConstants.au3>

Opt("TrayOnEventMode", 1)
Opt("TrayMenuMode", 3)
TraySetToolTip("Clicks accept on a remote desktop shadow connection request.")

$exitItem = TrayCreateItem("Exit")
TrayItemSetOnEvent($exitItem, "OnExit")


While True
	$hWin = WinGetHandle("Remote Control Request")
    If Not @error Then
        ControlClick($hWin, "", "[CLASS:Button; INSTANCE:1]")
    EndIf


    Sleep(100)
WEnd

; Exit function
Func OnExit()
    Exit
EndFunc
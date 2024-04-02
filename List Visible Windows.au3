#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=_Icon.ico
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Fileversion=1.0.0.7
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_Language=1033
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;#RequireAdmin
#include <Array.au3>
#include <CommonFunctions.au3>

;Get a list of visable windows with lots of information.
$aWindows = _GetVisibleWindows(True)
$Time = @extended
_ArrayDisplay($aWindows, "_GetVisibleWindows - Admin: " & ((IsAdmin()) ? "Yes" : "No") & "  Time: " & $Time & "ms")
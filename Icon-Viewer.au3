#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Fileversion=0.98.7.0
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_ProductName=Icon-Viewer
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_requestedExecutionLevel=None
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
; Icon Viewer
; View and save icons from resource files like shell32.dll or explorer.exe
; By JohnMC - JohnsCS.com - https://github.com/jmclaren7/autoit-scripts

#include <ComboConstants.au3>
;#include <EditConstants.au3>
;#include <MsgBoxConstants.au3>
;#include <StaticConstants.au3>
#include <StructureConstants.au3> ;
;#include <ButtonConstants.au3>
;#include <GUIConstantsEx.au3>
;#include <ListViewConstants.au3>
#include <GuiListView.au3> ;
#include <GuiImageList.au3>
;#include <WindowsConstants.au3>
;#include <File.au3>
;#include <WinAPIShellEx.au3>
;#include <WinAPIRes.au3>

#include "CommonFunctions.au3"


Global $Title = "Icon-Viewer"
;Global $ExportPath = @ScriptDir & "\Icons"
;If Not FileExists($ExportPath) Then DirCreate($ExportPath)

Global $ListViewColumns = 5


; ==== GUI setup
Global $IconGUI = GUICreate($Title, 800, 600, -1, -1)
GUISetIcon("C:\Windows\System32\Shell32.dll", -327, $IconGUI)
Global $IconListView = GUICtrlCreateListView("", 1, 50, 798, 550, BitOR($GUI_SS_DEFAULT_LISTVIEW, $LVS_NOCOLUMNHEADER, $LVS_NOSORTHEADER, $LVS_NOLABELWRAP, $WS_VSCROLL))  ; , $LVS_ALIGNLEFT
_GUICtrlListView_SetView ( $IconListView, 2)
;_GUICtrlListView_SetExtendedListViewStyle($IconListView, BitOr($LVS_EX_GRIDLINES, $LVS_EX_BORDERSELECT, $LVS_EX_SUBITEMIMAGES)) ; This is done seperately from GUICtrlCreateListView in order to fix an issue with the listview border
$IconFileCombo = GUICtrlCreateCombo("shell32.dll", 12, 14, 320, 25, BitOR($GUI_SS_DEFAULT_COMBO, $CBS_DISABLENOSCROLL, $CBS_DROPDOWN))
GUICtrlSetData($IconFileCombo, "shell32.dll|imageres.dll", "shell32.dll")
$BrowseButton = GUICtrlCreateButton('Browse', 340, 10, 60, 28)
$ContextMenu = GUICtrlCreateContextMenu($IconListView)
Local $SaveContext = GUICtrlCreateMenuItem("Save...", $ContextMenu)




GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")

; ==== Add columns
For $i = 1 To $ListViewColumns
	_GUICtrlListView_AddColumn($IconListView, $i, Ceiling((798 - 30) / $ListViewColumns), 0, -1)
Next

GUISetState(@SW_SHOW)

; ==== List any DLLs in system directory that have icons
;~ $aIconFiles = _FileListToArray(@SystemDir, "*.DLL")
;~ For $i = 1 To $aIconFiles[0]
;~ 	If _WinAPI_ExtractIconEx($aIconFiles[$i], -1, 0, 0, 0) > 0 Then
;~ 			ConsoleWrite(@CRLF & "Icons found: " & $aIconFiles[$i])
;~ 			GUICtrlSetData($IconFileCombo, $aIconFiles[$i])
;~ 			;GUICtrlSetData($Progress, 100 - ($i / $aIconFiles[0] * 100))
;~ 	EndIf
;~ Next


_Log("GUI Ready: " & @ScriptName)

; ==== Add Icons
_LoadIcons(@SystemDir & "\Shell32.dll")


_Log("Done")

; ==== GUI loop
While 1
	$Msg = GUIGetMsg()
	If $Msg > 0 Then _Log("$Msg=" & $Msg)
	Switch $Msg
		Case $GUI_EVENT_CLOSE
			Exit

		Case $BrowseButton
			_Log("$BrowseButton")

		Case $IconListView
			_Log("$IconListView")

		Case $IconFileCombo
			_Log("$IconFileCombo")

		Case $SaveContext
			_Log("$SaveContext")
			_GUICtrlListView_GetSelectedIndices($IconListView)

	EndSwitch

	Sleep(10)
Wend


Func _LoadIcons($IconFile)
	_Log("_LoadIcons: " & $IconFile)

	_Timer()

	If Not FileExists($IconFile) Then Return SetError(1)

	; Create the image list, this is attached to the listview control later
	$hImageList = _GUIImageList_Create(32, 32, 5, 3, 256, 512)

	; Get icon count and names from file
	Local $aIconNames = _WinAPI_EnumResourceNames($IconFile, BitOr($RT_GROUP_ICON,$RT_GROUP_CURSOR)) ; BitOr($RT_GROUP_ICON,$RT_GROUP_CURSOR)
	If @error Then
		_Log("_WinAPI_EnumResourceNames Error: " & @error)
		Return SetError(1, @error, 0)
	Endif

	; Add each icon to the image list
	For $Index = 1 To $aIconNames[0]
		$ErrorCheck = _GUIImageList_AddIcon($hImageList, $IconFile, $Index - 1, True)
		If $ErrorCheck = -1 Then _Log("_GUIImageList_AddIcon Error: $Index=" & $Index & "  $aIconNames[$Index]=" & $aIconNames[$Index] & "  $ErrorCheck=" & $ErrorCheck)
	Next
	_Log("Timer: " & _Timer())

	; Attach image list to listview control
	_GUICtrlListView_SetImageList($IconListView, $hImageList, 1)

	; Populate listview with text and icon
	For $Index = 1 To $aIconNames[0]
		$Text = "" & $Index & @CRLF & " (-" & $aIconNames[$Index] & ")"
		$ErrorCheck = _GUICtrlListView_AddItem($IconListView, $Text, $Index - 1)
		If $ErrorCheck = -1 Then _Log("  _GUICtrlListView_AddItem Error: $Index=" & $Index & "  $aIconNames[$Index]=" & $aIconNames[$Index] & "  $ErrorCheck=" & $ErrorCheck)
	Next

	_Log("Timer: " & _Timer())

	Return $aIconNames[0]
EndFunc   ;==>_LoadIcons

Func _Exit()
	_Log("_Exit")
EndFunc

;~ Func _SaveRow($sDLLName)
;~ 	Local $iCols, $iRows, $iIcons
;~ 	WinSetTitle($hGui, "", $sTitel & $sDLLName)
;~ 	For $iRows = 0 To _GUICtrlListView_GetItemCount($listview) - 1
;~ 		If _GUICtrlListView_GetItemChecked($listview, $iRows) Then
;~ 			$iIcons = $iRows * 16 - 1
;~ 			For $iCols = 1 To 16
;~ 				$iIcons += 1
;~ 				_SaveToFile($sDLLName, $iIcons, $iSize, $iSize)
;~ 				; _SaveToFile($sDLLName, $iIcons, 48, 48)	;comment out and every icon in loop is saved in 48x48
;~ 			Next
;~ 		EndIf
;~ 	Next
;~ EndFunc   ;==>_SaveRow


;~ Func _SaveToFile($sDLLName, $iIconId, $iWidth = 32, $iHeight = 32)
;~ 	ConsoleWrite($sDLLName & @TAB & '|' & $iIconId & '|' & @TAB & $iWidth & '|' & $iHeight & @CRLF)
;~ 	Local $sFile = $sIconPath & '\' & StringReplace($sDLLName, '.dll', '_') & StringReplace($iIconId & '.ico', ' ', '')
;~ 	ConsoleWrite($sFile & @CRLF)
;~ 	Local $hIcon = _WinAPI_ShellExtractIcon(@SystemDir & '\' & $sDLLName, $iIconId, $iWidth, $iHeight)
;~ 	_WinAPI_SaveHICONToFile($sFile, $hIcon)
;~ 	;ShellExecute($sFile)
;~ 	_WinAPI_DestroyIcon($hIcon)
;~ EndFunc   ;==>_SaveToFile



; Used for detecting events related to the listview
Func WM_NOTIFY($hWnd, $iMsg, $wParam, $lParam)
	Local $tNMHDR = DllStructCreate($tagNMHDR, $lParam)
	Local $iCode = DllStructGetData($tNMHDR, "Code")

	Switch $iCode
		Case $NM_CLICK, $NM_DBLCLK, $NM_RCLICK, $NM_RETURN, $NM_SETFOCUS
			Local $tInfo = DllStructCreate($tagNMITEMACTIVATE, $lParam)
			Local $Index = DllStructGetData($tInfo, "Index") + 1 ; +1 to translate to 1 based icon index

			_Log("WM_NOTIFY: $hWnd=" & $hWnd & "  $iMsg=" & $iMsg & "  $wParam=" & $wParam & "  $lParam=" & $lParam & "  $Index=" & $Index)
			_Log("GetSelectedIndices: " & _GUICtrlListView_GetSelectedIndices($IconListView))

			Global $MenuMsg = 2000 + $Index
	EndSwitch

	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_NOTIFY

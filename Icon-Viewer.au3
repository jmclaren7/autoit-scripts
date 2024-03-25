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
#include <StructureConstants.au3> ;
#include <GuiComboBox.au3>
#include <GuiListView.au3> ;
#include <GuiImageList.au3>
#include "CommonFunctions.au3"

Global $Title = "Icon-Viewer"
Global $IconGUI, $IconListView
_Log(@SystemDir)

; ==== GUI setup
$IconGUI = GUICreate($Title, 801, 587, -1, -1, BitOR($GUI_SS_DEFAULT_GUI,$WS_MAXIMIZEBOX,$WS_SIZEBOX,$WS_THICKFRAME,$WS_TABSTOP))
$IconListView = GUICtrlCreateListView("", 1, 34, 798, 550, BitOR($GUI_SS_DEFAULT_LISTVIEW,$LVS_NOCOLUMNHEADER,$LVS_NOSORTHEADER,$LVS_NOLABELWRAP,$WS_VSCROLL))
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 0, 50)
GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKRIGHT+$GUI_DOCKTOP+$GUI_DOCKBOTTOM)
$IconListView_0 = GUICtrlCreateListViewItem("", $IconListView)
$IconFileCombo = GUICtrlCreateCombo("", 4, 6, 408, 25)
GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$BrowseButton = GUICtrlCreateButton("Browse", 420, 2, 60, 28)
GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)

$ContextMenu = GUICtrlCreateContextMenu($IconListView)
$SaveContext = GUICtrlCreateMenuItem("Save...", $ContextMenu)
GUISetIcon("C:\Windows\System32\Shell32.dll", -327, $IconGUI)

_GUICtrlListView_SetView ( $IconListView, 2)
GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")

$EnterDummy = GUICtrlCreateDummy()
Local $aAccelKeys[1][2]
$aAccelKeys[0][0] = "{ENTER}"
$aAccelKeys[0][1] = $EnterDummy
GUISetAccelerators($aAccelKeys)

GUISetState(@SW_SHOW)

Local $tInfo
_GUICtrlComboBox_GetComboBoxInfo($IconFileCombo, $tInfo)
Local $hCombo = DllStructGetData($tInfo, "hEdit")

GUICtrlSetData($IconFileCombo, "Shell32.dll|Imageres.dll|wmploc.dll|netshell.dll|DDORes.dll", "Shell32.dll")

_Log("GUI Ready: " & @ScriptName)

_LoadIcons(GUICtrlRead($IconFileCombo))

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
			$NewIconFile = FileOpenDialog($Title, "", "Icon Files (*.exe;*.dll;*.ico)|All (*.*)", 1, "", $IconGUI)
			If Not @error Then _LoadIcons($NewIconFile)

		Case $IconListView
			_Log("$IconListView")

		Case $IconFileCombo
			_Log("$IconFileCombo")
			_LoadIcons(GUICtrlRead($IconFileCombo))

		Case $EnterDummy
			_Log("$EnterDummy")
			$Focus = ControlGetHandle($IconGUI, "", ControlGetFocus ($IconGUI))

			If $Focus = $hCombo Then
				_Log("$IconFileCombo")
				_LoadIcons(GUICtrlRead($IconFileCombo))

			EndIf

		Case $SaveContext
			_Log("$SaveContext")
			_Log(_GUICtrlListView_GetSelectedIndices($IconListView))

	EndSwitch

	Sleep(10)
Wend


Func _LoadIcons($IconFile)
	_Log("_LoadIcons: " & $IconFile)
	_Timer()

	; Check if the file exists, if it doesn't check the system32 folder
	If Not FileExists($IconFile) Then
		$IconFile = @SystemDir & "\" & $IconFile
		If Not FileExists($IconFile) Then Return SetError(1)
	EndIf

	; Remove all existing list view items
	_GUICtrlListView_DeleteAllItems($IconListView)

	If Not FileExists($IconFile) Then Return SetError(1)

	; Create the image list, this is attached to the listview control later
	Local $hImageList = _GUIImageList_Create(32, 32, 5, 3, 256, 512)

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



;~ Func _SaveToFile($sFile, $iIconId, $iWidth = 32, $iHeight = 32)
;~ 	Local $sOutputFile = $sIconPath & '\' & StringReplace($sFile, '.dll', '_') & StringReplace($iIconId & '.ico', ' ', '')
;~ 	ConsoleWrite($sFile & @CRLF)
;~ 	Local $hIcon = _WinAPI_ShellExtractIcon($sFile, $iIconId, $iWidth, $iHeight)
;~ 	_WinAPI_SaveHICONToFile($sOutputFile, $hIcon)
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
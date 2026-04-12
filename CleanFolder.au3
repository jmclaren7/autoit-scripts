#cs ----------------------------------------------------------------------------

	 AutoIt Version: 3.3.18.0
	 Author:         myName

	 Script Function:
		Recursively delete files matching patterns in an array within the script directory.

#ce ----------------------------------------------------------------------------

#include <File.au3>
#include <FileConstants.au3>
#include <Array.au3>
#include <MsgBoxConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>

; ------------------------------------------------------------------------------
; Configuration
; ------------------------------------------------------------------------------
; Define the array of file patterns to delete.
; Add or remove patterns as needed. Wildcards (* and ?) are supported.
Local $aPatterns[] = ["*.tmp", "*.log", "*.bak", "Thumbs.db", "*.ini", "*.cfg"]
; ------------------------------------------------------------------------------

_Main()

Func _Main()
	Local $sTargetDir = @ScriptDir
	
	; Convert array to semicolon-separated string for _FileListToArrayRec
	Local $sMask = _ArrayToString($aPatterns, ";")
	
	ConsoleWrite("Starting cleanup in: " & $sTargetDir & @CRLF)
	ConsoleWrite("Looking for patterns: " & $sMask & @CRLF)

	; Find files recursively
	; 1 : Return files only ($FLTAR_FILESONLY)
	; 1 : Search in subdirectories ($FLTAR_RECUR)
	; 0 : Not sorted ($FLTAR_NOSORT)
	; 1 : Return full path ($FLTAR_FULLPATH)
	Local $aFiles = _FileListToArrayRec($sTargetDir, $sMask, 1, 1, 0, 1)
	
	If @error Then
		ConsoleWrite("No files found matching the specified patterns." & @CRLF)
		MsgBox($MB_ICONINFORMATION, "Cleanup Report", "No files found matching the patterns.")
		Return
	EndIf

	; Create GUI for confirmation
	Local $hGUI = GUICreate("Confirm Deletion", 600, 400)
	GUICtrlCreateLabel("Found " & $aFiles[0] & " files to delete. Review the list below:", 10, 10, 580, 20)
	
	; Create a list box with horizontal scrollbar ($WS_HSCROLL) and vertical scrollbar ($WS_VSCROLL is default)
	Local $idList = GUICtrlCreateList("", 10, 40, 580, 310, BitOR($WS_BORDER, $WS_VSCROLL, $WS_HSCROLL))
	
	; Populate list - skip index 0 (count)
	; Using a loop to avoid string length limits of _ArrayToString for massive lists, 
	; though for speed on huge lists, _ArrayToString is often better. 
	; For safety and simplicity here, we loop.
	For $i = 1 To $aFiles[0]
		GUICtrlSetData($idList, $aFiles[$i])
	Next
	
	Local $idBtnDelete = GUICtrlCreateButton("Delete Files", 150, 360, 120, 30)
	Local $idBtnCancel = GUICtrlCreateButton("Cancel", 330, 360, 120, 30)
	
	GUISetState(@SW_SHOW, $hGUI)
	
	Local $bDelete = False
	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE, $idBtnCancel
				$bDelete = False
				ExitLoop
			Case $idBtnDelete
				$bDelete = True
				ExitLoop
		EndSwitch
	WEnd
	
	GUIDelete($hGUI)
	
	If Not $bDelete Then
		ConsoleWrite("Operation cancelled by user." & @CRLF)
		Return
	EndIf

	Local $iDeleted = 0
	Local $iFailed = 0
	
	; Loop through the array of found files (Index 0 contains the count)
	For $i = 1 To $aFiles[0]
		; Skip the script itself if it happens to match a pattern (safety check)
		If $aFiles[$i] = @ScriptFullPath Then ContinueLoop
		
		If FileDelete($aFiles[$i]) Then
			ConsoleWrite("Deleted: " & $aFiles[$i] & @CRLF)
			$iDeleted += 1
		Else
			ConsoleWrite("Failed to delete: " & $aFiles[$i] & @CRLF)
			$iFailed += 1
		EndIf
	Next
	
	Local $sMessage = "Cleanup Complete." & @CRLF & @CRLF & _
					  "Deleted: " & $iDeleted & " files."
	
	If $iFailed > 0 Then
		$sMessage &= @CRLF & "Failed: " & $iFailed & " files."
	EndIf
	
	MsgBox($MB_ICONINFORMATION, "Cleanup Report", $sMessage)
EndFunc

#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Res_Fileversion=0.1.0.6
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_Language=1033
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <File.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include "CommonFunctions.au3"
#include <Array.au3>

_ConsoleWrite("Start")

$ScriptName = "NTFSReport"
$ScanDirectory = @ScriptDir
$ReportPath = @ScriptDir&"\"&$ScriptName&".html"

_ConsoleWrite("GUICreate")
#Region ### START Koda GUI section ### Form=c:\users\john mclaren\documents\github\autoitscripts\ntfsreport.kxf
$Form1 = GUICreate("Form1", 488, 180, 288, 278)
$ScanBrowseButton = GUICtrlCreateButton("Browse", 392, 32, 75, 25)
$ScanInput = GUICtrlCreateInput("ScanInput", 24, 32, 361, 21)
$Label1 = GUICtrlCreateLabel("Scan Directory", 24, 13, 74, 17)
$Label2 = GUICtrlCreateLabel("Save Report To", 24, 61, 80, 17)
$SaveReportsInput = GUICtrlCreateInput("SaveReportsInput", 24, 80, 361, 21)
$SaveReportBrowseButton = GUICtrlCreateButton("Browse", 392, 80, 75, 25)
$GenerateReportButton = GUICtrlCreateButton("Generate", 392, 144, 75, 25)
$RecurseCheck = GUICtrlCreateCheckbox("Recurse", 24, 120, 97, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
$IncludeFilesCheck = GUICtrlCreateCheckbox("Include Files", 24, 144, 97, 17)
$IncludeSystemCheck = GUICtrlCreateCheckbox("Include System/Builtin", 128, 144, 153, 17)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

GUICtrlSetData ($ScanInput, $ScanDirectory)
GUICtrlSetData ($SaveReportsInput, $ReportPath)

_ConsoleWrite("MainLoop")
While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit

		Case $ScanBrowseButton
			_ConsoleWrite("$bScanBrowse")
			$ScanDirectory = GUICtrlRead ($ScanInput)
			$ScanDirectory = FileSelectFolder ( $ScriptName&" - Select Directory", $ScanDirectory, 0, "", $Form1)
			GUICtrlSetData ($ScanInput, $ScanDirectory)

		Case $SaveReportBrowseButton
			_ConsoleWrite("$bReportBrowse")
			$ReportPath = GUICtrlRead ($SaveReportsInput)
			$ReportPath = FileSaveDialog ( $ScriptName&" - Save Report", $ReportPath, "HTML file (*.html)", $FD_PROMPTOVERWRITE , $ScriptName&".html", $Form1)
			GUICtrlSetData ($SaveReportsInput, $ReportPath)

		Case $GenerateReportButton
			_ConsoleWrite("$bGenerate")
			$aFiles = _FileListToArrayRec($ScanDirectory, "*", $FLTAR_FOLDERS, $FLTAR_RECUR)

			;_ConsoleWrite("_FileWriteFromArray")
			_FileWriteFromArray(@DesktopDir&"\files.txt", $aFiles, 1)
			;_ConsoleWrite("Done")

			$Start = TimerInit()
			For $i = 1 To UBound($aFiles) - 1
				$ThisFile = $ScanDirectory&$aFiles[$i]
				_ConsoleWrite("$ThisFile = " & $ThisFile)

				$array = _GetACL ("C:\Users\John McLaren\Documents\GitHub\AutoITScripts")

				_ConsoleWrite(_ArrayToString($array, " > "))

				;for $z = 1 to 100


					;if StringInStr(,)


				;next

			Next
			_ConsoleWrite(TimerDiff($Start))

	EndSwitch

	sleep(10)
WEnd


Func _GetACL ($Path)
	If StringRight($Path, 1) = "\" Then $Path = StringTrimRight($Path,1)

    Local $Run = FileGetShortName(@SystemDir & "\cacls.exe") & ' "' & $Path & '"'
    Local $iPid = Run($Run, '', @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
	While ProcessExists($iPID)
		Sleep(10)
	Wend
	Local $Data = StdoutRead($iPID)

	$Data = StringReplace($Data, $Path, "")
	$Data = StringStripWS($Data, $STR_STRIPLEADING + $STR_STRIPTRAILING)

	$Data = StringSplit($Data, @CRLF, $STR_ENTIRESPLIT)

	Local $aTable[0][2]

	For $i=1 To Ubound($Data) - 1
		$Data[$i] = StringStripWS($Data[$i], $STR_STRIPLEADING + $STR_STRIPTRAILING)
		Local $Subject = StringLeft($Data[$i], StringInStr($Data[$i], ":")-1)
		Local $Access = StringTrimLeft($Data[$i], StringInStr($Data[$i], ":"))
		_ArrayAdd ($aTable, $Subject&"|"&$Access)

	Next

	Return $aTable
EndFunc


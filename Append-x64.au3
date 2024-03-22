



#include <File.au3>
#include <WinAPIFiles.au3>

$sPath = FileSelectFolder("Select a folder to append to the .exe files", "", 0, @ScriptDir)
if @error then exit
$kernel32 = DllOpen('kernel32.dll')
$aFiles = _FileListToArrayRec($sPath, "*.exe", 1 + 8, 1)
$Append = "-x64"
For $i = 1 To $aFiles[0]
	$ThisFileFullPath = $sPath & "\" & $aFiles[$i]
	If Not StringInStr($ThisFileFullPath, "64") Then
		Local $aCall = DllCall($kernel32, 'int', 'GetBinaryTypeW', 'wstr', $ThisFileFullPath, 'dword*', 0)
		If @error Or Not $aCall[0] Then ContinueLoop

		If $aCall[2] = $SCS_64BIT_BINARY Then
			$NewFileFullPath = StringReplace($ThisFileFullPath, ".exe", $Append & ".exe")
			FileMove($ThisFileFullPath, $NewFileFullPath)
			ConsoleWrite(@CRLF & "$NewFileFullPath=" & $NewFileFullPath)

		EndIf

	EndIf
Next
DllClose($kernel32)

ConsoleWrite(@CRLF)
#include <GUIConstantsEx.au3>
#include <EditConstants.au3>
#include <WindowsConstants.au3>
#include <ListViewConstants.au3>
#include <GuiListView.au3>
#include <File.au3>
#include <Array.au3>

; Create GUI
Local $hGUI = GUICreate("Digital Signature Checker", 1000, 600, -1, -1, $WS_OVERLAPPEDWINDOW)
Local $idBrowse = GUICtrlCreateButton("Browse Directory", 10, 10, 120, 30)
Local $idPath = GUICtrlCreateInput("", 140, 15, 400, 20, $ES_READONLY)
Local $idScan = GUICtrlCreateButton("Start Scan", 550, 10, 100, 30)
Local $idProgress = GUICtrlCreateProgress(10, 50, 640, 20)
Local $idListView = GUICtrlCreateListView("File Name|STIssuedBy|STIssuedFor|STValid|STRevoked|PSSigner|PSValid|PSRevoked|Error|File Path", 10, 80, 980, 500, $LVS_REPORT + $LVS_SHOWSELALWAYS)

; Set ListView column widths
_GUICtrlListView_SetColumnWidth($idListView, 0, 300)
_GUICtrlListView_SetColumnWidth($idListView, 1, 170)
_GUICtrlListView_SetColumnWidth($idListView, 2, 170)
_GUICtrlListView_SetColumnWidth($idListView, 3, 50)
_GUICtrlListView_SetColumnWidth($idListView, 4, 50)
_GUICtrlListView_SetColumnWidth($idListView, 5, 50)
_GUICtrlListView_SetColumnWidth($idListView, 6, 50)
_GUICtrlListView_SetColumnWidth($idListView, 7, 50)
_GUICtrlListView_SetColumnWidth($idListView, 8, 100)
_GUICtrlListView_SetColumnWidth($idListView, 9, 200)

GUISetState(@SW_SHOW, $hGUI)

Local $sSelectedPath = ""
Local $aFiles[0]

While 1
    Local $nMsg = GUIGetMsg()
    
    Switch $nMsg
        Case $GUI_EVENT_CLOSE
            Exit
            
        Case $idBrowse
            $sSelectedPath = FileSelectFolder("Select directory to scan:", @DesktopDir, 1)
            If $sSelectedPath <> "" Then
                GUICtrlSetData($idPath, $sSelectedPath)
                GUICtrlSetState($idScan, $GUI_ENABLE)
            EndIf
            
        Case $idScan
            If $sSelectedPath <> "" Then
                ScanDirectory($sSelectedPath, $idListView, $idProgress)
            EndIf
    EndSwitch
WEnd

Func ScanDirectory($sPath, $idLV, $idProg)
    ; Clear previous results
    _GUICtrlListView_DeleteAllItems($idLV)
    
    ; Get all executable files recursively
    Local $aFiles = GetExecutableFiles($sPath)
    Local $iTotal = UBound($aFiles)
    
    If $iTotal = 0 Then
        MsgBox(48, "Info", "No executable files found in the selected directory.")
        Return
    EndIf
    
    ; Process each file
    For $i = 0 To $iTotal - 1
        Local $sFilePath = $aFiles[$i]
        Local $sFileName = StringRegExpReplace($sFilePath, ".*\\", "")
        
        ; Update progress
        GUICtrlSetData($idProg, Int(($i / $iTotal) * 100))
        
        ; Check digital signature
        Local $aSignInfo = CheckDigitalSignature($sFilePath)
        
        ; Add to ListView
        Local $sStatus = $aSignInfo[0]
        Local $sSignedBy = $aSignInfo[1]
        Local $sValid = $aSignInfo[2]
        Local $sRevoked = $aSignInfo[3]
        Local $sError = $aSignInfo[4]
        Local $sPSsigner = $aSignInfo[5]
        Local $sPSvalid = $aSignInfo[6]
        Local $sPSrevoked = $aSignInfo[7]
        Local $sSignedTo = $aSignInfo[8]
        
        
        _GUICtrlListView_AddItem($idLV, $sFileName)
        _GUICtrlListView_SetItemText($idLV, $i, $sSignedBy, 1)
        _GUICtrlListView_SetItemText($idLV, $i, $sSignedTo, 2)
        _GUICtrlListView_SetItemText($idLV, $i, $sValid, 3)
        _GUICtrlListView_SetItemText($idLV, $i, $sRevoked, 4)
        _GUICtrlListView_SetItemText($idLV, $i, $sPSsigner, 5)
        _GUICtrlListView_SetItemText($idLV, $i, $sPSvalid, 6)
        _GUICtrlListView_SetItemText($idLV, $i, $sPSrevoked, 7)
        _GUICtrlListView_SetItemText($idLV, $i, $sError, 8)
        _GUICtrlListView_SetItemText($idLV, $i, $sFilePath, 9)
        ; Color code based on status
        Switch $sStatus
            Case "Signed"
                If $sValid = "Yes" And $sRevoked = "No" Then
                    _GUICtrlListView_SetItemParam($idLV, $i, 0x00FF00) ; Green for valid
                Else
                    _GUICtrlListView_SetItemParam($idLV, $i, 0x0000FF) ; Red for invalid/revoked
                EndIf
            Case "Not Signed"
                _GUICtrlListView_SetItemParam($idLV, $i, 0x00FFFF) ; Yellow for unsigned
            Case Else
                _GUICtrlListView_SetItemParam($idLV, $i, 0x808080) ; Gray for error
        EndSwitch
    Next
    
    ; Complete progress
    GUICtrlSetData($idProg, 100)
    MsgBox(64, "Complete", "Scan completed. Processed " & $iTotal & " files.")
EndFunc

Func GetExecutableFiles($sPath)
    Local $aFiles[0]
    Local $aExtensions[3] = [".exe", ".dll", ".msi"]
    
    For $i = 0 To 2
        Local $aFound = _FileListToArrayRec($sPath, "*" & $aExtensions[$i], $FLTAR_FILES, $FLTAR_RECUR, $FLTAR_NOSORT, $FLTAR_FULLPATH)
        If Not @error And IsArray($aFound) Then
            For $j = 1 To $aFound[0]
                _ArrayAdd($aFiles, $aFound[$j])
            Next
        EndIf
    Next
    
    Return $aFiles
EndFunc

Func CheckDigitalSignature($sFilePath)
    Local $aResult[9] = ["Unknown", "", "", "", ""]
    
    ; Use signtool.exe to verify signature
    Local $sSignToolPath = @WindowsDir & "\System32\signtool.exe"
    If Not FileExists($sSignToolPath) Then
        $sSignToolPath = @ProgramFilesDir & "\Windows Kits\10\bin\10.0.26100.0\x64\signtool.exe"
        If Not FileExists($sSignToolPath) Then
            $aResult[0] = "Error"
            $aResult[4] = "SignTool not found"
            Return $aResult
        EndIf
    EndIf
    
    ; Check if file has signature
    Local $iPID = Run('"' & $sSignToolPath & '" verify /pa /all /debug "' & $sFilePath & '"', "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
    Local $sOutput = ""
    Local $sError = ""
    
    While 1
        $sError &= StderrRead($iPID)
        $errorerror = @error
        $sOutput &= StdoutRead($iPID)
        If @error AND $errorerror Then ExitLoop
        Sleep(10)
    WEnd
    
    Local $iExitCode = @extended

    ; Extract signer Issued by information
    Local $aMatches = StringRegExp($sOutput, "Issued by: (.+)", 1)
    If Not @error And UBound($aMatches) > 0 Then
        $aResult[1] = StringStripWS($aMatches[0], 3)
    Else
        $aResult[1] = "Error"
        ConsoleWrite(@CRLF & "Error extracting Issued by information: " & @CRLF & $sOutput & @CRLF & @CRLF)
    EndIf

    ; Extract signer information
    Local $aMatches = StringRegExp($sOutput, "Issued to: (.+)", 1)
    If Not @error And UBound($aMatches) > 0 Then
        $aResult[8] = StringStripWS($aMatches[0], 3)
    Else
        $aResult[8] = "Error"
        ConsoleWrite(@CRLF & "Error extracting Issued to information: " & @CRLF & $sOutput & @CRLF & @CRLF)
    EndIf
    
    ; Parse results
    If StringInStr($sOutput, "Successfully verified") Then
        $aResult[0] = "Signed"
        $aResult[2] = "Yes"
        $aResult[3] = "No"
        
    ElseIf StringInStr($sError, "No signature found") Or StringInStr($sOutput, "No signature found") Then
        $aResult[0] = "Not Signed"
        $aResult[2] = "N/A"
        $aResult[3] = "N/A"
        
    ElseIf StringInStr($sError, "certificate chain") Or StringInStr($sOutput, "certificate chain") Then
        $aResult[0] = "Signed"
        $aResult[2] = "No"
        $aResult[3] = "Unknown"
        $aResult[4] = "Certificate chain error"
        
    ElseIf StringInStr($sError, "revoked") Or StringInStr($sOutput, "revoked") Then
        $aResult[0] = "Signed"
        $aResult[2] = "No"
        $aResult[3] = "Yes"
        $aResult[4] = "Certificate revoked"
        
    Else
        $aResult[0] = "Error"
        $aResult[4] = StringLeft($sError & $sOutput, 100)
    EndIf
    
    ; Additional check using WinVerifyTrust API for more detailed info
    If $aResult[0] = "Signed" Then
        Local $aWinTrustResult = CheckWinVerifyTrust($sFilePath)
        If $aWinTrustResult[0] <> "" Then
            $aResult[5] = $aWinTrustResult[0] ; Signer name
            $aResult[6] = $aWinTrustResult[1] ; Valid
            $aResult[7] = $aWinTrustResult[2] ; Revoked
        EndIf
    EndIf
    
    Return $aResult
EndFunc

Func CheckWinVerifyTrust($sFilePath)
    Local $aResult[3] = ["", "", ""]
    
    ; Use PowerShell to get detailed signature information
    Local $sPS = 'Get-AuthenticodeSignature "' & $sFilePath & '" | Select-Object SignerCertificate, Status'
    Local $iPID = Run(@ComSpec & ' /c powershell.exe -Command "' & $sPS & '"', "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
    
    Local $sOutput = ""
    While 1
        $sOutput &= StdoutRead($iPID)
        If @error Then ExitLoop
        Sleep(10)
    WEnd
    
    ; Parse PowerShell output
    If StringInStr($sOutput, "Valid") Then
        $aResult[1] = "Yes"
        $aResult[2] = "No"
        
        ; Extract subject name
        Local $aMatches = StringRegExp($sOutput, "CN=([^,]+)", 1)
        If Not @error And UBound($aMatches) > 0 Then
            $aResult[0] = $aMatches[0]
        EndIf
        
    ElseIf StringInStr($sOutput, "UnknownError") Then
        $aResult[1] = "Unknown"
        $aResult[2] = "Unknown"
    ElseIf StringInStr($sOutput, "NotTrusted") Then
        $aResult[1] = "No"
        $aResult[2] = "Unknown"
    EndIf
    
    Return $aResult
EndFunc
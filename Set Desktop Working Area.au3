; Sets the area that windows are able to use when maximized

Global $IsPE = StringInStr(@SystemDir, "X:")

If $IsPE Then _WorkingArea(0, 0, @DesktopWidth, @DesktopHeight - 30)

Func _WorkingArea($iLeft = Default, $iTop = Default, $iWidth = Default, $iHeight = Default)
    Local Static $tWorkArea = 0
    If IsDllStruct($tWorkArea) Then
        _WinAPI_SystemParametersInfo($SPI_SETWORKAREA, 0, DllStructGetPtr($tWorkArea), $SPIF_SENDCHANGE)
        $tWorkArea = 0
    Else
        $tWorkArea = DllStructCreate($tagRECT)
        _WinAPI_SystemParametersInfo($SPI_GETWORKAREA, 0, DllStructGetPtr($tWorkArea))

        Local $tCurrentArea = DllStructCreate($tagRECT)
        Local $aArray[4] = [$iLeft, $iTop, $iWidth, $iHeight]
        For $i = 0 To 3
            If $aArray[$i] = Default Or $aArray[$i] < 0 Then
                $aArray[$i] = DllStructGetData($tWorkArea, $i + 1)
            EndIf
            DllStructSetData($tCurrentArea, $i + 1, $aArray[$i])
            $aArray[$i] = DllStructGetData($tWorkArea, $i + 1)
        Next
        _WinAPI_SystemParametersInfo($SPI_SETWORKAREA, 0, DllStructGetPtr($tCurrentArea), $SPIF_SENDCHANGE)
        $aArray[2] -= $aArray[0]
        $aArray[3] -= $aArray[1]
        Local $aReturn[4] = [$aArray[2], $aArray[3], $aArray[0], $aArray[1]]
        Return $aReturn
    EndIf
EndFunc   ;==>_WorkingArea
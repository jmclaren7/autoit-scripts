#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Res_Fileversion=1.0.0.10
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#RequireAdmin
#include <Process.au3>

$sUninstall = GetUninstallString("Teams Machine-Wide Installer")
If Not @error Then
	$sUninstall = StringReplace($sUninstall, " /I", " /x") & " /qn"
	_RunDos($sUninstall)
endif

_RunDos(""""&@LocalAppDataDir&"\Microsoft\Teams\Update.exe"" --uninstall -s")
sleep(4000)


Func GetUninstallString($app)
   $key = "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall"
   Local $i = 0

   While 1
      $i += 1
      $subkey = RegEnumKey($key, $i)
      If @error Then ExitLoop
      $displayname = RegRead($key & "\" & $subkey, "DisplayName")
      If @error Then ContinueLoop
      If $displayname == $app Then
            Return RegRead($key & "\" & $subkey, "UninstallString")
      EndIf
   WEnd
   SetError(1)
   Return ""
EndFunc
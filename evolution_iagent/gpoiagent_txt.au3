#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.12.0
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here



#include <File.au3>
#include <Array.au3>
#include <MsgBoxConstants.au3>
#include <AutoItConstants.au3>
#include <Misc.au3>
#RequireAdmin

$UltimaVersion = "10.6.2313.218"   ;Version del Evolution 10.6 10.6V2 "10.6.2313.218" | v1"10.6.2313.121"

If @OSArch = "X86" Then
   $Programfile = "C:\Program Files"
EndIf
If @OSArch = "X64" Then
   $Programfile = "C:\Program Files (x86)"
EndIf

if FileExists("\\172.16.1.26\Shared\logs\") Then
	  $logsroute = "\\172.16.1.26\Shared\logs\iagent.txt"
	;	 if FileExists("C:\iagent.txt") Then _FileWriteLog("\\172.16.1.111\comp\logs\iagent.txt", "Hay residuos de log en C:\" & @ComputerName &  @OSArch, 1)
   Else
	  $logsroute = "C:\iagent.txt"
EndIf

if RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION\", "iagent.exe") <> "9999" Then
	  RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION\", "iagent.exe", "REG_DWORD", "9999")
	  _FileWriteLog($logsroute,  @ComputerName & " ha agregado la clave 32 bits", 1)
EndIf

If @OSArch = "X64" Then
   if RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION\", "iagent.exe") <> "9999" Then
	  RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION\", "iagent.exe", "REG_DWORD", "9999")
	  _FileWriteLog($logsroute, @ComputerName & " ha agregado la clave 64 bits", 1)
   EndIf
EndIf


If FileExists($Programfile & '\Evolution\Agente\iAgent.exe') Then

   $version = stringreplace(StringReplace(FileGetVersion($Programfile & '\Evolution\Agente\iAgent.exe',  $FV_PRODUCTVERSION), "BUILD", "")," ", ".")

	  if $version = $ultimaversion Then
		 Call("registro")
		 Exit
	  Else

	  If @OSArch = "X86" Then
		 $Puesto = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\ICR\Evolution/iAgent\Global", "Puesto")
		 $ServerAddress = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\ICR\Evolution/iAgent\Server", "ServerAddress")
	  EndIf

	  If @OSArch = "X64" Then
		 $Puesto = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432NODE\ICR\Evolution/iAgent\Global", "Puesto")
		 $ServerAddress = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432NODE\ICR\Evolution/iAgent\Server", "ServerAddress")
	  EndIf

    $mayormenor = _VersionCompare($ultimaversion, $version)

	  if  $mayormenor = "-1" Then
			While ProcessExists("iagent.exe")
			   ProcessClose("iagent.exe")
			WEnd
		 $ipid = Run(@ComSpec & ' /c ' & '"' & $Programfile & '\Evolution\Agente\uninst_Evolution_iAgent.exe" /S')
		 processWaitClose($iPID)
		 _FileWriteLog($logsroute , @ComputerName & " " & @OSArch & " inicia deinstalación de iagent version" & $version & " ,no se admiten versiones superiores", 1)

	  $i = 0
		 While $i <= 120
			if FileExists ($Programfile & '\Evolution\Agente\uninst_Evolution_iAgent.exe') Then
			   sleep (1000)
			   $i = $i + 1
			Else
			   ExitLoop
			EndIf
		 WEnd
	  if $i <> "0" then _FileWriteLog($logsroute, @ComputerName & " ha esperado para ver si estaba borrado " & $i & " segundos, si es 121=timeout, posible fallo", 1)

	  EndIf

    FileCopy(@ScriptDir & "\iagent_" & $ultimaversion & ".exe" , "C:\")
   $ipid = Run("C:\iagent_" & $ultimaversion & ".exe /S /EvoServerAddress=" & $serveraddress & " " & '"/PuestoTrabajo=' & $puesto & '"')
   processWaitClose($iPID)

      $version2 = stringreplace(StringReplace(FileGetVersion($Programfile & '\Evolution\Agente\iAgent.exe',  $FV_PRODUCTVERSION), "BUILD", "")," ", ".")
		 if $version2 = $ultimaversion Then
			_FileWriteLog($logsroute , @ComputerName & " " & @OSArch & " ha actualizado de" & $version & " a " & $version2, 1)
		 Else
			_FileWriteLog($logsroute , @ComputerName & " " & @OSArch & " fallo en la actualizacion de " & $version & " a " & $version2, 1)
		 EndIf
  $a = 1
   while $a <10
	  FileDelete("C:\iagent_" & $ultimaversion & ".exe")
	  if not FileExists("C:\iagent_" & $ultimaversion & ".exe") then ExitLoop
	  Sleep(1000)
	  $a = $a + 1
   WEnd
  Call("registro")
   EndIf
Else
   FileCopy(@ScriptDir & "\iagent_" & $ultimaversion & ".exe" , "C:\")
   $ipid = Run("C:\iagent_" & $ultimaversion & ".exe /S /EvoServerAddress=172.16.0.25 " & '"/PuestoTrabajo=NoCfg"')
   processWaitClose($iPID)

      $version = stringreplace(StringReplace(FileGetVersion($Programfile & '\Evolution\Agente\iAgent.exe',  $FV_PRODUCTVERSION), "BUILD", "")," ", ".")
		 if $version = $ultimaversion Then
			_FileWriteLog($logsroute , @ComputerName & " " & @OSArch & " ha instalado iagent version " & $version, 1)
		 Else
			_FileWriteLog($logsroute , @ComputerName & " " & @OSArch & " fallo en la instalacion de iagent " & $version, 1)
		 EndIf
   FileDelete("C:\iagent_" & $ultimaversion & ".exe")
  $a = 1
   while $a <10
	  FileDelete("C:\iagent_" & $ultimaversion & ".exe")
	  if not FileExists("C:\iagent_" & $ultimaversion & ".exe") then ExitLoop
	  Sleep(1000)
	  $a = $a + 1
   WEnd
   Call("registro")

EndIf

Func registro()

if not FileExists(@ScriptDir & "\evolution.txt") Then
   _FileWriteLog($logsroute , @ComputerName & " " & @OSArch & " no existe evolution.txt", 1)
   Exit
EndIf
$file = FileOpen(@ScriptDir & "\evolution.txt", 0)
While 1
    $line = FileReadLine($file)
	$eofile = @error
	$SeparadoComas = StringSplit($line, ",")
	if $eofile = -1 Then
	   	If @OSArch = "X86" Then
			local $Puesto = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\ICR\Evolution/iAgent\Global", "Puesto")
			local $ServerAddress = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\ICR\Evolution/iAgent\Server", "ServerAddress")
		 EndIf
		 If @OSArch = "X64" Then
			local $Puesto = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432NODE\ICR\Evolution/iAgent\Global", "Puesto")
			local $ServerAddress = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432NODE\ICR\Evolution/iAgent\Server", "ServerAddress")
		 EndIf
		 _FileWriteLog($logsroute ,'No tiene configurado la extension en evolution.txt. No se hara ninguna modificacion en el puesto: ' & @ComputerName & "," & $puesto & "," & $serveraddress, 1)
		 ExitLoop
    EndIf

	if $separadocomas[1] = @ComputerName Then
	  If @OSArch = "X64" Then
		 Global $Puesto = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432NODE\ICR\Evolution/iAgent\Global", "Puesto")
		 Global $ServerAddress = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432NODE\ICR\Evolution/iAgent\Server", "ServerAddress")
	  EndIf

	  If @OSArch = "X86" Then
		 Global $Puesto = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\ICR\Evolution/iAgent\Global", "Puesto")
		 Global $ServerAddress = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\ICR\Evolution/iAgent\Server", "ServerAddress")
	  EndIf


	  If $Puesto <> $SeparadoComas[2] Then
		 ProcessClose ( "iagent.exe" )
		 If @OSArch = "X86" Then
			RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\ICR\Evolution/iAgent\Global", "Puesto", "REG_SZ", $SeparadoComas[2])
		 EndIf
		 If @OSArch = "X64" Then
			RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432NODE\ICR\Evolution/iAgent\Global", "Puesto", "REG_SZ", $SeparadoComas[2])
		 EndIf
		 _FileWriteLog($logsroute , @ComputerName & " " & @OSArch & ' ha cambiado su extension de ' & $Puesto & ' a la extension ' & $SeparadoComas[2], 1)
	  EndIf

	  If $ServerAddress <> $SeparadoComas[3] Then
		 ProcessClose ( "iagent.exe" )
		 If @OSArch = "X86" Then
			RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\ICR\Evolution/iAgent\Server", "ServerAddress", "REG_SZ", $SeparadoComas[3])
			RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\ICR\EvoLink\Settings", "EvoServerAddress", "REG_SZ", $SeparadoComas[3])
		 EndIf
		 If @OSArch = "X64" Then
			RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432NODE\ICR\Evolution/iAgent\Server", "ServerAddress", "REG_SZ", $SeparadoComas[3])
			RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432NODE\ICR\EvoLink\Settings", "EvoServerAddress", "REG_SZ", $SeparadoComas[3])
		 EndIf
		 _FileWriteLog($logsroute , @ComputerName & " " & @OSArch & ' ha cambiado su evoserver de ' & $serveraddress & ' al evoserver ' & $SeparadoComas[3], 1)
	  EndIf
   ExitLoop
   EndIf
WEnd
FileClose($file)

EndFunc
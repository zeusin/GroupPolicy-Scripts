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
#include <SQLite.au3>
#include <SQLite.dll.au3>
#RequireAdmin


$UltimaVersion = "10.6.2313.218"   ;Version Evolution 10.6 V2 "10.6.2313.218" | v1"10.6.2313.121"
$rutared = "\\192.168.55.114\descargas\iagent.txt"
$rutalocal = "C:\iagent.txt"
$clavecompatibilidad = 0 ; clave de compatibilidad de internet explorer, 0 desactiva la ejecucion
$dlllocation = "SQLite3.dll"
$bbddnombre = @ScriptDir & "\puestos.db"

;if FileExists("\\172.16.1.26\Shared\logs\") Then
 ;   $logsroute = $rutared
;Else
    $logsroute = $rutalocal
;EndIf

If @OSArch = "X86" Then
   $Programfile = "C:\Program Files"
   $ClavePuesto = "HKEY_LOCAL_MACHINE\SOFTWARE\ICR\Evolution/iAgent\Global"
   $ClaveServer = "HKEY_LOCAL_MACHINE\SOFTWARE\ICR\Evolution/iAgent\Server"
   $ClaveServer2 = "HKEY_LOCAL_MACHINE\SOFTWARE\ICR\EvoLink\Settings"
EndIf
If @OSArch = "X64" Then
   $Programfile = "C:\Program Files (x86)"
   $clavePuesto = "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432NODE\ICR\Evolution/iAgent\Global"
   $ClaveServer = "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432NODE\ICR\Evolution/iAgent\Server"
   $ClaveServer2 = "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432NODE\ICR\EvoLink\Settings"
EndIf

if $clavecompatibilidad = 1 then
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
EndIf

$version = stringreplace(StringReplace(FileGetVersion($Programfile & '\Evolution\Agente\iAgent.exe',  $FV_PRODUCTVERSION), "BUILD", "")," ", ".")
select
    case $UltimaVersion = $version
		call("registro")
	 case $UltimaVersion <> $version
        call("comprobarmayormenor")
        call("instalar")
        ;call("registro")
    case $UltimaVersion = "0.0.0.0"
        call("instalar")
        ;call("registro")
EndSelect

Func instalar()

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
;esto hay que mejorarlo
  $a = 1
   while $a <10
	  FileDelete("C:\iagent_" & $ultimaversion & ".exe")
	  if not FileExists("C:\iagent_" & $ultimaversion & ".exe") then ExitLoop
	  Sleep(1000)
	  $a = $a + 1
   WEnd

Endfunc

Func comprobarmayormenor()
$mayormenor = _VersionCompare($UltimaVersion, $version)
if  $mayormenor = "-1" Then
    While ProcessExists("iagent.exe")
        ProcessClose("iagent.exe")
    WEnd
    $ipid = Run(@ComSpec & ' /c ' & '"' & $Programfile & '\Evolution\Agente\uninst_Evolution_iAgent.exe" /S')
	processWaitClose($iPID)
	_FileWriteLog($logsroute , @ComputerName & " " & @OSArch & " inicia desinstalación de iagent version" & $version & " ,no se admiten versiones superiores", 1)
	;añadir esperar hasta que desaparezca iagent.exe
 EndIf

Endfunc

Func registro()
$salida = ""
$arow = ""
$mensaje = ""
_SQLite_Startup()
If @error Then
    _FileWriteLog($logsroute , @ComputerName & " " & @OSArch & " SQLite3.dll no puede ser cargada", 1)
    Exit
EndIf
_SQLite_Open($bbddnombre)

If @error Then
    _FileWriteLog($logsroute , @ComputerName & " " & @OSArch & " no puede abrir la base de datos", 1)
    Exit
EndIf

_SQLite_Query(-1, "select extporord.puestos,servidor from extporord,extensiones where extporord.nombrepc='PC001';", $salida)
$noval = _SQLite_FetchData($salida, $aRow)
_SQLite_Close($bbddnombre)
MsgBox(0,"",$noval)
MsgBox(0,"",$arow[0])


if $noval = 101 then MsgBox(0,"","Añadir a base de datos")
   exit

; hay que añadir validacion de si no existe la extension en la base de datos
$extensionpuesto = RegRead($ClavePuesto, $puesto)
$ipservidor = RegRead($ClaveServer, "ServerAddress")

if $arow[0] <> $extensionpuesto then
   RegWrite($ClavePuesto, "puesto", "REG_SZ", $arow[0])
EndIf

if $arow[1] <> $ipservidor then
   RegWrite($ClaveServer, "ServerAddress", "REG_SZ", $arow[1])
   RegWrite($claveServer2, "EvoServerAddress", "REG_SZ", $arow[1])
EndIf

Endfunc

#cs ----------------------------------------------------------------------------
By Manuel Garcia

 Script Function:
	Instala y acutaliza UltraVNC con mirror driver, desinstalando el instalado por la politica original y los scripts previos hechos por mi.

#ce ----------------------------------------------------------------------------
#RequireAdmin
#include <AutoItConstants.au3>
#include <FileConstants.au3>
#include <File.au3>
#include <Misc.au3>

$ultimaversion="1.2.1.1"
If @OSArch = "X86" Then global $program = "C:\program files\uvnc bvba\ultravnc"
If @OSArch = "X64" Then global $program = "C:\program files (x86)\uvnc bvba\ultravnc"
global $file = $program & "\ultravnc.ini"
if FileExists("\\172.16.1.26\Shared\logs\") Then
	  $logsroute = "\\172.16.1.26\Shared\logs\vnc.txt"
		 ;if FileExists("C:\vnc.txt") Then _FileWriteLog("\\172.16.1.111\comp\logs\vnc.txt", "Hay residuos de log en C:\ " & @ComputerName &  @OSArch, 1)
   Else
	  $logsroute = "C:\vnc.txt"
EndIf


If @OSArch = "x64" Then
   If FileExists ("C:\Program Files\uvnc bvba\UltraVNC\winvnc.exe") Then
		 While ProcessExists("winvnc.exe")
			ProcessClose("winvnc.exe")
		 WEnd
     ; $ipid = Run(@ComSpec & ' /c  ' & 'sc stop uvnc_service',  @TempDir, @SW_HIDE)
	 ; ProcessWaitClose($iPID)
	  $ipid = Run(@ComSpec & ' /c  ' & '"C:\Program Files\uvnc bvba\UltraVNC\winvnc.exe" -uninstall', @TempDir, @SW_HIDE, $STDOUT_CHILD)
	  Sleep(40000)
	  $ipid = Run(@ComSpec & ' /c  ' & '"C:\Program Files\uvnc bvba\UltraVNC\unins000.exe" /norestart /verysilent ', @TempDir, @SW_HIDE, $STDOUT_CHILD)
	  ProcessWaitClose($iPID)
	  ;$ipid = Run(@ComSpec & ' /c  ' & 'sc stop uvnc_service',  @TempDir, @SW_HIDE)
	  ;ProcessWaitClose($iPID)
	  ;sleep(5000)
	  ;$ipid = Run(@ComSpec & ' /c  ' & 'sc delete uvnc_service',  @TempDir, @SW_HIDE)
	  ;ProcessWaitClose($iPID)
	  While ProcessExists("winvnc.exe")
			ProcessClose("winvnc.exe")
		 WEnd
	  $borrar = DirRemove("C:\program files\uvnc bvba\",1)
	  if $borrar = 0 then _FileWriteLog($logsroute, @ComputerName & " fallo el borrar la carpeta de vnc, probablemente quede algun servicio arrancado", 1)
	  _FileWriteLog($logsroute , @ComputerName & " Desinstalado UltraVNC de 64 bits en sistema de 64", 1)
   EndIf
EndIf

If FileExists('C:\vncserver') Then
   While ProcessExists("winvnc.exe")
	  ProcessClose("winvnc.exe")
   WEnd
   $ipid = Run(@ComSpec & ' /c  ' & 'sc stop uvnc_service',  @TempDir, @SW_HIDE)
   ProcessWaitClose($iPID)
   sleep(5000)
   $ipid = Run(@ComSpec & ' /c  ' & 'sc delete uvnc_service',  @TempDir, @SW_HIDE)
   ProcessWaitClose($iPID)
   sleep(5000)
   DirRemove("C:\vncserver", 1)
  _FileWriteLog($logsroute , @ComputerName & @OSArch & " Desinstalado C:\VNCServer", 1)
EndIf

if RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System", "SoftwareSASGeneration") <> "1" Then
	  RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System", "SoftwareSASGeneration", "REG_DWORD", "1")
	  _FileWriteLog($logsroute , @ComputerName & @OSArch & "clave añadida")
EndIf



if FileExists ($program & "\winvnc.exe") then
   $versionvnc = FileGetVersion($program & "\winvnc.exe")

	 If  $versionvnc = $ultimaversion Then
		 call("servicio")
		 call("ininame")
		 Exit
	  Else
		 While ProcessExists("winvnc.exe")
			ProcessClose("winvnc.exe")
		 WEnd

		 $mayormenor = _VersionCompare($ultimaversion, $versionvnc)

			if  $mayormenor = "-1" Then
			   $ipid = Run(@ComSpec & ' /c  "' & $program & '\unins000.exe" /norestart /verysilent', @TempDir, @SW_HIDE, $STDOUT_CHILD)
			   ProcessWaitClose($iPID)
		 EndIf
		 call("install")

		 $versionvnc2 = FileGetVersion("C:\Program Files\uvnc bvba\UltraVNC\winvnc.exe")
			If  $versionvnc2 = $ultimaversion Then
			   _FileWriteLog($logsroute, @ComputerName & @OSArch & " Vnc actualizado de " & $versionvnc & " a " & $versionvnc2, 1)
			Else
			   _FileWriteLog($logsroute, @ComputerName & @OSArch & " Vnc fallo al actualizar de " & $versionvnc & " a " & $ultimaversion & " , se permanece en " & $versionvnc2, 1)
			EndIf
	  EndIf
   call("servicio")
   call("ininame")

Else

   call("install")
   $versionvnc = FileGetVersion($program & "\winvnc.exe")

	  If  $versionvnc = $ultimaversion Then
		 _FileWriteLog($logsroute,  @ComputerName & @OSArch & " Vnc instalado " & $ultimaversion, 1)
		 call("ininame")
		 call("servicio")
	  Else
		 _FileWriteLog($logsroute,  @ComputerName & @OSArch & " Vnc no instalado" & $ultimaversion, 1)
		 Exit
	  EndIf

EndIf

Func install()
   While ProcessExists("winvnc.exe")
	  ProcessClose("winvnc.exe")
   WEnd
   DirCopy(@ScriptDir & '\mirror' & @OSArch , @TempDir & '\mirror', $FC_OVERWRITE)
   $iPID = Run(@ComSpec & ' /c  ' & 'certutil.exe -addstore TrustedPublisher ' & @TempDir & '\mirror\UltraVNC.cer', @TempDir, @SW_HIDE)
   ProcessWaitClose($iPID)
   sleep(1000)
   $iPID = Run(@ComSpec & ' /c cd ' & @TempDir & '\mirror && setupdrv.exe install',  @TempDir, @SW_HIDE)
   ProcessWaitClose($iPID)
   sleep(1000)
   DirRemove(@TempDir & '\mirror', 1)
   $iPID = Run(@ComSpec & ' /c  ' & @ScriptDir &  '\VNC_' & $ultimaversion & '_X86.exe /loadinf="' & @ScriptDir & '\configvnc_' & @OSArch & '"' & ' /norestart /verysilent', @TempDir, @SW_HIDE)
   ProcessWaitClose($iPID)
	  if $iPID = "0" Then
		 _FileWriteLog($logsroute,  @ComputerName & @OSArch & " fallo al ejecutar el exe", 1)
	  EndIf

EndFunc

Func ininame()
   global $cambio = ""
   Global $i = 0
   Call("ini", "Ultravnc", "passwd", "29D3D1BDA3D008353A")
   Call("ini", "Ultravnc", "passwd2", "D3785C4E0F8380B3BA")
   Call("ini", "admin", "UseRegistry", "0")
   Call("ini", "admin", "MSLogonRequired", "1")
   Call("ini", "admin", "NewMSLogon", "0")
   Call("ini", "admin", "DebugMode", "0")
   Call("ini", "admin", "Avilog", "0")
   If @OSArch = "x64" Then Call("ini", "admin", "Path", "C:\program files (x86)\uvnc bvba\UltraVNC")
   If @OSArch = "x86" Then Call("ini", "admin", "Path", "C:\program files\uvnc bvba\UltraVNC")
   Call("ini", "admin", "accept_reject_mesg", "")
   Call("ini", "admin", "DebugLevel", "0")
   Call("ini", "admin", "DisableTrayIcon", "0")
   Call("ini", "admin", "rdpmode", "0")
   Call("ini", "admin", "LoopbackOnly", "0")
   Call("ini", "admin", "UseDSMPlugin", "0")
   Call("ini", "admin", "AllowLoopback", "0")
   Call("ini", "admin", "AuthRequired", "1")
   Call("ini", "admin", "ConnectPriority", "0")
   Call("ini", "admin", "DSMPlugin", "")
   Call("ini", "admin", "AuthHosts", "")
   Call("ini", "admin", "DSMPluginConfig", "")
   Call("ini", "admin", "AllowShutdown", "0")
   Call("ini", "admin", "AllowProperties", "0")
   Call("ini", "admin", "AllowEditClients", "1")
   Call("ini", "admin", "FileTransferEnabled", "1")
   Call("ini", "admin", "FTUserImpersonation", "1")
   Call("ini", "admin", "BlankMonitorEnabled", "1")
   Call("ini", "admin", "BlankInputsOnly", "1")
   Call("ini", "admin", "DefaultScale", "1")
   Call("ini", "admin", "primary", "1")
   Call("ini", "admin", "secondary", "1")
   Call("ini", "admin", "SocketConnect", "1")
   Call("ini", "admin", "HTTPConnect", "1")
   Call("ini", "admin", "AutoPortSelect", "1")
   Call("ini", "admin", "PortNumber", "5900")
   Call("ini", "admin", "HTTPPortNumber", "5800")
   Call("ini", "admin", "IdleTimeout", "0")
   Call("ini", "admin", "IdleInputTimeout", "0")
   Call("ini", "admin", "RemoveWallpaper", "0")
   Call("ini", "admin", "RemoveAero", "0")
   Call("ini", "admin", "QuerySetting", "2")
   Call("ini", "admin", "QueryTimeout", "10")
   Call("ini", "admin", "QueryAccept", "0")
   Call("ini", "admin", "QueryIfNoLogon", "1")
   Call("ini", "admin", "InputsEnabled", "1")
   Call("ini", "admin", "LockSetting", "0")
   Call("ini", "admin", "LocalInputsDisabled", "0")
   Call("ini", "admin", "EnableJapInput", "0")
   Call("ini", "admin", "kickrdp", "0")
   Call("ini", "admin", "Clearconsole", "0")
   Call("ini", "admin_auth", "group1", "administradores")
   Call("ini", "admin_auth", "group2", "")
   Call("ini", "admin_auth", "group3", "")
   Call("ini", "admin_auth", "locdom1", "1")
   Call("ini", "admin_auth", "locdom2", "0")
   Call("ini", "admin_auth", "locdom3", "0")
   Call("ini", "poll", "TurboMode", "1")
   Call("ini", "poll", "PollUnderCursor", "0")
   Call("ini", "poll", "PollForeground", "0")
   Call("ini", "poll", "PollFullScreen", "1")
   Call("ini", "poll", "OnlyPollConsole", "0")
   Call("ini", "poll", "OnlyPollOnEvent", "0")
   Call("ini", "poll", "MaxCpu", "50")
   Call("ini", "poll", "EnableDriver", "1")
   Call("ini", "poll", "EnableHook", "1")
   Call("ini", "poll", "EnableVirtual", "0")
   Call("ini", "poll", "SingleWindow", "0")
   Call("ini", "poll", "SingleWindowName", "")
   If $i = 1 Then
	  $pid = Run(@ComSpec & ' /C net stop uvnc_service & sc start uvnc_service', '', @SW_HIDE, 2)
	  ProcessWaitClose($pid)
	  _FileWriteLog($logsroute,  @ComputerName & @OSArch & " Se ha reiniciado el servicio por haber cambiado el ini." & " || " & $cambio, 1)
   EndIf
EndFunc

Func Ini($section, $key, $valor )
   $reg = IniRead($file, $section, $key, "NotFound")
   If $reg <> $valor Then
	  global $i = 1
	  $cambio = $cambio & " cambio de [" & $section & "] " & $key & " de "  & $reg & " a " & $valor & " | "
	 IniWrite($file, $section, $key, $valor)
   EndIf
EndFunc


Func servicio()

   $pid = Run('sc query uvnc_service', '', @SW_HIDE, 2)

Global $data

Do
    $data &= StdOutRead($pid)
Until @error

If StringInStr($data, 'running') Then
   ConsoleWrite("corriendo")
Else
   $ipid = Run(@ComSpec & ' /c  "' & $program &  '\winvnc.exe" -install', @TempDir, @SW_HIDE, $STDOUT_CHILD)
   ProcessWaitClose($iPID)
   _FileWriteLog($logsroute,  @ComputerName & @OSArch & " Se ha instalado el servicio porque no estaba instalado.", 1)
EndIf

EndFunc

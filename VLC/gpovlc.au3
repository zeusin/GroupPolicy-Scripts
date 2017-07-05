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
$ultimaversion = "2.2.2.0"

if FileExists("\\172.16.1.26\Shared\logs\") Then
	  $logsroute = "\\172.16.1.26\Shared\logs\vlc.txt"
	;	 if FileExists("C:\vlc.txt") Then _FileWriteLog("\\172.16.1.111\comp\logs\vlc.txt", "Hay residuos de log en C:\" & @ComputerName &  @OSArch)
   Else
	  $logsroute = "C:\vlc.txt"
EndIf




If @OSArch = "X86" Then
   $Programfile = "C:\Program Files"
EndIf
If @OSArch = "X64" Then
   $Programfile = "C:\Program Files"
   if FileExists("C:\Program Files (x86)\VideoLAN\VLC\vlc.exe") Then
	  $ipid = Run(@ComSpec & ' /c ' & '"C:\Program Files (x86)\VideoLAN\VLC\uninstall.exe" /S', @TempDir, @SW_HIDE, $STDOUT_CHILD)
	  processWaitClose($iPID)
	  DirRemove("C:\Program Files (x86)\VideoLAN")
	  _FileWriteLog($logsroute , @ComputerName & " " & @OSArch & " vlc 32 bits desinstalado", 1)
   EndIf
EndIf

if FileExists ($Programfile & "\VideoLAN\VLC\vlc.exe") then

   $Vncversion = FileGetVersion($Programfile & "\VideoLAN\VLC\vlc.exe")

	  if $vncversion = $ultimaversion Then Exit

   SplashTextOn("Actualización de Software", "Se esta actualizando VLC, sea paciente." & @CRLF & @CRLF & "Dept. Sistemas." & @CRLF & @CRLF & "La paciencia no es simplemente la capacidad de esperar, es cómo nos comportamos mientras esperamos." & @CRLF &  "Joyce Meyer." , 450, 200, -1, 150, $DLG_TEXTLEFT , "", 12)
   $mayormenor = _VersionCompare($ultimaversion, $vncversion)

	  if  $mayormenor = "-1" Then
			While ProcessExists("vlc.exe")
			   ProcessClose("vlc.exe")
			WEnd
		 $ipid = Run(@ComSpec & ' /c ' & $Programfile & '\VideoLAN\VLC\uninstall.exe /S', @TempDir, @SW_HIDE, $STDOUT_CHILD)
		 processWaitClose($iPID)

		; $i = 0
		;	While $i <= 120
		;	   if FileExists ($Programfile & '\VideoLAN\VLC\vlc.exe') Then
		;	   sleep (1000)
		;		  $i = $i + 1
		;	   Else
		;		  ExitLoop
		;	   EndIf
		;	WEnd
		 ;_FileWriteLog("\\172.16.1.111\comp\logs\vlc.txt", "Se ha esperado " & $i & " segundos para desaparecer vlc.exe en " & @ComputerName & " " & @OSArch)
			;if FileExists ($Programfile & '\VideoLAN\VLC\vlc.exe') Then
			 ;  _FileWriteLog("\\172.16.1.111\comp\logs\vlc.txt", "vlc en version " & $vncversion & " no se ha desinstalado " & @ComputerName & " " & @OSArch)
			;Else
			   _FileWriteLog($logsroute , "vlc en version " & $vncversion & " desinstalada, no se admiten versiones superiores " & @ComputerName & " " & @OSArch, 1)
			;EndIf
	  EndIf

   Call("instalar")
   $Vncversion = FileGetVersion($Programfile & "\VideoLAN\VLC\vlc.exe")

   If $vncversion = $ultimaversion Then
	  _FileWriteLog($logsroute, "vlc actualizado a version " & $ultimaversion & " " & @ComputerName &  @OSArch, 1)
   Else
	  _FileWriteLog($logsroute, "vlc ha fallado al actualizar a version " & $ultimaversion & " " & @ComputerName &  @OSArch, 1)
   EndIf

   SplashOff()


Else
   SplashTextOn("Instalacion de Software", "Se esta instalando VLC, sea paciente." & @CRLF & @CRLF & "Dept. Sistemas." & @CRLF & @CRLF & "La paciencia no es simplemente la capacidad de esperar, es cómo nos comportamos mientras esperamos." & @CRLF &  "Joyce Meyer." , 450, 200, -1, 150, $DLG_TEXTLEFT , "", 12)
   Call("instalar")
   $Vncversion = FileGetVersion($Programfile & "\VideoLAN\VLC\vlc.exe")

   If $vncversion = $ultimaversion Then
	  _FileWriteLog($logsroute, "vlc instalado a version " & $ultimaversion & " " & @ComputerName &  @OSArch, 1)
   Else
	  _FileWriteLog($logsroute, "vlc ha fallado al instalar a version " & $ultimaversion & " " & @ComputerName &  @OSArch, 1)
   EndIf

   SplashOff()

EndIf


   Func instalar()

$ipid = Run(@ComSpec & ' /c  ' & @ScriptDir & '\vlc_' & $ultimaversion & "_" & @OSArch & '.exe /L=3082 /S /NCRC', @TempDir, @SW_HIDE, $STDOUT_CHILD)
ProcessWaitClose($iPID)

EndFunc
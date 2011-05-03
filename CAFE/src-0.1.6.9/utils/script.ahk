;
; AutoHotkey Version: 1.x
; Langage:        Français
; Plateforme:     WinXP
; Auteur:         Yann Perrin <yann.perrin+clef@gmail.com> et Lahire Biette <tuxmouraille@gmail.com>
;
; Utilité du Script :
;	Crée des associations de fichiers temporaires, tant que le script est en cours d'utilisation
;

#NoTrayIcon
#NoEnv
SendMode Input
#SingleInstance, on

;inclusion des fonctions relatives aux chemins de fichiers et à la lecture des fichiers ini
#Include %A_ScriptDir%
#Include ..\library.ahk
#Include ..\cafe_lang.ahk


; defURL = http://download.tuxfamily.org/nomadsofts/C.A.F.E./script

;ajouter un label à la section auto executable permet d'utiliser ce script dans un autre script
scriptIni:
;initialisation
	Process, Priority,,H
	CoordMode, Mouse, Screen
	SetWorkingDir, %A_ScriptDir%
	StringReplace, inifile, A_ScriptName, .ahk, .ini
	StringReplace, inifile, inifile, .exe, .ini
	Loop, %inifile%
		inifile = %A_LoopFileLongPath%

IniRead, scriptpath, %inifile%, GENERAL, scriptpath, script
scriptpath := GetAbsMovPath(scriptpath)

GroupAdd, Interception, ahk_class ExploreWClass,,, Panneau de configuration
GroupAdd, Interception, ahk_class Progman,,, Panneau de configuration
GroupAdd, Interception, ahk_class CabinetWClass,,, Panneau de configuration
Iniread, fenetresAdditionnelles, %inifile%, configuration, fenetresadditionnelles, 0
If fenetresAdditionnelles
	{
	StringSplit, fa, fenetresAdditionnelles, `,, %A_Space%%A_Tab%
	Loop, %fa0%
		{
		fTitle := fa%A_Index%
		GroupAdd, Interception, %fTitle%,,, Panneau de configuration
		}
	}

#IfWinActive, ahk_group Interception
MouseGetPos,,, OutputVarWin
WinGetClass, class, ahk_id %OutputVarWin%
WinGetText, text, ahk_id %OutputVarWin%
StringSplit, OutputArray, text , `r`n
text := OutputArray1
SplitPath, text,,,,, OutDrive
If ( class = "CabinetWClass" and OutDrive = "" )
	return

Menu, script, UseErrorLevel
Menu, script, Add, Utiliser un script, script
Menu, script, Add
CreatescriptMenu(scriptpath,"script")
Menu, script, show
return

script:
return

cpscriptfile:
If ( class = "Progman" )
	{
	EnvGet, wdir, WINDIR
	SplitPath, wdir,,,,, wdirDrive
	SplitPath, A_Desktop,,,,, deskDrive
	If ( wdirDrive != deskDrive )
		{
		MsgBox, 262208, %cafeinfo%, %badDeskPath%
		FileSelectFolder, deskPath, ::{20d04fe0-3aea-1069-a2d8-08002b30309d},, %promtbadDeskPath%
		if not deskPath  ; The user canceled the dialog.
			return
		RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders, Desktop, %deskPath%
		}
	outscriptpath := A_Desktop
	}

If ( class != "Progman" )
	outscriptpath := text

scriptfilename := A_ThisMenuItem

Loop, %scriptpath%\*.*, 1, 1
	{
	SplitPath, A_LoopFileDir, OutDir
	If ( ( OutDir = A_ThisMenu ) and (A_LoopFileName = A_ThisMenuItem ) )
		{
		scriptfile = %A_LoopFileLongPath%
		break
		}
	}

; SplitPath, scriptfile,,, OutExtension, OutNameNoExt

; IfExist, %outscriptpath%\%scriptfilename%
	; {
	; loop
		; {
		; scriptfilename = %OutNameNoExt%%A_Space%(%A_Index%).%OutExtension%
		; IfNotExist, %outscriptpath%\%scriptfile%
			; {
			; break
			; }
		; }
	; }
; FileCopy, %scriptfile%, %outscriptpath%\%scriptfilename%
Run, %scriptfile%,, Hide
return


CreatescriptMenu(scriptpath,MenuName)
{
Loop, %scriptpath%\*.*, 1, 0
	{
	dossier := InStr(FileExist(A_LoopFileLongPath), "D")
	If ( dossier = "1" )
		{
		Menu, %A_LoopFileName%, UseErrorLevel
		CreatescriptMenu(A_LoopFileLongPath,A_LoopFileName)
		Menu, %MenuName%, Add, %A_LoopFileName%, :%A_LoopFileName%
		}
	If ( dossier = "0" )
		{
		Menu, %MenuName%, Add, %A_LoopFileName%, cpscriptfile
		}
	}
}
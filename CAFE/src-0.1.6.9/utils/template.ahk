;
; AutoHotkey Version: 1.x
; Langage:        Français
; Plateforme:     WinXP
; Auteur:         Yann Perrin <yann.perrin+clef@gmail.com> et Lahire Biette <tuxmouraille@gmail.com>
;
; Utilité du Script :
;	Crée des associations de fichiers temporaires, tant que le script est en cours d'utilisation
;


#NoEnv
SendMode Input
#SingleInstance, force
SetBatchLines, -1  ; Make the operation run at maximum speed.

;inclusion des fonctions relatives aux chemins de fichiers et à la lecture des fichiers ini
#Include %A_ScriptDir%
#Include ..\library.ahk
#Include ..\cafe_lang.ahk

defURL = http://download.tuxfamily.org/nomadsofts/C.A.F.E./template

;ajouter un label à la section auto executable permet d'utiliser ce script dans un autre script
TemplateIni:
;initialisation
	Process, Priority,,H
	CoordMode, Mouse, Screen
	SetWorkingDir,%A_ScriptDir%
	StringReplace, inifile, A_ScriptName, .ahk, .ini
	StringReplace, inifile, inifile, .exe, .ini
	Loop, %inifile%
		inifile = %A_LoopFileLongPath%

IniRead, templatepath, %inifile%, GENERAL, templatepath, template
templatepath := GetAbsMovPath(A_ScriptDir,templatepath)

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

Menu, template, UseErrorLevel
Menu, template, Add, A partir d'un model, template
Menu, template, Add
CreateTemplateMenu(templatepath,"template")
Menu, template, show
return

template:
return

cptemplatefile:
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
	outtemplatepath := A_Desktop
	}

If ( class != "Progman" )
	outtemplatepath := text

templatefilename := A_ThisMenuItem

Loop, %templatepath%\*.*, 1, 1
	{
	If ( A_ThisMenu = "template" )
		OutDir := templatepath
	If ( A_ThisMenu != "template" )
		SplitPath, A_LoopFileDir, OutDir
	If ((( OutDir = A_ThisMenu ) and (A_LoopFileName = A_ThisMenuItem ) ) or ( ( OutDir = templatepath ) and (A_LoopFileName = A_ThisMenuItem )))
		{
		templatefile = %A_LoopFileLongPath%
		break
		}
	}

SplitPath, templatefile,,, OutExtension, OutNameNoExt

IfExist, %outtemplatepath%\%templatefilename%
	{
	loop
		{
		templatefilename = %OutNameNoExt%%A_Space%(%A_Index%).%OutExtension%
		IfNotExist, %outtemplatepath%\%templatefile%
			{
			break
			}
		}
	}
FileCopy, %templatefile%, %outtemplatepath%\%templatefilename%
return


CreateTemplateMenu(templatepath,MenuName)
{
Loop, %templatepath%\*.*, 1, 0
	{
	dossier := InStr(FileExist(A_LoopFileLongPath), "D")
	If ( dossier = "1" )
		{
		Menu, %A_LoopFileName%, UseErrorLevel
		CreateTemplateMenu(A_LoopFileLongPath,A_LoopFileName)
		Menu, %MenuName%, Add, %A_LoopFileName%, :%A_LoopFileName%
		}
	If ( dossier = "0" )
		{
		Menu, %MenuName%, Add, %A_LoopFileName%, cptemplatefile
		}
	}
}
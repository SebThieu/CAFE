;
; AutoHotkey Version: 1.x
; Langage:        Français
; Plateforme:     WinXP
; Auteurs:        Yann Perrin <yann.perrin+clef@gmail.com> et Lahire Biette <tuxmouraille@gmail.com>
;
; Utilité du Script :
;   Reproduit la fonction "Executer" de Windows en privilégiant les programmes présents sur le même support
;   Ouvre les fichiers selon les associations définies par C.A.F.E. si il est disponible
;   Utilisable en ligne de commande
;
#notrayicon
#singleinstance force
#Include %A_ScriptDir%
#Include ..\library.ahk
#Include ..\cafe_lang.ahk
fichierIntrouvable = le fichier spécifié est introuvable.
SetWorkingDir,%A_ScriptDir%
StringReplace, sucreinifile, A_ScriptFullPath, .ahk, .ini
StringReplace, sucreinifile, sucreinifile, .exe, .ini
IniRead, CWD, %sucreinifile%, configuration, dossiercafe, %A_ScriptDir%
SetWorkingDir, %CWD%
inifile = cafe.ini
Loop, %inifile%
inifile = %A_LoopFileLongPath% ;récupération du chemin complet de cafe.ini
Loop, %inifile%
CWD = %A_LoopFileDir% ;récupération du chemin complet du dossier de Café

if 0<1
{
	IniRead, Mode, %sucreinifile%, configuration, mode, 1
	;interface graphique
	Gui, Add, GroupBox, x6 y0 w360 h80 , Exécuter
	Gui, Add, Edit, x16 y20 w250 h20 vselectedapp gselection, ; la barre affichant le chemin vers le paquet
	Gui, Add, Button, x276 y20 w35 h20 gopen, ...
	Gui, Add, Button, x321 y20 w35 h20 vraccourci graccourci disabled, +>
	Gui, Add, Button, x276 y50 w80 h20 gGuiexecute, Exécuter
	IfExist, %inifile% ; ajout d'un bouton permettant l'utilisation des associations alternatives si cafe.ini est trouvé
	Gui, Add, Button, x186 y50 w80 h20 , Alternatif
	Gui, Add, DropDownList, x16 y50 w160 h20 Choose%Mode% r3 AltSubmit vMode gSucreChangeMode, garder au premier plan|réduire après usage|fermer après usage
	; Generated using SmartGUI Creator 4.0
	Gui, Show,h87 w372, S.U.C.R.E. | Exécuter
	If Mode=1
		Gui, +AlwaysOnTop
}
else
{
	; usage en ligne de commande
	; sous la forme :
	; sucre.exe [fichier 1] [fichier ...] [fichier n]
	; si un des nom de fichier est remplacé par alternative, les suivants utiliseront les associations alternatives
	section:="associations"
	Loop, %0%
	{
		appselected := %A_Index%
		if appselected = -alternative
			section:="alternative"
			
;~ 		If ( appselected = "-openwith" )
;~ 		{
;~ 			FileSelectFile, prog, 3, %appspath%, Ouvrir "%OutThisFileName%" avec:, %typeapplication% (*.exe`;*.cmd`;*.bat)
;~ 			SplitPath, filename,, thisworkingdir
;~ 			Run, "%prog%" "%filename%", %thisworkingdir%,UseErrorLevel
;~ 		}
			
		else
			Gosub execute
	}
	ExitApp
}
Return

open:
FileSelectFile, appselected, 3, ,, Tous les fichiers (*.*)
GuiControl,, selectedapp, %appselected%
return

selection:
	GuiControlGet, appselected,, selectedapp
	If appselected
		GuiControl, enable, raccourci
	else
		GuiControl, disable, raccourci
return

raccourci:
	Gui, +OwnDialogs
	GuiControlGet, appselected,, selectedapp
	appselected:=GetRelativePath(inifile,appselected)
	msg = Entrez un mot-clef pour :`n %appselected%
	InputBox, raccourci, S.U.C.R.E. | Mot-Clef, %msg%,,,132
	If raccourci and not ErrorLevel
		IniWrite, %appselected%, %sucreinifile%, Raccourcis, %raccourci%
return

#IfWinActive, S.U.C.R.E. | Exécuter
Enter::
NumpadEnter::
Guiexecute:
	GuiControlGet, appselected,, selectedapp
	section:="associations"
	execute:
	SetWorkingDir, %CWD%
	IniRead, appselected, %sucreinifile%, Raccourcis, %appselected% , %appselected%
	Loop, %appselected%
		appselected = %A_LoopFileLongPath%
	SplitPath, A_ScriptDir,,,,,lecteur
	lecteur = %lecteur%\
	SetWorkingDir, %lecteur%
	trouve = 0
	Loop, %appselected%, 1, 1
		{
		If (A_LoopFileName = appselected)
			{
			trouve = 1
			filename = %A_LoopFileLongPath%
			Gosub SucreAction
			Break
			}
		}
	If not trouve
		{
		filename = %appselected%
		Gosub SucreAction
		If ErrorLevel
		MsgBox, %fichierIntrouvable%
		}
	If 0=0
		{
		If Mode=2
			Gui, Minimize
		If Mode=3
			Gosub, GuiClose
		}
return

!Enter::
!NumpadEnter::
GuiAltExecute:
	GuiControlGet, appselected,, selectedapp
	section:="alternative"
	Gosub, execute
return

SucreAction:
	SetWorkingDir, %CWD%
	IfNotExist, %inifile%
	{
		Run, "%filename%",,UseErrorLevel
		return
	}
	;si le fichier est un raccourci, on en cherche la cible
	SplitPath, filename,,, extension
	IfEqual extension, lnk
	FileGetShortcut, %filename%, filename
	;on vérifie à quel programme il est associé
	SplitPath, filename ,,, extension
	IniRead, prog, %inifile%, %section%, %extension%, host
	;si il s'agit d'un fichier url, on récupère l'url en question
	IfEqual extension, url
		IniRead, filename, %filename%, InternetShortcut, URL
	dossier := InStr(FileExist(filename), "D")
	progInexistant =
	(
	Le programme %prog%
	designé pour ouvrir les fichiers %extension%
	dans %inifile% est introuvable.
	Pensez à mettre %inifile% à jour
	)

	If (prog = "host" or dossier)
	{
		Run, "%filename%",,UseErrorLevel
	}

	Else If ( prog != "host" and prog != "ask")
	{
		prog:=GetAbsMovPath(A_ScriptDir,prog)
		SplitPath, filename,, thisworkingdir
		Run, "%prog%" "%filename%", %thisworkingdir%,UseErrorLevel

		If (ErrorLevel = "ERROR")
		{
			MsgBox,, SUCRE | ERREUR, %logicielintrouvable%`n`n"%prog%" "%filename%"
			Run, "%filename%",,UseErrorLevel
		}
	}
return

SucreChangeMode:
	GuiControlGet, Mode,, Mode
	If Mode=1
		Gui, +AlwaysOnTop
	Else
		Gui, -AlwaysOnTop
	IniWrite, %Mode%, %sucreinifile%, configuration, mode
return

~Esc & s::
GuiClose:
ExitApp
/*
AutoHotkey Version: 0.1.6.9
Langage:        Fran�ais
Plateforme:     WinXP
Auteur:         Yann Perrin <yann.perrin+clef@gmail.com> original coder
		  Lahire Biette <tuxmouraille@gmail.com> now coder
		  enigmatick add context menu fonction
		  Zachary Hudock <zrhudock@adelphia.net> and Brian All <brianallb23@gmail.com> add windows configuration (window_conf.ahk)

Utilit� du Script :
	Cr�e des associations de fichiers temporaires, tant que le script est en cours d'utilisation

Purpose of CAFE:
	Create temporary file associations for portable applications.
*/

#NoEnv
SendMode Input
#SingleInstance, force
#InstallKeybdHook
;~ #UseHook On
;si on lance le logiciel avec le param�tre /exit, il s'arr�te
IfEqual, 1, /exit
	ExitApp
;si on le lance avec le param�tre /cafeupdated, il efface le programme de mise � jour
;~ IfEqual, 1, /cafeupdated
;~ 	FileDelete, cafeUpdater.exe

;inclusion des fonctions relatives aux chemins de fichiers et � la lecture des fichiers ini
#Include %A_ScriptDir%
#Include library.ahk
#Include cafe_library.ahk
#Include info.ahk

;initialisation
	Process, Priority,,H
	CoordMode,Mouse,Screen
	SetWorkingDir,%A_ScriptDir%
	StringReplace, inifile, A_ScriptName, .ahk, .ini
	StringReplace, inifile, inifile, .exe, .ini
	Loop, %inifile%
		inifile = %A_LoopFileLongPath%
	firstClick := 0

#Include cafe_lang.ahk

;~ #################################################################################
;~ #################################################################################
;~ #################################################################################
; lecture des valeurs � ajouter � la variable d'environement (locale) PATH 
; uniquement pour C.A.F.E. et les aplications qu'il lance
IniRead, var, %inifile%, configuration, PATH
If ( var != "ERROR" and var != "" )
{
	var:=GetAbsMovPath(A_ScriptDir,var)
	EnvGet, path, PATH
	Loop, Parse, var, `,
	{
		n = 0
		this = %A_LoopField%
		Loop, Parse, path, `,
		{
			If ( this = A_LoopField )
				n = 1
		}
		
		If ( n = "0" )
			path = %path%;%A_LoopField%
	}
	EnvSet, PATH, %path%
}

IniRead, var, %inifile%, configuration, USERPROFILE
If ( var != "ERROR" and var != "" )
{
	var:=GetAbsMovPath(A_ScriptDir,var)
	EnvSet, USERPROFILE, %var%
}

IniRead, var, %inifile%, configuration, APPDATA
If ( var != "ERROR" and var != "" )
{
	var:=GetAbsMovPath(A_ScriptDir,var)
	EnvSet, APPDATA, %var%
}

IniRead, var, %inifile%, configuration, HOMEDRIVE
If ( var != "ERROR" and var != "" )
{
	var:=GetAbsMovPath(A_ScriptDir,var)
	EnvSet, HOMEDRIVE, %var%
}

IniRead, var, %inifile%, configuration, HOMEPATH
If ( var != "ERROR" and var != "" )
{
	EnvSet, HOMEPATH, %var%
}
;~ #################################################################################
;~ #################################################################################
;~ #################################################################################


;~ =============================================================
; lecture du chemin vers le dossiers des applications
;~ here we read the apps path forlder
;~ =============================================================
IniRead, appspath, %inifile%, configuration, appspath, %A_ScriptDir%
	appspath:=GetAbsMovPath(A_ScriptDir,appspath)

;~ =============================================================
;~ WHERE WE DEFINE THE DEFAULT VALUE FOR PAUSE VARIABLES
;~ =============================================================
IniRead, _pause_menu, %inifile%, configuration, Menu_Start_Pause, 0
If ( _pause_menu = "" )
	_pause_menu = 0

IniRead, _pause_hk, %inifile%, configuration, HK_Start_Pause, 0
If ( _pause_hk = "" )
	_pause_hk = 0

IniRead, _pause_fs, %inifile%, configuration, FS_Start_Pause, 0
If ( _pause_fs = "" )
	_pause_fs = 0

;~ =============================================================
; on cr�e la liste des fichiers de configuration
;~ =============================================================
	SplitPath, inifile, inilist
	ThisMenuList = TRAY|CONTEXT|CONTEXT2
	loop, Parse, ThisMenuList, |
	{
		Loop
		{
			IniRead, thisfile, %inifile%, %A_LoopField%, file-%A_Index%
			If (thisfile = "" or thisfile = "ERROR")
				break
			thisfile = %thisfile%.ini
			IfNotInString, inilist, %thisfile%
			{
				inilist = %inilist%`n%thisfile%
			}
		}
	}

;mise en place de la vitesse de double-clic personnalis�e
	initialDblClickSpeed := DllCall("GetDoubleClickTime")
	IniRead, dblClickSpeed, %inifile%, configuration, doubleclic, %initialDblClickSpeed%
	If (dblClickSpeed != initialDblClickSpeed)
		DllCall("SetDoubleClickTime", Int, dblClickSpeed)
	OnExit, Fin
;r�cup�ration des informations concernant la position de la souris lors d'un double-clic
	SysGet, XDblClickDiff, 36
	SysGet, YDblClickDiff, 37
;cr�ation du menu
	If A_IsCompiled
		Menu, tray, NoStandard
	
	; les entr�s pour les informations
;~ 	FileInstall, instructions.txt,instructions.txt
;~ 	AjoutInfo("instructions.txt")
;~ 	FileInstall, README.html,README.html
;~ 	AjoutInfo("README.html")
	FileInstall, license.txt,license.txt
	AjoutInfo("license.txt")
	FileInstall, about.txt,about.txt
	AjoutInfo("about.txt")
	
	Loop, %lngdir%\*.lng
	{
		nbfichier = %A_Index%
		StringReplace, langue, A_LoopFileName, .lng
		Menu, langues, Add, %langue%, Lng
		if (A_LoopFileLongPath=lng)
			Menu, langues, Check, %langue%
	}
	If nbfichier
		Menu, pref, Add, %langage%, :langues
	Menu, pref, Add, %autoassoc%, AutoAsso

;~ 	where we creat the menu item and hotkey to open ConfigMouseGUI
	IniRead, hk, %inifile%, configuration, HK_MouseConf, Win+M
	If ( hk = "" )
		hk  = Win+M
	Menu, pref, Add, %dblclickset%`t(%hk%), ConfigSouris
	hk:=HK_Cafe2AHK(hk)
	HotKey, %hk%, ConfigSouris
	
;~ 	where we creat the menu item and hotkey to open ConfigFileAssociationsGUI
	IniRead, hk, %inifile%, configuration, HK_AssoConf, Win+X
	If ( hk = "" )
		hk  = Win+X
	Menu, pref, Add, %configassoc%`t(%hk%), CafeConf
	hk:=HK_Cafe2AHK(hk)
	HotKey, %hk%, CafeConf

;~ 	where we creat the menu item and hotkey to open ConfigMouseGUI
	IniRead, hk, %inifile%, configuration, HK_AppsConf, Win+A
	If ( hk = "" )
		hk  = Win+A
	Menu, pref, Add, %configapplis%`t(%hk%), CafeConfApps
	hk:=HK_Cafe2AHK(hk)
	HotKey, %hk%, CafeConfApps

;~ 	where we creat the menu item and hotkey to open ConfigHotKeyGUI
	IniRead, hk, %inifile%, configuration, HK_HKConf, Win+H
	If ( hk = "" )
		hk  = Win+H
	Menu, pref, Add, %confighotkeys%`t(%hk%), CafeConfHK
	hk:=HK_Cafe2AHK(hk)
	HotKey, %hk%, CafeConfHK

;~ 	where we creat the menu item and hotkey to open ConfigWindowAddedGUI
	IniRead, hk, %inifile%, configuration, HK_WinConf, Win+W
	If ( hk = "" )
		hk  = Win+W
	Menu, pref, Add, %configwinds%`t(%hk%), CafeConfWindows
	hk:=HK_Cafe2AHK(hk)
	HotKey, %hk%, CafeConfWindows

	; le sous menu pour �diter les fichiers de configuration
	Menu, fileconfiguration, Add, %ttconfedit%, CafeEdit
	Menu, fileconfiguration, Add
	Loop, Parse, inilist, `n
		{
		name = %A_LoopField%
		Menu, fileconfiguration, Add, %name%, CafeEdit
		}
	Menu, pref, Add, %confedit%, :fileconfiguration
	Menu, tray, Add, %pref%, :pref
	Menu, tray, Add

	;~ =============================================================
	; where we make the town context menus, and we add items to the tray menu
	; ici on ajoute au tray menu les entr�es suppl�m�ntaires et on cr� les menus contextuels.
	;~ =============================================================
	ThisMenuList = TRAY|CONTEXT|CONTEXT2
	loop, Parse, ThisMenuList, |
	{
		This_Section := A_LoopField
		loop
		{
			iffileexist2:
			IniRead, contextfile, %inifile%, %This_Section%, file-%a_index%
			If ( contextfile = "" or contextfile = "ERROR" )
				break
			
			contextfile := A_ScriptDir . "\" . contextfile . ".ini"
			
			IfNotExist, %contextfile%
			{
				SplitPath, contextfile,,,,contextfile
				StringReplace, nocontextfile1, nocontextfile, $contextfile, %contextfile%, All
				MsgBox, 262166, %CAFEERREUR%, %nocontextfile1%
				
				IfMsgBox, Cancel
					ExitApp
				IfMsgBox, TryAgain
					Goto, iffileexist2
				IfMsgBox, Continue
					continue
			}
			
			else
			{
				Menu, %This_Section%, UseErrorLevel
				Cafe_Menu:=CreateContext(contextfile,This_Section,Cafe_Menu)
			}
		}
	}

;~ 	where we creat the menu item and hotkey to relaunch CAFE
	IniRead, hk, %inifile%, configuration, HK_Reload, Win+R	
	If ( hk = "" )
		hk  = Win+R
	Menu, tray, Add, %relaneccafe%`t(%hk%), relancer
	hk:=HK_Cafe2AHK(hk)
	HotKey, %hk%, relancer

;~ 	where we creat the menu item and hotkey to file associaton fonction
	IniRead, hk, %inifile%, configuration, HK_FS_Pause, Win+Alt+F	
	If ( hk = "" )
		hk  = Win+Alt+F
	fs_pause_item = %fs_pause_item%`t(%hk%)
	Menu, tray, Add, %fs_pause_item%, FS_Pause
	If ( _pause_fs = "1" or _pause_fs = "true" )
		Menu, tray, ToggleCheck, %fs_pause_item%
	hk:=HK_Cafe2AHK(hk)
	HotKey, %hk%, FS_Pause

;~ 	where we creat the menu item and hotkey to context menu fonction
	IniRead, hk, %inifile%, configuration, HK_Menu_Pause, Win+Alt+M
	If ( hk = "" )
		hk  = Win+Alt+M
	menu_pause_item = %menu_pause_item%`t(%hk%)
	Menu, tray, Add, %menu_pause_item%, Menu_Pause
	If ( _pause_menu = "1" or _pause_menu = "true" )
		Menu, tray, ToggleCheck, %menu_pause_item%
	hk:=HK_Cafe2AHK(hk)
	HotKey, %hk%, Menu_Pause

;~ 	where we create the menu item and hotkey to file associaton fonction
	IniRead, hk, %inifile%, configuration, HK_HotKey_Pause, Win+Alt+H
	If ( hk = "" )
		hk  = Win+Alt+H
	hk_pause_item = %hk_pause_item%`t(%hk%)
	Menu, tray, Add, %hk_pause_item%, HK_Pause
	If ( _pause_hk = "1" or _pause_hk = "true" )
		Menu, tray, ToggleCheck,  %hk_pause_item%
	hk:=HK_Cafe2AHK(hk)
	HotKey, %hk%, HK_Pause

	IniRead, hk, %inifile%, configuration, HK_Pause, Win+P
	If ( hk = "" )
		hk = Win+P
	Menu, tray, Add, %pause%`t(%hk%), Suspension
	Menu, tray, Default, %pause%`t(%hk%)
	hk:=HK_Cafe2AHK(hk)
	HotKey, %hk%, Suspension

;~ 	where we creat the menu item and hotkey to quit CAFE
	IniRead, hk, %inifile%, configuration, HK_Quit, Esc+C
	If ( hk = "" )
		hk = Esc+C
	Menu, tray, Add, %quit%`t(%hk%), Fin
	hk:=HK_Cafe2AHK(hk)
	HotKey, %hk%, Fin

	Menu, tray, Tip, C.A.F.E.
	Iniread, auto, %inifile%, configuration, auto, 0
	If auto
		Menu, pref, Check, %autoassoc%
;~ d�marrage en pausec
	IfEqual, 1, /pause
		Gosub, Suspension

	GroupAdd, Interception, ahk_class ExploreWClass
	GroupAdd, Interception, ahk_class Progman
	GroupAdd, Interception, ahk_class CabinetWClass
	GroupAdd, Interception, ahk_class WorkerW
	Iniread, fenetresAdditionnelles, %inifile%, configuration, fenetresadditionnelles, 0
	If fenetresAdditionnelles
	{
		Loop, Parse, fenetresAdditionnelles, |, %A_Space%%A_Tab%
			GroupAdd, Interception, %A_LoopField%
	}

; o� on cr�e les groupes de fen�tres
list := GetIniSectionListKey(inifile,"GROUP")
Loop, Parse, list, |
	{
	Group_Name := A_LoopField
	IniRead, grouplist, %inifile%, GROUP, %Group_Name%
	StringSplit, ga, grouplist, `,, %A_Space%%A_Tab%
	Loop, %ga0%
		{
		gTitle := ga%A_Index%
;~ 		GroupAdd, %Group_Name%, %gTitle%,,, Panneau de configuration
		GroupAdd, %Group_Name%, %gTitle%
		}
	}

;~ =============================================================
;~ WHERE WE ADD USER'S HOTKEYS
;~ =============================================================
; o� on ajoute nos propres raccourcis clavier
list := GetIniSectionListKey(inifile,"HOTKEY")
Loop, Parse, list, |
{
	
	hk = %A_LoopField%
	
	IniRead, cmd, %inifile%, HOTKEY, %hk%
	StringSplit, array, cmd, ~
	
	; cette fonction sert � convetir les codes des raccourcis clavier 
	; dans le fichier deconfiguration, o� ils sont compr�hensibles par l'utilisateur
	;  en code AHK
	hk:=HK_Cafe2AHK(hk)
	
	If ( array3 != "" )
	{
		Hotkey, IfWinActive, %array3%
		HotKey, %hk%, HKAction
	}

	If ( array3 = "" )
	{
		HotKey, %hk%, HKAction
	}
}


;~ =============================================================
;~ raccourcis pour le menu contextuel
IniRead, var, %inifile%, configuration, Use_Middle_Click
If ( var = "1" )
{
	Hotkey, IfWinActive, ahk_group Interception
	HotKey, ~MButton, Bouton_Milieu
}

IniRead, var, %inifile%, configuration, Use_Win_Right_Click
If ( var = "1" )
{
	Hotkey, IfWinActive, ahk_group Interception
	HotKey, ~RButton, Bouton_Droit
}

IniRead, var, %inifile%, configuration, Use_Double_Right_Click
If ( var = "1" )
{
	Hotkey, IfWinActive, ahk_group Interception
	HotKey, ~#RButton, Win_Bouton_Droit
}
;~ =============================================================


;~ =============================================================
;~ raccourcis pour la s�lection de la fen�tre � ajouter
	Hotkey, IfWinExist, %wintitlegui%
	Hotkey, +#Lbutton, selwin
;~ =============================================================


;~ =============================================================
;~ WHERE WE CHECK A MAYBE COMMAND LINE ARGUMENT
;~ will be delete when the Gui will be separated to the deamon
;~ =============================================================�
; le param�tre /appsconf ouvre la fen�re de configuration des apps
IfEqual, 1, /appsconf
	GoSub, CafeConfApps

; le param�tre /extsconf ouvre la fen�re de configuration des extensions
IfEqual, 1, /extsconf
	GoSub, CafeConf

;si on le lance avec le param�tre /mouseconf,  on ouvre la fen�re de conf de la souris
IfEqual, 1, /mouseconf
	GoSub, ConfigSouris

;si on le lance avec le param�tre /hkconf,  on ouvre la fen�re de conf des raccourcis
IfEqual, 1, /hkconf
	GoSub, HK_Gui

;si on le lance avec le param�tre /hkconf,  on ouvre la fen�re de conf des fen�tres additionnelles
IfEqual, 1, /winconf
	GoSub, CafeConfWindows
;~ =============================================================


;~ =============================================================
;~ WHERE WE SHOW THE BALLON TOOL TIP TO SHOW CAFE IS READE TO BE USE
;~ =============================================================
; on affiche le ballon tool tip qui indique que cafe � finit de se charger en m�moire 
TrayTip, %cafeoperationel%, %utilisationpossible%,, 1
;~ =============================================================

Return



;~ =============================================================
;~ WHERE WE LAUNCH THE CONFIGURED COMMAND FOR THE USED HOTKEY
;~ =============================================================
; o� on lance la commande associ�e au raccourcis clavier
HKAction:
hk = %A_ThisHOTKEY%
If ( _pause_hk = "1" )
	{
	Send, {%hk%}
	return
	}

; cette fonction sert � convertir les codes AHK des raccourcis clavier en codes
; du fichier deconfiguration, compr�hensibles par l'utilisateur
hk:=HK_AHK2Cafe(hk)

IniRead, cmd, %inifile%, HOTKEY, %hk%

StringSplit, array, cmd, ~

If ( array2 != "" )
	{
	cmd = %array1%
	}

cmd:=GetAbsMovPath(A_ScriptDir,cmd)

Run, %cmd%,,UseErrorLevel

If (ErrorLevel = "ERROR")
	{
	StringReplace, logicielintrouvable21, logicielintrouvable2, $hk, %hk%
	StringReplace, logicielintrouvable21, logicielintrouvable21, $inifile, %inifile%
	StringReplace, logicielintrouvable21, logicielintrouvable21, $cmd, %cmd%
	MsgBox, 262192, %cafeerreur%, %logicielintrouvable21%
	}
Return
;~ =============================================================


;~ =============================================================
;~ WHERE WE ACT FOR THE SELECTIVES PAUSES
;~ =============================================================
FS_Pause:
Menu, tray, ToggleCheck, %fs_pause_item%
If ( _pause_fs = "0")
	{
	_pause_fs = 1
	TrayTip,,  %fs_pause_msg_1%
	Return
	}
If ( _pause_fs = "1")
	{
	_pause_fs = 0
	TrayTip,,  %fs_pause_msg_0%
	Return
	}
Return
	
Menu_Pause:
Menu, tray, ToggleCheck, %menu_pause_item%
If ( _pause_menu = "0")
	{
	_pause_menu = 1
	TrayTip,,  %menu_pause_msg_1%
	Return
	}
If ( _pause_menu = "1")
	{
	_pause_menu = 0
	TrayTip,,  %menu_pause_msg_0%
	Return
	}
Return

HK_Pause:
Menu, tray, ToggleCheck, %hk_pause_item%
If ( _pause_hk = "0")
	{
	_pause_hk = 1
	TrayTip,,  %hk_pause_msg_1%
	Return
	}
If ( _pause_hk = "1")
	{
	_pause_hk = 0
	TrayTip,,  %hk_pause_msg_0%
	Return
	}
Return
;~ =============================================================


ContextAction:
Loop, Parse, Cafe_Menu, `r`n
{
	StringSplit, menu, A_LoopField, ~
	If ( ( menu1 = A_ThisMenu ) and ( menu2 = A_ThisMenuItem ) )
	{
		CafeExecStr = %menu3%
		Break
	}
}
	StringReplace, CafeExecStr, CafeExecStr, $F, %f%, All
	StringReplace, CafeExecStr, CafeExecStr, $P, %filedir%, All
	StringReplace, CafeExecStr, CafeExecStr, $E, %filetruncatedname%, All

	If (filedir = "FolderView")
		filedir = %A_Desktop%
	
	IfInString, CafeExecStr, *hide*
	{
		StringReplace, CafeExecStr, CafeExecStr, %A_Space%*hide*,, All
		Run, %CafeExecStr%, %filedir%, Hide UseErrorLevel
;~ 		Msgbox, Run, %CafeExecStr%, %filedir%, Hide
	}
	Else
	{
		Run, %CafeExecStr%, %filedir%,UseErrorLevel
;~ 		MsgBox, Run, %CafeExecStr%, %filedir%
	}

	If (ErrorLevel = "ERROR")
	{
		MsgBox,, %cafeerreur%, %logicielintrouvable3%
	}


Return

;~ =============================================================
;mise en place des raccourcis sp�cifiques
;~ =============================================================
#IfWinActive, ahk_group Interception
Lbutton::
	If ( _pause_fs = "1" )
	{
;~ 		Send, {Lbutton}
		Send, {Click}
		Return
	}
	section := "associations"
 	Gosub, CafeVerifDoubleClic
return

!Lbutton::
	If ( _pause_fs = "1" )
	{
;~ 		Send, {!Lbutton}
		Send, {Alt}{Click}
 		return
	}
	section := "alternative"
	Gosub, CafeVerifDoubleClic
return

Lbutton UP::
	Click up
return

#Lbutton::
	section := "associations"
	Gosub, CafeAssoc
return

!#Lbutton::
	section := "alternative"
	Gosub, CafeAssoc
return

Enter::
	If ( _pause_fs = "1" )
	{
		Send, {Enter}	
		return
	}
NumpadEnter::
	If ( _pause_fs = "1" )
	{
		Send, {NumpadEnter}
		return
	}
	section := "associations"
	nonInterception = CafeEnter
	Gosub, CafeAction
return

!Enter::
	If ( _pause_fs = "1" )
	{
		Send, {!Enter}	
		return
	}

!NumpadEnter::
	If ( _pause_fs = "1" )
	{
		Send, {!NumpadEnter}	
		return
	}
	section := "alternative"
	nonInterception = CafeAltEnter
	Gosub, CafeAction
return


;~ =============================================================
;~ interception des actions qui permettent d'afficher le menu contextuel de CAFE
;~ =============================================================
;~ ~RButton::
Bouton_Droit:
; pour le pause selective du menu contextuel
;~ If ( _pause_menu = "1" or _d_r_click != "1"  )
If ( _pause_menu = "1" )
{
	Send, {~RButton}
	return
}

; If (A_PriorHotKey = A_ThisHotKey and A_TimeSincePriorHotkey < 500)
If (A_PriorHotKey = A_ThisHotKey and A_TimeSincePriorHotkey < dblClickSpeed )
	{ ; d�tection sommaire d'un double-clic droit, il faudrait remplacer 500 par le temps de double-clic syst�me.
	KeyWait, RButton  ; on attend que le bouton droit soit relach�, ce qui d�clenche g�n�ralement l'ouverture du menu contextuel
	WinWait, ahk_class #32768, , 1  ; on attend que le menu contextuel apparaisse
	if not ErrorLevel  ; et si il est trouv�, on le ferme.
		Send {Escape}
	f:=GetFileName()
	GoSub, Next
	}
Return


;~ ~#RButton::
Win_Bouton_Droit:
;~ If ( _pause_menu = "1" or _w_r_click != "1" )
If ( _pause_menu = "1" )
{
	Send, {~#RButton}
	Return
}

KeyWait, RButton  ; on attend que le bouton droit soit relach�, ce qui d�clenche g�n�ralement l'ouverture du menu contextuel
WinWait, ahk_class #32768, , 1  ; on attend que le menu contextuel apparaisse
if not ErrorLevel  ; et si il est trouv�, on le ferme.
	Send {Escape}
f:=GetFileName()
Gosub, Next
Return


;~ ~MButton::
Bouton_Milieu:
;~ If ( _pause_menu = "1" or _m_click != "1" )
If ( _pause_menu = "1" )
{
	Send, {MButton}
	Return
}

f:=GetFileName()
StringSplit, OutputArray, f, `r`n
If ( OutputArray0 = "1" ) or ( f = "")
{
;~ 	Send {LButton down}
	Send {Click Down}
	KeyWait, MButton, U
;~ 	Send {LButton up}
	Send {Click Up}
	f:=GetFileName()
}

Gosub, Next
Return

Next:
	outfilename =
	filedir =
	extension =
	filetruncatedname =

;et je montre et grise les menu en fonction de la selection
If ( f != "")
{
	StringSplit, OutputArray, f, `r`n
	If ( OutputArray0 > "1" )
	{
		SplitPath, OutputArray1 , outfilename, filedir, extension, filetruncatedname
		StringReplace, f, f, `r`n, `"%A_Space%`", All
		Loop, Parse, Cafe_Menu, `r`n
		{
			StringSplit, menu, A_LoopField, ~
			If ( menu4 = "" or menu4 = ".*" or menu4 = "\" or menu4 = "\|.*" or menu4 = ".*|\" )
				Menu, %menu1%, Enable, %menu2%
			Else If ( menu4 != "" )
				Menu, %menu1%, Disable, %menu2%
		}
	}
	
	Else If ( OutputArray0 = "1" )
;~ 	Else If ( OutputArray0 != "0" )
	{
		; si le fichier est un raccourci, on en cherche la cible
		SplitPath, f , outfilename, filedir, extension, filetruncatedname
		IfEqual extension, lnk
		{
			FileGetShortcut, %f%, f
			SplitPath, f , outfilename, filedir, extension, filetruncatedname
		}

		dossier := InStr(FileExist(f), "D")		
		If ( dossier = "1" )
		{
			filetruncatedname = %outfilename%
			
			Loop, Parse, Cafe_Menu, `r`n
			{
				StringSplit, menu, A_LoopField, ~
				If ( menu4 = "" )
					Menu, %menu1%, Enable, %menu2%
				Else IfInString, menu4, \
					Menu, %menu1%, Enable, %menu2%
				Else
					Menu, %menu1%, Disable, %menu2%
			}
		}
		
		Else
		{
			Loop, Parse, Cafe_Menu, `r`n
			{
				StringSplit, menu, A_LoopField, ~
				If ( menu4 = "" )
					Menu, %menu1%, Enable, %menu2%
				Else IfInString, menu4, .*
					Menu, %menu1%, Enable, %menu2%
				Else IfInString, menu4, %extension%
					Menu, %menu1%, Enable, %menu2%
				Else
					Menu, %menu1%, Disable, %menu2%
			}
		}
	}
	Menu, context, show
}

Else If ( f = "")
{
	text =
	OutputVarWin =
	IfWinActive, ahk_group Interception
	{
		MouseGetPos,,, OutputVarWin
		WinGetClass, class, ahk_id %OutputVarWin%
		WinGetText, text, ahk_id %OutputVarWin%
		StringSplit, OutputArray, text , `r`n
		filedir := OutputArray1
	}

	Menu, context2, show
}
Return

;mise en place des raccourcis g�n�raux
#IfWinActive
~LButton::
~!LButton::
	MouseGetPos, X, Y
	PriorX = %X%
	PriorY = %Y%
	firstClick := A_TickCount
return

;~ section des raccourcis en dure que je doit changer
relancer:
; Gosub GuiDestroyAll
reload
return

; editer les associations
;~ #x::
CafeConf:
Gosub GuiDestroyAll
#Include cafe_ext_conf.ahk
return

; editer les applications
;~ #a::
CafeConfApps:
Gosub GuiDestroyAll
#Include cafe_apps_conf.ahk
return

;~ #w::
CafeConfWindows:
Gosub GuiDestroyAll
#Include cafe_window_conf.ahk
Return

;~ #h::
CafeConfHK:
Gosub GuiDestroyAll
#Include cafe_hk_conf.ahk
return
;~ =============================================================
;~ fin de la section des raccourcis en dure
;~ =============================================================


;~ =============================================================
;labels correspondant aux entr�es du menu
;~ =============================================================
AutoAsso:
	Menu, pref, ToggleCheck, %autoassoc%
	Iniread, auto, %inifile%, configuration, auto, 0
	If auto
		IniDelete, %inifile%, configuration, auto
	Else
		IniWrite, 1, %inifile%, configuration, auto
return

;choix du langage
Lng:
	lngfile = %lngdir%\%A_ThisMenuItem%.lng
	Iniwrite, %lngfile%, %inifile%, configuration, langue
	Reload
return

; editer le fichier des associations
CafeEdit:
	If ( A_ThisMenuItem = ttconfedit )
		showthis := inilist
	If ( A_ThisMenuItem != ttconfedit )
		showthis := A_ThisMenuItem
	
	IniRead, prog, %inifile%, associations, ini, host
	If (prog = "host"or prog = "" or prog = "ERROR")
		{
		Loop, Parse, showthis, `n
			{
			Run, "%A_LoopField%",,UseErrorLevel
			}
		}
	Else
		{
		prog:=GetAbsMovPath(A_ScriptDir,prog)
		IfExist, %prog%
			{
			Run, "%prog%" "%showthis%",,UseErrorLevel
			}
		Else
			{
			StringReplace, progInexistant1, progInexistant, ``n, `n, All
			StringReplace, progInexistant1, progInexistant1, $prog, %prog%
			StringReplace, progInexistant1, progInexistant1, $inifile, %inifile%
			MsgBox, 262192, %cafeerreur%, %progInexistant1%
			Run, "%inifile%",,UseErrorLevel
			}
		}
return


;~ =============================================================
;~ WHERE WE SUSPEND CAFE 
;~ =============================================================
;~ Ctrl & LWin::
Suspension:
Suspend
IniRead, hk, %inifile%, configuration, HK_Pause, Win+P
If ( hk = "" )
	hk = Win+P
Menu, tray, ToggleCheck, %pause%`t(%hk%)
If ( _pause = "0")
	{
	_pause = 1
	TrayTip,,  %enpause%
	return
	}
If ( _pause = "1")
	{
	_pause = 0
	TrayTip,, %actif%
	return
	}
Return
;~ =============================================================


;~ =============================================================
;~ =============================================================
ConfigSouris:
Gosub GuiDestroyAll
	IfWinExist, ahk_class AutoHotkeyGUI
		Gui, destroy
	
	vitesse := DllCall("GetDoubleClickTime")
	priorClick := 0
	Gui, +AlwaysOnTop -SysMenu 
	Gui, Add, Text,vRapide, %labelrapide%
	Gui, Add, Text,vLent, %labellent%
	Gui, Add, Slider, Buddy1Rapide Buddy2Lent +Vertical Center Range150-1650 TickInterval150 Line150 gVitesse vvitesse Section x15 y15 h85, %vitesse%
	Gui, Add, Button,ys gTest, %boutontest%
	Gui, Add, Button,Section gDblClickSet, %labelvalider%
	Gui, Add, Button,ys gGuiEscape, %labelannuler%
	Gui, Show, Center, %titredblclick%
return

;~ =============================================================
;label obligatoire pour l'enregistrement de la position du slider
;~ =============================================================
Vitesse:
return
;~ =============================================================

;~ =============================================================
;~ =============================================================
Test:
	deltaClick := A_TickCount - priorClick
	priorClick := A_TickCount
	If (deltaClick < vitesse)
		{
		ToolTip, %dblclicktooltip%
		SetTimer, RemoveToolTip, 500
		}
	Else
		{
		StringReplace, oneclicktooltip1, oneclicktooltip, ``n, `n, All
		StringReplace, oneclicktooltip1, oneclicktooltip1, $deltaClick, %deltaClick%
		StringReplace, oneclicktooltip1, oneclicktooltip1, $vitesse, %vitesse%
		ToolTip, %oneclicktooltip%
		SetTimer, RemoveToolTip, 1500
		}
return

RemoveToolTip:
	SetTimer, RemoveToolTip, Off
	ToolTip
return

; on red�finit la vitesse du double clic gauche
DblClickSet:
	DllCall("SetDoubleClickTime", Int, vitesse)
	IniWrite, %vitesse%, %inifile%, configuration, doubleclic

GuiEscape:
	Gui, destroy
return

;verification qu'on a bien double cliqu�
CafeVerifDoubleClic:
	MouseGetPos, X, Y
	defaultDblClickSpeed := DllCall("GetDoubleClickTime")
	pastTime := A_TickCount-firstClick
	EnvSub, PriorX, %X%
	Transform, PriorX, Abs, %PriorX%
	EnvSub, PriorY, %Y%
	Transform, PriorY, Abs, %PriorY%
	If (pastTime < dblClickSpeed and PriorX <= XDblClickDiff and PriorY <=YDblClickDiff)
		{
		nonInterception = CafeDblClick
		Gosub, CafeAction
		}
	else
		{
		PriorX = %X%
		PriorY = %Y%
		firstClick := A_TickCount
		Click down
		}
return

;lancement de l'executable associ� si il existe
;if there is one, launch the associated software
CafeAction:
filename:=GetFileName()
If ( filename = "" or filename = "ERROR" )
	Goto, CafeEnter

Loop, Parse, filename, `r`n 
{
	If (A_LoopField = "")
		continue

	thisfilename = %A_LoopField%

	;si le fichier est un raccourci, on en cherche la cible
	;in case of link file, find the goal
	SplitPath, thisfilename , OutThisFileName,, extension
	IfEqual extension, lnk
	{
		FileGetShortcut, %thisfilename%, thisfilename
		SplitPath, thisfilename , OutThisFileName,, extension
	}
	
	
	If ( extension = "" )
		extension = ><
	
	;on v�rifie � quel programme il est associ�
	;whitch is the associated software
	IniRead, prog, %inifile%, %section%, %extension%, ask
	
	dossier := InStr(FileExist(thisfilename), "D")
	If (prog = "host" or prog = "ask" or dossier or not(FileExist(thisfilename)))
	{
		Iniread, auto, %inifile%, configuration, auto, 0
		If ( prog = "ask" and auto = "1" and not(dossier) )
		{
			StringReplace, fichiernonrepertorie1, fichiernonrepertorie, $extension, %extension%
			MsgBox, 262211, %cafeinfo%, %fichiernonrepertorie1%
			IfMsgBox, Yes
			{
				Gosub, Association
				return
			}
			IfMsgBox, Cancel
			{
				return
			}
			Else
			{
				If ( extension != "" )
					IniWrite, host, %inifile%, %section%, %extension%
				Else
					IniWrite, host, %inifile%, %section%, ><
				Send {Enter}
			}
		}
		If ( prog = "host" and dossier != "1")
		{
			SplitPath, thisfilename,, thisworkingdir
			Send {Enter}
		}
		Else
		{
			Gosub, %nonInterception%
		}
	}
	Else
	{
		Gosub, CafeGetUrl
		SplitPath, thisfilename,, thisworkingdir
		
		prog:=GetAbsMovPath(A_ScriptDir,prog)

		Run, %prog% "%thisfilename%", %thisworkingdir%,UseErrorLevel

		If (ErrorLevel = "ERROR")
			{
			MsgBox, 262196, %cafeerreur%, %logicielintrouvable%`n`n%prog%
			IfMsgBox, Yes
				Gosub, Association
			Else
				Gosub, %nonInterception%
		}
	}
}
return

;si il s'agit d'un fichier url, on r�cup�re l'url en question
CafeGetUrl:
	IfEqual extension, url
		IniRead, filename, %filename%, InternetShortcut, URL
return


;envoi des touches et double-clics non intercept�s
CafeEnter:
	Send, {Enter}
return

CafeAltEnter:
	Send, {Alt down}{Enter}{Alt up}
return

CafeDblClick:
;~ 	Click, 2
	Click, 1
return

ContextMenuClick:
	Send, {Enter}
return

;association d'extension avec un executable
CafeAssoc:
	Click
	filename:=GetFileName()
;si le fichier est un raccourci, on en cherche la cible
	SplitPath, filename,,, extension
	IfEqual extension, lnk
		FileGetShortcut, %filename%, filename
;on v�rifie � quel programme il est associ�
	SplitPath, filename ,,, extension
	IniRead, prog, %inifile%, %section%, %extension%, ask
	if ((prog != "host")&&(prog != "ask"))
		prog:=GetAbsMovPath(A_ScriptDir,prog)

Association:
	StringReplace, assocboxtitle1, assocboxtitle, $extension, %extension%
	FileSelectFile, opener, 3, %appspath%, %assocboxtitle1%, %typeapplication% (*.exe;*.cmd;*.bat)
	IfNotEqual, opener,
		{
		SplitPath, filename,, thisworkingdir
		Run, "%opener%" "%filename%", %thisworkingdir%,UseErrorLevel
		opener:=GetRelativePath(A_ScriptFullPath,opener)
		If ( extension != "" )
			IniWrite, %opener%, %inifile%, %section%, %extension%
		Else
			IniWrite, %opener%, %inifile%, %section%, ><
		}
return


GuiDestroyAll:
GuiDestroy:
	FileDelete, %tempfile%
	Gui, Destroy
	SetTitleMatchMode, 2
	Splitpath, inifile, ininame
	IfWinExist, %ininame%
		{
		WinActivate, %ininame%
		Send, ^s
		WinClose, %ininame%
		}
return


Fin:
;restoration de la vitesse de double-clic initiale
	currentDblClickSpeed := DllCall("GetDoubleClickTime")
	If (currentDblClickSpeed != initialDblClickSpeed)
		DllCall("SetDoubleClickTime", Int, initialDblClickSpeed)
ExitApp

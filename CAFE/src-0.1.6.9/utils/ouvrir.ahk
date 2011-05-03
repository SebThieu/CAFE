;
; AutoHotkey Version: 1.x
; Langage:        Français
; Plateforme:     WinXP
; Auteur:         Lahire Biette <tuxmouraille@gmail.com>
;
;


#NoEnv
SendMode Input
#SingleInstance, force
SetBatchLines, -1  ; Make the operation run at maximum speed.

;inclusion des fonctions relatives aux chemins de fichiers et à la lecture des fichiers ini
#Include %A_ScriptDir%
#Include ..\library.ahk
#Include ..\cafe_library.ahk
#Include ..\AHKArray.ahk

A_cmd := AHKANewArray()
A_nom := AHKANewArray()

;initialisation
	Process, Priority,,H
	CoordMode,Mouse,Screen
	SetWorkingDir,%A_ScriptDir%
	StringReplace, inifile, A_ScriptName, .ahk, .ini
	StringReplace, inifile, inifile, .exe, .ini
	Loop, %inifile%
		inifile = %A_LoopFileLongPath%

#Include ..\cafe_lang.ahk

; lecture du chemin vers le dossiers des applications
IniRead, appspath, %inifile%, configuration, appspath, %A_ScriptDir%
	appspath:=GetAbsMovPath(A_ScriptDir,appspath)

If 1 = /openwith
	Goto, ShowMenu

; ItsGui:
; listKey := GetIniSectionListKey(inifile,"associations")

; Gui, Add, Edit, x106 y200 w280 h20 vApp_Name,
; Gui, Add, Text, x106 y180 w280 h20 , Le nom à afficher dans le menu
; Gui, Add, Button, x416 y200 w40 h20 gChange_App_Name, Ok ; pour changer le nom de l'application
; Gui, Add, Edit, x106 y250 w280 h20 vApp_Path,
; Gui, Add, Button, x396 y250 w40 h20 , ...
; Gui, Add, Button, x436 y250 w40 h20 , Ok
; Gui, Add, Text, x106 y230 w280 h20 , Le chemin  relatif vers cette l'application
; Gui, Add, GroupBox, x96 y160 w390 h120 , Editer l'application liée
; Gui, Add, ListBox, x106 y20 w370 h110 vListApps gEdit_App +AltSubmit, ; la listbox des applications liées
; Gui, Add, GroupBox, x96 y0 w390 h160 , Liste des applications liées
; Gui, Add, GroupBox, x6 y0 w85 h280 , Extensions
; Gui, Add, ListBox, x11 y20 w75 h225 vListExt glistapps_ext +Sort, %listKey% ; la listbox des associations
; Gui, Add, Button, x366 y130 w110 h20 , Supprimer
; Gui, Add, Button, x11 y250 w75 h20 , Supprimer
; Gui, Show,, New GUI Window
; Return


; Change_App_Name:

	; GuiControlGet, ext,, ListExt
	; GuiControlGet, app,, ListApps
	; GuiControlGet, This_App_Name,, App_Name
	
	; IniRead, extList, %inifile%, associations, %ext%, %A_Space%	
	; StringReplace, extList, extList, %app%, %This_App_Name%, All
	; IniWrite, %extList%, %inifile%, associations, %ext%

	; listKey := GetIniSectionListKey(inifile,"associations")
	
	; GuiControl,, ListExt, |%listKey%
	; GuiControl, Choose, ListExt, %ext%
	
	; GoSub, listapps_ext

; return

; Edit_App:

	; GuiControlGet, Indx,, ListApps
	
	; progpath := AHKAGet(A_cmd,Indx)
	; progname := AHKAGet(A_nom,Indx)
	
	; GuiControl,, App_Name, %progname%
	; GuiControl,, App_Path, %progpath%

; return

; listapps_ext:

	; GuiControlGet, ext,, ListExt
	
	; IniRead, ow, %inifile%, associations, %ext%, %A_Space%
	; extsList = %ow%

	; appsList =

	; Loop, Parse, extsList, |
		; {
		; If ( A_LoopField = "" )
			; continue
		
		; cmd := GetAbsMovPath(A_ScriptDir,A_LoopField)
		; SplitPath, cmd,,,, name
		; IniRead, name, %inifile%, MenuName, %name%, %name%
		
		
		; A_cmd := AHKAAdd(A_cmd,cmd)
		; A_nom := AHKAAdd(A_nom,name)
		
		; If ( appsList = "" )
			; appsList = %name%
		; Else
			; appsList = %appsList%|%name%
		; }

	; GuiControl,, ListApps, |%appsList%
	
; return

GuiClose:
ExitApp

; on cré et on montre le menu contextuel
ShowMenu:

	IfEqual, 0, 2
		SplitPath, 2,,, ext
	Else
		ext = file
	
	IniRead, asso, cafe.ini, associations, %ext%, %A_Space%
	IniRead, alt, cafe.ini, alternative, %ext%, %A_Space%
	IniRead, ow, %inifile%, associations, %ext%, %A_Space%
	extsList = %asso%|%alt%|%ow%
	
	Menu, openwith, UseErrorLevel
	Loop, Parse, extsList, |
		{
		If ( A_LoopField = "" )
			continue
		
		cmd := GetAbsMovPath(A_ScriptDir,A_LoopField)
		SplitPath, A_LoopField,,,, name
		IniRead, name, %inifile%, MenuName, %name%, %name%
		
		A_cmd := AHKAAdd(A_cmd,cmd)
		A_nom := AHKAAdd(A_nom,name)
		
		; Menu, openwith, Add, %a_index% : %name%, runwiththis
		Menu, openwith, Add, %name%, runwiththis
		
		If ( A_Index = "1" and asso != "" )
			Menu, openwith, Default, %name%
		If ( A_Index = "1" and  asso != "" and alt = "" )
			Menu, openwith, Add
		If ( A_Index = "2" and alt != "" )
			Menu, openwith, Add
		}
	Menu, openwith, Add
	Menu, openwith, Add, Ouvrir avec une autre application, otherapp
	; Menu, openwith, Add
	; Menu, openwith, Add, Configurer, ItsGui
	Menu, openwith, Show
	ExitApp

return

runwiththis:

	Loop, %0%  ; For each parameter:
		{
		targ := %A_Index%
		If ( targ = "/openwith" )
			continue
		cherche = %A_ThisMenuItem%
		Indx := AHKAFind(A_nom,Cherche)
		prog := AHKAGet(A_cmd,Indx)
		
		Run, "%prog%" "%targ%"
		}
	ExitApp

return

otherapp:

	FileSelectFile, prog, 3, %appspath%, Ouvrir "%OutThisFileName%" avec:, %typeapplication% (*.exe`;*.cmd`;*.bat)
	If not prog
		return

	prog1:=GetRelativePath(A_ScriptFullPath,prog)
	IniRead, extList, %inifile%, associations, %ext%
	
	IfNotInString, extList, %prog1%
		{
		If ( extList = "" or extList = "ERROR" )
			extList = %prog1%
		Else
			extList = %extList%|%prog1%
		
		SplitPath, prog1,,,, name
		IniRead, appMenuName, %inifile%, MenuName, %name%
		If ( appMenuName = "" or appMenuName = "ERROR" )
			{
			InputBox, appMenuName, Ouvrir avec..., Veuillez indiquer le nom à utiliser dans le menu pour ce logiciel.,,,145
			If not appMenuName
				{
				appMenuName = %name%
				}
			IniWrite, %appMenuName%, %inifile%, MenuName, %name%
			}
		IniWrite, %extList%, %inifile%, associations, %ext%
		}
	
	Loop, %0%  ; For each parameter:
		{
		targ := %A_Index%
		If ( targ = "/openwith" )
			continue
		Run, "%prog%" "%targ%"
		}
	
	ExitApp
return

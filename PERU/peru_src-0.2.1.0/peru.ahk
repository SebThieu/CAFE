/*
AutoHotkey Version: 0.2.1.0
Langage:        Français
Plateforme:     WinXP
Auteur:         Yann Perrin <yann.perrin+clef@gmail.com> original coder
		  Lahire Biette <tuxmouraille@gmail.com> now coder
		  enigmatick add context menu fonction
		  Zachary Hudock <zrhudock@adelphia.net> and Brian All <brianallb23@gmail.com> add windows configuration (window_conf.ahk)

Utilité du Script :
	Crée des associations de fichiers temporaires, tant que le script est en cours d'utilisation

Purpose of this script:
	Create temporary file associations for portable applications.
*/

#NoEnv
SendMode Input
#SingleInstance, force
#InstallKeybdHook
;~ #UseHook On
;si on lance le logiciel avec le paramètre /exit, il s'arrête
IfEqual, 1, /exit
	ExitApp

;inclusion des fonctions relatives aux chemins de fichiers et à la lecture des fichiers ini
#Include %A_ScriptDir%
#Include library.ahk
#Include peru_library.ahk
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

#Include peru_lang.ahk


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

;mise en place de la vitesse de double-clic personnalisée
	initialDblClickSpeed := DllCall("GetDoubleClickTime")
	IniRead, dblClickSpeed, %inifile%, configuration, doubleclic, %initialDblClickSpeed%
	If (dblClickSpeed != initialDblClickSpeed)
		DllCall("SetDoubleClickTime", Int, dblClickSpeed)
	OnExit, Fin
;récupération des informations concernant la position de la souris lors d'un double-clic
	SysGet, XDblClickDiff, 36
	SysGet, YDblClickDiff, 37
;création du menu
	If A_IsCompiled
		Menu, tray, NoStandard


;~ ###################################################
;~ ###################################################
	; les entrés pour les informations
;~ 	FileInstall, README.html,README.html
;~ 	Run, README.html
;~ 	FileInstall, license.txt,license.txt
;~ 	AjoutInfo("license.txt")
;~ 	FileInstall, about.txt,about.txt
;~ 	AjoutInfo("about.txt")
;~ ###################################################
;~ ###################################################


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

	SplitPath, inifile, var
	Menu, pref, Add, Editer %var%, CafeEdit
	
	;~ =============================================================
	; where we make the town context menus, and we add items to the tray menu
	; ici on ajoute au tray menu les entrées suppléméntaires et on cré les menus contextuels.
	;~ =============================================================
	Loop
	{
		IniRead, type, %inifile%, TRAY, type-%A_Index%
		If ( type = "ERROR" or type = "" )
		{
			break
		}

		Else If ( type ="separator" )
		{
			Menu,TRAY, add
		}

		Else If ( type ="menu" )
		{
			IniRead, Item_Name, %inifile%, TRAY, name-%A_Index%
			Menu,TRAY,add,%Item_Name%,ContextAction
		}
	}

;~ 	#############################################
;~ 	#############################################
; les entrés pour les informations
;~ 	FileInstall, README.html,README.html
;~ 	Run, README.html
;~ 	FileInstall, license.txt,license.txt
;~ 	AjoutInfo("license.txt")
;~ 	FileInstall, about.txt,about.txt
;~ 	AjoutInfo("about.txt")
	Menu, tray, Add, %pref%, :pref
	Menu, tray, Add
;~ 	#############################################
;~ 	#############################################


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

;~ ###############################################################
;~ ### TEST D'AJOUT DU SUPPORT DE GESTION DU VOLUME AU CLAVIER ###
;~ ###############################################################
SoundGet, masterVolume
masterVolume := Round(masterVolume)

; ini file info
kXposName = xpos            ; name of GUI window x position value
kYposName = ypos            ; name of GUI window y position value
kWidthName = width          ; name of GUI window width value
kHeightName = height        ; name of GUI window height value


;----- other global constants -----
; OSD appearance and behavior
;~ kWindowColor := "111111"		;color of OSD slider background
;~ kWindowColor := "adadad"		;color of OSD slider background
IniRead, cl, %inifile%, Volume, OSD_Slider_BackGround
If ( cl = "" or cl = "ERROR" )
    kWindowColor := "adadad"
Else
    kWindowColor := cl

;~ kBarColor := "44ee44"			;greenish color of OSD slider when audio is unmuted
;~ kBarColor := "87D200"			;another greenish color of OSD slider when audio is unmuted
IniRead, cl, %inifile%, Volume, OSD_Slider_Color
If ( cl = "" or cl = "ERROR" )
    kBarColor := "44ee44"
Else
    kBarColor := cl

;~ kMuteBarColor := "999999"		;grey color of OSD slider when audio is muted
IniRead, cl, %inifile%, Volume, OSD_Slider_Color_AudioMuted
If ( cl = "" or cl = "ERROR" )
    kMuteBarColor := "999999"
Else
    kMuteBarColor := cl

;~ kBarHeight = 20			;height of OSD indicator bar in pixels
IniRead, kBarHeight, %inifile%, Volume, BarHeight, 20
If ( kBarHeight = "" )
    kBarHeight = 20

;~ kBarWidth = 300					;width of OSD indicator bar in pixels
IniRead, kBarWidth, %inifile%, Volume, BarWidth, 300
If ( kBarWidth = "" )
    kBarWidth = 300

;~ kUnmuted := "rsc/audio-volume-unmuted-48a.gif"	;OSD image of unmuted master audio
IniRead, ico, %inifile%, Volume, Unmuted_Icon
If ( ico = "" or ico = "ERROR" )
    kUnmuted := "rsc/audio-volume-unmuted-48a.gif"
Else
    kUnmuted := ico

;~ kMuted := "rsc/audio-volume-muted-48a.gif"	    ;OSDimage of muted master audio
IniRead, ico, %inifile%, Volume, Muted_Icon
If ( ico = "" or ico = "ERROR" )
    kMuted := "rsc/audio-volume-muted-48a.gif"
Else
    kMuted := ico

kDing := "rsc/ding.wav"     ; sound that plays when volume is set using GUI window

kSliderTimeout := 500		; time (msec) for OSD slider to go away after changing volume
kMuteTimeout := 1000		; time (msec) for OSD mute on/off icon to go away

kNumVolumeSteps := 25		; number of gradations in the OSD (hotkey controlled) volume control

; other OSD stuff
kOSDVolName := "volOSD_095B"    ; make this a window name guaranteed to not exist anywhere else
kOSDMuteName := "muteOSD_095B"  ; make this a window name guaranteed to not exist anywhere else

; GUI window stuff
kVolumeWinTitle := "Volume"   ; title of volume slider window
kVolumeWinMute := "Mute"      ; label for mute checkbox in volume slider window
kGUIpanelWidth := 100         ; width of volume slider window
kGUIsliderHeight := 100       ; height of actual volume slider

; About box stuff
kAboutMsgBoxTitle := "About HotkeyVolume"
kAboutStr := "HotkeyVolume`nv0.95b`n`nUp:`tAlt-UpArrow`nDown:`tAlt-DownArrow`nMute:`tAlt-M`n`n© 2006 Mithat Konar`n© 2009 Biette Lahire"
kErrorMixer := "Windows Mixer was not Found"

;----- Hotkey definitions -----
; These should be used only during debugging
;^!x::gosub Quit				; Ctrl-Alt-X exits script
;^!r::Reload                 ; Assign Ctrl-Alt-R restarts the script.
IniRead, hk, %inifile%, Volume, Volume_Up , Volume_Up
If ( hk = "" )  
	hk = Volume_Up
hk:=HK_Cafe2AHK(hk)
HotKey, %hk%, VolUp

IniRead, hk, %inifile%, Volume, Volume_Down , Volume_Down
If ( hk = "" )  
	hk = Volume_Down
hk:=HK_Cafe2AHK(hk)
HotKey, %hk%, VolDown

IniRead, hk, %inifile%, Volume, Volume_Mute , Volume_Mute
If ( hk = "" )  
	hk = Volume_Mute
hk:=HK_Cafe2AHK(hk)
HotKey, %hk%, ToggleMute

;~ ###############################################################
;~ ###############################################################



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

	Menu, tray, Tip, P.E.R.U.
	Iniread, auto, %inifile%, configuration, auto, 0
	If auto
		Menu, pref, Check, %autoassoc%
;~ démarrage en pausec
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

; où on crée les groupes de fenêtres
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
; où on ajoute nos propres raccourcis clavier
list := GetIniSectionListKey(inifile,"HOTKEY")
Loop, Parse, list, |
{
	
	hk = %A_LoopField%
	
	IniRead, cmd, %inifile%, HOTKEY, %hk%
	StringSplit, array, cmd, ~
	
	; cette fonction sert à convetir les codes des raccourcis clavier 
	; dans le fichier deconfiguration, où ils sont compréhensibles par l'utilisateur
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
	HotKey, ~MButton, Boutton_Milieu
}

IniRead, var, %inifile%, configuration, Use_Win_Right_Click
If ( var = "1" )
{
	Hotkey, IfWinActive, ahk_group Interception
	HotKey, ~RButton, Boutton_Droit
}

IniRead, var, %inifile%, configuration, Use_Double_Right_Click
If ( var = "1" )
{
	Hotkey, IfWinActive, ahk_group Interception
	HotKey, ~#RButton, Win_Boutton_Droit
}
;~ =============================================================


;~ =============================================================
;~ raccourcis pour la sélection de la fenêtre à ajouter
	Hotkey, IfWinExist, %wintitlegui%
	Hotkey, +#Lbutton, selwin
;~ =============================================================


;~ =============================================================
;~ WHERE WE CHECK A MAYBE COMMAND LINE ARGUMENT
;~ will be delete when the Gui will be separated to the deamon
;~ =============================================================µ
; le paramètre /appsconf ouvre la fenêre de configuration des apps
IfEqual, 1, /appsconf
	GoSub, CafeConfApps

; le paramètre /extsconf ouvre la fenêre de configuration des extensions
IfEqual, 1, /extsconf
	GoSub, CafeConf

;si on le lance avec le paramètre /mouseconf,  on ouvre la fenêre de conf de la souris
IfEqual, 1, /mouseconf
	GoSub, ConfigSouris

;si on le lance avec le paramètre /hkconf,  on ouvre la fenêre de conf des raccourcis
IfEqual, 1, /hkconf
	GoSub, HK_Gui

;si on le lance avec le paramètre /hkconf,  on ouvre la fenêre de conf des fenêtres additionnelles
IfEqual, 1, /winconf
	GoSub, CafeConfWindows
;~ =============================================================


;~ =============================================================
;~ WHERE WE SHOW THE BALLON TOOL TIP TO SHOW CAFE IS READE TO BE USE
;~ =============================================================
; on affiche le ballon tool tip qui indique que cafe à finit de se charger en mémoire 
TrayTip, %cafeoperationel%, %utilisationpossible%,, 1
;~ =============================================================

Return

;~ ##############################################################################################################################
;~ ##############################################################################################################################
;~ ################################ TEST D'AJOUT DU SUPPORT DE GESTION DU VOLUME AU CLAVIER #####################################
;~ ##############################################################################################################################
;~ ##############################################################################################################################
;----- Subroutines -----;
VolUp:
; Turns volume up and updates OSD and system tray.
gosub RemoveVolumeWindow
incrementVol("up", kNumVolumeSteps)
gosub ShowVolume
return

VolDown:
; Turns volume down and updates OSD and system tray.
gosub RemoveVolumeWindow
incrementVol("down", kNumVolumeSteps)
gosub ShowVolume
return

ToggleMute:
; Toggles mute setting and updates OSD and system tray icon.
gosub RemoveVolumeWindow
SoundSet, +1, , mute  ;toggle the master mute
gosub ShowMute
return

ToggleMuteNoOSD:
; Toggles mute setting and updates system tray icon without updating OSD.
SoundSet, +1, , mute  ;toggle the master mute
Return

ShowVolume:
; Displays OSD volume indicator and updates system tray tooltip
SoundGet, masterVolume
masterVolume := Round(masterVolume)
Menu, Tray, Tip , Volume [%masterVolume%`%]
IfWinNotExist, %kOSDVolName%
{
    SoundGet, masterMute, , mute
    if (masterMute = "On")
		barColor := kMuteBarColor
    else
        barColor := kBarColor
    Progress, b r0-100 cw%kWindowColor% cb%barColor% w%kBarWidth% zh%kBarHeight% zx0 zy0,,, %kOSDVolName%	; Set the position of the bar to %masterVolume%.
}
IfWinExist, %kOSDMuteName%		; if a mute indicator is on screen, remove it
    SplashImage, Off
Progress, %masterVolume%	; set the position of the bar to %master_volume%.
SetTimer, RemoveProgress, %kSliderTimeout%
Return

ShowMute:
; Displays OSD mute state indicator.
SoundGet, masterMute, , mute
IfWinExist, %kOSDVolName%		; if a volume slider is on screen, remove it
    Progress, Off
if (masterMute = "On")
    muteStateImage := kMuted
else
    muteStateImage := kUnMuted
SplashImage, %muteStateImage%, b,,, %kOSDMuteName%
SetTimer, RemoveSplashImage, %kMuteTimeout%
return

RemoveProgress:
; Removes a progress bar.
SetTimer, RemoveProgress, Off	;turn the timer off
Progress, Off	;turn the progress bar off
return

RemoveSplashImage:
; Removes splash image
SetTimer, RemoveSplashImage, Off	;turn the timer off
SplashImage, Off	;turn the splashimage off
return

RemoveVolumeWindow:
; Removes the GUI volume window if it exists
if volGUIWinExist()
    WinClose, %kVolumeWinTitle% ahk_class AutoHotkeyGUI, %kVolumeWinMute%
return

GUIUpdateVol:
; Used with the GUI volume window. Sets the system volume level based on position of the GUI volume window's slider
; and updates system tray tooltip.
SoundSet, %GUImasterVolume% ; set the volume level
GUImasterVolume := Round(GUImasterVolume)
Menu, Tray, Tip , Volume [%GUImasterVolume%`%]
SoundPlay, %kDing%
return
;~ ##############################################################################################################################
;~ ##############################################################################################################################
;~ ##############################################################################################################################
;~ ##############################################################################################################################



;~ =============================================================
;~ WHERE WE LAUNCH THE CONFIGURED COMMAND FOR THE USED HOTKEY
;~ =============================================================
; où on lance la commande associée au raccourcis clavier
HKAction:
hk = %A_ThisHOTKEY%
If ( _pause_hk = "1" )
	{
	Send, {%hk%}
	Return
	}

; cette fonction sert à convertir les codes AHK des raccourcis clavier en codes
; du fichier deconfiguration, compréhensibles par l'utilisateur
hk:=HK_AHK2Cafe(hk)

IniRead, cmd, %inifile%, HOTKEY, %hk%

StringSplit, array, cmd, ~

If ( array2 != "" )
	{
	cmd = %array1%
	}


cmd:=GetAbsMovPath(A_ScriptDir,cmd)

cmd:=GetGoodCMD(cmd,inifile)

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
	StringReplace, MenuItem, A_ThisMenuItem, %outfilename%, $N, All
	IniRead, prog, %inifile%, %A_ThisMenu%, %MenuItem%
	If ( prog = "ERROR" or prog = "" )
	{
		MsgBox,, %cafeerreur%, %logicielintrouvable3%
	}

	Else
	{
		prog:=GetGoodCMD(prog,inifile)

		StringReplace, f, f, `r`n, " ", All

		StringReplace, prog, prog, $F, %f%, All
		StringReplace, prog, prog, $P, %filedir%, All
		StringReplace, prog, prog, $E, %filetruncatedname%, All

		prog:=GetAbsMovPath(A_ScriptDir,prog)

		If (filedir = "FolderView")
			filedir = %A_Desktop%
		
		IfInString, prog, *hide*
		{
			StringReplace, prog, prog, %A_Space%*hide*,, All
;~ 			MsgBox, Run, %prog%, %filedir%, Hide UseErrorLevel
			Run, %prog%, %filedir%, Hide UseErrorLevel
		}
		Else
		{
;~ 	 		MsgBox, Run, %prog%, %filedir%,UseErrorLevel
	 		Run, %prog%, %filedir%,UseErrorLevel
		}

		If (ErrorLevel = "ERROR")
		{
			MsgBox,, %cafeerreur%, %logicielintrouvable3%
		}
	}
Return

OuvrirAction:
If ( A_ThisMenu = "CONTEXT" )
{
	filename = %f%
	section := "1"
	Gosub, CafeAction2
}

Else If ( A_ThisMenu = ouvrir )
{
	filename = %f%
	section := "1"
	Gosub, CafeAction2
}

Else If ( A_ThisMenu = ouvriravec )
{
	filename = %f%
	section := A_ThisMenuItemPos
 	Gosub, CafeAction2
}
Return

;~ =============================================================
;mise en place des raccourcis spécifiques
;~ =============================================================
#IfWinActive, ahk_group Interception
Lbutton::
	If ( _pause_fs = "1" )
	{
;~ 		Send, {Lbutton}
		Send, {Click}
		Return
	}
	section := "1"
 	Gosub, CafeVerifDoubleClic
Return

!Lbutton::
	If ( _pause_fs = "1" )
	{
;~ 		Send, {!Lbutton}
		Send, {Alt}{Click}
 		Return
	}
	section := "2"
	Gosub, CafeVerifDoubleClic
Return

Lbutton UP::
	Click up
Return

#Lbutton::
	section := "1"
	Gosub, CafeAssoc
Return

!#Lbutton::
	section := "2"
	Gosub, CafeAssoc
Return

Enter::
	If ( _pause_fs = "1" )
	{
		Send, {Enter}	
		Return
	}
NumpadEnter::
	If ( _pause_fs = "1" )
	{
		Send, {NumpadEnter}
		Return
	}
	section := "1"
	nonInterception = CafeEnter
	Gosub, CafeAction
Return

!Enter::
	If ( _pause_fs = "1" )
	{
		Send, {!Enter}	
		Return
	}

!NumpadEnter::
	If ( _pause_fs = "1" )
	{
		Send, {!NumpadEnter}	
		Return
	}
	section := "2"
	nonInterception = CafeAltEnter
	Gosub, CafeAction
Return


;~ =============================================================
;~ interception des actions qui permettent d'afficher le menu contextuel de CAFE
;~ =============================================================
Boutton_Droit:
; pour le pause selective du menu contextuel
If ( _pause_menu = "1" )
{
	Send, {~RButton}
	Return
}

; If (A_PriorHotKey = A_ThisHotKey and A_TimeSincePriorHotkey < 500)
If (A_PriorHotKey = A_ThisHotKey and A_TimeSincePriorHotkey < dblClickSpeed )
	{ ; détection sommaire d'un double-clic droit, il faudrait remplacer 500 par le temps de double-clic système.
	KeyWait, RButton  ; on attend que le bouton droit soit relaché, ce qui déclenche généralement l'ouverture du menu contextuel
	WinWait, ahk_class #32768, , 1  ; on attend que le menu contextuel apparaisse
	if not ErrorLevel  ; et si il est trouvé, on le ferme.
		Send {Escape}
	f:=GetFileName()
	GoSub, Next
	}
Return


Win_Boutton_Droit:
; pour le pause selective du menu contextuel
If ( _pause_menu = "1" )
{
	Send, {~#RButton}
	Return
}

KeyWait, RButton  ; on attend que le bouton droit soit relaché, ce qui déclenche généralement l'ouverture du menu contextuel
WinWait, ahk_class #32768, , 1  ; on attend que le menu contextuel apparaisse
if not ErrorLevel  ; et si il est trouvé, on le ferme.
	Send {Escape}
f:=GetFileName()
Gosub, Next
Return


Boutton_Milieu:
; pour le pause selective du menu contextuel
If ( _pause_menu = "1" )
{
	Send, {MButton}
	Return
}

f:=GetFileName()
StringSplit, OutputArray, f, `r
If ( OutputArray0 = "1" ) or ( f = "")
{
	Send {Click Down}
	KeyWait, MButton, U
	Send {Click Up}
	f:=GetFileName()
}

Gosub, Next
Return

Next:
If ( f != "")
{
	StringSplit, OutputArray, f, `r`n

	If ( OutputArray0 > "1" )
	{
		SplitPath, OutputArray1 , outfilename, filedir, extension, filetruncatedname
		dossier := InStr(FileExist(OutputArray1), "D")
		If ( dossier = "1" )
		{
			filetruncatedname = %outfilename%
		}
		extension = `?
;~ 		StringReplace, f, f, `r`n, `"%A_Space%`", All
	}
	
	Else If ( OutputArray0 = "1" )
	{
		; si le fichier est un raccourci, on en cherche la cible
		SplitPath, f , outfilename, filedir, extension, filetruncatedname
		IfEqual extension, lnk
		{
			FileGetShortcut, %f%, f
			SplitPath, f , outfilename, filedir, extension, filetruncatedname
		}

		If ( extension = "" )
			extension = ><
		
		dossier := InStr(FileExist(f), "D")
		If ( dossier = "1" )
		{
			extension = \
			filetruncatedname = %outfilename%
		}
	}
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
		StringSplit, OutputArray, text , `r
		filedir := OutputArray1
		extension = 
	}
}

Menu, CONTEXT, UseErrorLevel

If ( OutputArray0 > "1" and f != "" )
{
	Menu, CONTEXT, add, %ouvrir%, OuvrirAction
	Menu, CONTEXT, Default, %ouvrir%
	Menu, CONTEXT, add
}

If ( OutputArray0 = "1" )
{
	IniRead, app, %inifile%, ASSOCIATIONS, %extension%
	If ( app != "" and app != "ERROR" )
	{
		Loop, Parse, app, |
		{
			StringReplace, cmd, A_LoopField, =,, All 
			IniRead, descr, %inifile%, DESCRIPTION, %cmd%, %cmd%
			
			If ( A_Index = "1" )
			{
				Menu,CONTEXT,add, %ouvriravec% %descr%, OuvrirAction
				Menu,CONTEXT,Default, %ouvriravec% %descr%
			}
			If ( descr != "ERROR" )
			{
				Menu,%ouvriravec%,add, %ouvriravec% %descr%, OuvrirAction
			}
		}

		Menu,%ouvriravec%,add
	}

	Menu,%ouvriravec%,add, Choisir une application, Association2 ;i18n

	Menu,CONTEXT,add,%ouvriravec%,:%ouvriravec%
	Menu,CONTEXT,add
}


CreateContext(extension,inifile,"CONTEXT",outfilename)
Menu, CONTEXT, show

RemoveContext(inifile,"CONTEXT")
Menu,%ouvriravec%, DeleteAll
Menu, CONTEXT, DeleteAll

Return

;mise en place des raccourcis généraux
#IfWinActive
~LButton::
~!LButton::
	MouseGetPos, X, Y
	PriorX = %X%
	PriorY = %Y%
	firstClick := A_TickCount
Return

;~ section des raccourcis en dure que je doit changer
relancer:
	Reload
Return

; editer les associations
;~ #x::
CafeConf:
Gosub GuiDestroyAll
#Include peru_ext_conf.ahk
Return

; editer les applications
;~ #a::
CafeConfApps:
Gosub GuiDestroyAll
#Include peru_apps_conf.ahk
Return

;~ #w::
CafeConfWindows:
Gosub GuiDestroyAll
#Include peru_window_conf.ahk
Return

;~ #h::
CafeConfHK:
Gosub GuiDestroyAll
#Include peru_hk_conf.ahk
Return
;~ =============================================================
;~ fin de la section des raccourcis en dure
;~ =============================================================


;~ =============================================================
;labels correspondant aux entrées du menu
;~ =============================================================
AutoAsso:
	Menu, pref, ToggleCheck, %autoassoc%
	Iniread, auto, %inifile%, configuration, auto, 0
	If auto
		IniDelete, %inifile%, configuration, auto
	Else
		IniWrite, 1, %inifile%, configuration, auto
Return

;choix du langage
Lng:
	lngfile = %lngdir%\%A_ThisMenuItem%.lng
	Iniwrite, %lngfile%, %inifile%, configuration, langue
	Reload
Return

; editer le fichier des associations
CafeEdit:
	filename = %inifile%
	section := "1"
	Gosub, CafeAction2
Return


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
	Return
	}
If ( _pause = "1")
	{
	_pause = 0
	TrayTip,, %actif%
	Return
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
Return

;~ =============================================================
;label obligatoire pour l'enregistrement de la position du slider
;~ =============================================================
Vitesse:
Return
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
Return

RemoveToolTip:
	SetTimer, RemoveToolTip, Off
	ToolTip
Return

; on redéfinit la vitesse du double clic gauche
DblClickSet:
	DllCall("SetDoubleClickTime", Int, vitesse)
	IniWrite, %vitesse%, %inifile%, configuration, doubleclic


GuiClose:
	Suspend, Off
GuiEscape:
	Gui, destroy
Return

;verification qu'on a bien double cliqué
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
Return

;lancement de l'executable associé si il existe
;if there is one, launch the associated software
CafeAction:
filename:=GetFileName()

If ( filename = "" or filename = "ERROR" )
	Goto, CafeEnter

CafeAction2:
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
	
	dossier := InStr(FileExist(thisfilename), "D")
;~ 	If ( dossier != "0" )
;~ 		extension = \

;~ 	If ( dossier != "0" )
;~ 	{
;~ 		StringRight, extension, thisfilename, 8
;~ 		If ( extension != "Portable" )
;~ 		{
;~ 			SplitPath, thisfilename, outname
;~ 			StringLeft, extension, outname, 8
;~ 			
;~ 			If ( extension != "Portable" )
;~ 				extension = \
;~ 		}
;~ 		Else If ( extension = "Portable" )
;~ 			dossier = 0
;~ 	}

	If ( dossier != "0" )
	{
		StringRight, extension, thisfilename, 8
		If ( extension != "Portable" )
			extension = \
		Else If ( extension = "Portable" )
			dossier = 0
	}


	;on vérifie à quel programme il est associé
	;whitch is the associated software
	IniRead, prog, %inifile%, ASSOCIATIONS, %extension%, ask
	
	StringSplit, out, prog, |
	prog := out%section%

;~ 	If (prog = "host" or prog = "ask" or dossier = "2" or dossier = "3" or not(FileExist(thisfilename)))
	If (prog = "host" or prog = "ask" or ( dossier != "0" and dossier != "1" ) or not(FileExist(thisfilename)))
	{	
		Iniread, auto, %inifile%, configuration, auto, 0
		If ( prog = "ask" and auto = "1" )
		{
			StringReplace, fichiernonrepertorie1, fichiernonrepertorie, $extension, %extension%
			MsgBox, 262211, %cafeinfo%, %fichiernonrepertorie1%
			IfMsgBox, Yes
			{
				Gosub, Association
				Return
			}
			IfMsgBox, Cancel
			{
				Return
			}
			Else
			{
				If ( extension != "" )
					IniWrite, host, %inifile%, ASSOCIATIONS, %extension%
				Else
					IniWrite, host, %inifile%, ASSOCIATIONS, ><
				Send {Enter}
			}
		}
		Else If ( prog = "host" and dossier != "0" )
		{
			Send {Enter}
		}
		Else If ( prog = "host" )
		{
			SplitPath, thisfilename,, thisworkingdir
			Run, %thisfilename%, %thisworkingdir%, UseErrorLevel
			If ( ErrorLevel = "ERROR" )
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

		prog:=GetGoodCMD(prog,inifile)

		prog:=GetAbsMovPath(A_ScriptDir,prog)

		Run, %prog% "%thisfilename%", %thisworkingdir%,UseErrorLevel

		If (ErrorLevel = "ERROR")
		{
			MsgBox, 262196, %cafeerreur%, %logicielintrouvable%`n`n"%prog%" "%thisfilename%"
			IfMsgBox, Yes
				Gosub, Association
			Else
				Gosub, %nonInterception%
		}
	}
}
Return

;si il s'agit d'un fichier url, on récupère l'url en question
CafeGetUrl:
	IfEqual extension, url
		IniRead, filename, %filename%, InternetShortcut, URL
Return


;envoi des touches et double-clics non interceptés
CafeEnter:
	Send, {Enter}
Return

CafeAltEnter:
	Send, {Alt down}{Enter}{Alt up}
Return

CafeDblClick:
;~ 	Click, 2
	Click, 1
Return

ContextMenuClick:
	Send, {Enter}
Return

;association d'extension avec un executable
CafeAssoc:
	Click

	filename:=GetFileName()
;si le fichier est un raccourci, on en cherche la cible
	SplitPath, filename,,, extension
	IfEqual extension, lnk
		FileGetShortcut, %filename%, filename
;on vérifie à quel programme il est associé
	SplitPath, filename ,,, extension
	IniRead, prog, %inifile%, ASSOCIATIONS, %extension%, ask
	If ( prog != "ask" )
	{
		StringSplit, out, prog, |
		prog := out%section%
	}
	
	if ((prog != "host")&&(prog != "ask"))
		prog:=GetAbsMovPath(A_ScriptDir,prog)

Association:
	StringReplace, assocboxtitle1, assocboxtitle, $extension, %extension%
	FileSelectFile, opener, 3, %appspath%, %assocboxtitle1%, %typeapplication% (*.exe;*.cmd;*.bat;*.java;*.py;*.*)
	IfNotEqual, opener,
	{
		SplitPath, filename,, thisworkingdir
		
		prog:=GetGoodCMD(opener,inifile)
		
		prog:=GetAbsMovPath(A_ScriptDir,prog)

		Run, %prog% "%filename%", %thisworkingdir%,UseErrorLevel
		
		If (ErrorLevel = "ERROR")
		{
			Msgbox, Il y a une erreur
		}

		opener:=GetRelativePath(A_ScriptFullPath,opener)
		IniRead, app, %inifile%, ASSOCIATIONS, %extension%, ERROR
		
		IfNotInString, app, %opener%
		{
		If ( app != "ERROR" )
			{
				If ( extension != "" )
					IniWrite, %opener%|%app%, %inifile%, ASSOCIATIONS, %extension%

				Else If ( extension = "" )
					IniWrite, %opener%|%app%, %inifile%, ASSOCIATIONS, ><
			}
			
			Else If ( app = "ERROR" )
			{
				If ( extension != "" )
				IniWrite, %opener%, %inifile%, ASSOCIATIONS, %extension%

				Else If ( extension = "" )
					IniWrite, %opener%, %inifile%, ASSOCIATIONS, ><
			}
		}
	}
Return

Association2:
	filename:=GetFileName()
;si le fichier est un raccourci, on en cherche la cible
	SplitPath, filename,,, extension
	IfEqual extension, lnk
		FileGetShortcut, %filename%, filename
;on vérifie à quel programme il est associé
	SplitPath, filename ,,, extension
	IniRead, prog, %inifile%, ASSOCIATIONS, %extension%, ask
	If ( prog != "ask" )
	{
		StringSplit, out, prog, |
		prog := out%section%
	}
	
	If ((prog != "host")&&(prog != "ask"))
		prog:=GetAbsMovPath(A_ScriptDir,prog)

	StringReplace, assocboxtitle1, assocboxtitle, $extension, %extension%
	FileSelectFile, opener, 3, %appspath%, %assocboxtitle1%, %typeapplication% (*.exe;*.cmd;*.bat)
	
	IfNotEqual, opener,
	{
		SplitPath, filename,, thisworkingdir

		prog:=GetGoodCMD(opener,inifile)
		prog:=GetAbsMovPath(A_ScriptDir,prog)

		Run, %prog% "%filename%", %thisworkingdir%,UseErrorLevel
		
		opener:=GetRelativePath(A_ScriptFullPath,opener)
		IniRead, app, %inifile%, ASSOCIATIONS, %extension%, ERROR
		
		IfNotInString, app, %opener%
		{
			If ( extension != "" and app != "ERROR" )
				IniWrite, %app%|%opener%, %inifile%, ASSOCIATIONS, %extension%

			Else If ( extension = "" and app != "ERROR" )
				IniWrite, %app%|%opener%, %inifile%, ASSOCIATIONS, ><

			Else If ( extension != "" and app = "ERROR" )
				IniWrite, %opener%, %inifile%, ASSOCIATIONS, %extension%

			Else If ( extension = "" and app = "ERROR" )
				IniWrite, %opener%, %inifile%, ASSOCIATIONS, ><
		}
	}
Return


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
Return


Fin:
;restoration de la vitesse de double-clic initiale
	currentDblClickSpeed := DllCall("GetDoubleClickTime")
	If (currentDblClickSpeed != initialDblClickSpeed)
		DllCall("SetDoubleClickTime", Int, initialDblClickSpeed)
ExitApp

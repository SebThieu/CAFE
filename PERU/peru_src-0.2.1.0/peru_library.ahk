;~ ##############################################################################################################################
;~ ##############################################################################################################################
;~ ################################ TEST D'AJOUT DU SUPPORT DE GESTION DU VOLUME AU CLAVIER #####################################
;~ ##############################################################################################################################
;~ ##############################################################################################################################
incrementVol(direction, numVolumeSteps)
; If direction = "up", the volume level is incremented by 100/numVolumeSteps; otherwise volume is
; decremented by the same amount.
{
    SoundGet, masterVolume						;get existing volume level (0 to 100)
    masterVolume := masterVolume/100 * numVolumeSteps	;scale to numVolumeSteps (0 to kNumVolumeSteps)
    masterVolume := Round(masterVolume)			;quantize
    if(direction = "up" or direction = "UP")
        masterVolume++								;add 1
    else
        masterVolume--								;subtract 1        
    masterVolume := Round(masterVolume/numVolumeSteps * 100)	;rescale to 0 to 100
    SoundSet, %masterVolume% ;set the volume level
}

volGUIWinExist()
; Returns 1 if the GUI volume window exists, 0 otherwise.
; I made this a function in case a better way to positively identify the window is found.
{
    global kVolumeWinTitle
    global kVolumeWinMute
    IfWinExist, %kVolumeWinTitle% ahk_class AutoHotkeyGUI, %kVolumeWinMute%
        return 1
    return 0
}

aboutBoxExist()
; Returns 1 if the "About" MsgBox exists, 0 otherwise.
; I made this a function in case a better way to positively identify the box is found.
{
    global kAboutMsgBoxTitle
    global kAboutStr
    IfWinExist, %kAboutMsgBoxTitle% ahk_class #32770, %kAboutStr%
        return 1
    return 0
}
;~ ##############################################################################################################################
;~ ##############################################################################################################################
;~ ##############################################################################################################################
;~ ##############################################################################################################################



; ------------------------------------------------------------------------------
; Où on la commnande à lancer...
; ------------------------------------------------------------------------------
GetGoodCMD(cmd,inifile){
	EnvGet, exec, PATHEXT
	
	SplitPath, cmd,,, pext
	IniRead, var, %inifile%, ASSOCIATIONS, %pext%, ERROR
	StringSplit, var, var, |
	app = %var1%
	
	SplitPath, app,,, pext
	
 	IfNotInString, exec, %pext%
	{
		app:=GetGoodCMD(app,inifile)
	}
	
	If ( var != "ERROR" and var != "" and app != "host" )
	{
		app:=GetAbsMovPath(A_ScriptDir,app)
		cmd := app . A_Space . cmd
	}
Return, cmd
}
; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------


; ------------------------------------------------------------------------------
; Où on crée la liste des applications liées
; ------------------------------------------------------------------------------
MakeListApps(inifile){
	list:=GetIniSectionListKey(inifile,"ASSOCIATIONS")
	
	aplist =
	Loop, Parse, list, |
	{
		IniRead, app, %inifile%, ASSOCIATIONS, %A_LoopField%, 0
		aplist = %aplist%|%app%
	}
	
	list =
	Loop, Parse, aplist, |
	{
		If ( A_LoopField != "" )
		{
			IfNotInString, list, %A_LoopField%
			{
				If ( list = "" )
					list = %A_LoopField%
				Else
					list = %list%|%A_LoopField%
			}
		}
	}
	
	Return, list
}
; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; Où on crée la liste de toutes les clés des sections association et alternative
; du fichier de configuration cafe.ini
; ------------------------------------------------------------------------------
MakeListExtWithApp(inifile,value){
	list:=GetIniSectionListKey(inifile,"ASSOCIATIONS")
	
	extlist=
	Loop, Parse, list, |
	{
		IniRead, app, %inifile%, ASSOCIATIONS, %A_LoopField%, 0
		IfInString, app, %value%
		{
			If ( extlist = "" )
				extlist = %A_LoopField%
			Else
				extlist = %extlist%|%A_LoopField%
		}
	}

	Return,	extlist
}
; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------


; ------------------------------------------------------------------------------
; où change l'application associées
; ------------------------------------------------------------------------------
ChangeAss(inifile,holdpath,thisnewapp){
	list:=GetIniSectionListKey(inifile,"ASSOCIATIONS")
	
	Loop, Parse, list, |
	{
		IniRead, app, %inifile%, ASSOCIATIONS, %A_LoopField%, 0
		appn =
		Loop, Parse, app, |
		{
			If ( A_LoopField = holdpath  and appn = "")
				appn = %thisnewapp%
			
			Else If ( A_LoopField = holdpath  and appn != "")
				appn = %appn%|%thisnewapp%
			
			Else If ( A_LoopField != holdpath  and appn = "")
				appn = %A_LoopField%
			
			Else If ( A_LoopField != holdpath  and appn != "")
				appn = %appn%|%A_LoopField%
		}
		IniWrite, %appn%, %inifile%, ASSOCIATIONS, %A_LoopField%
	}
}
; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------


; ------------------------------------------------------------------------------
; où on cré le menu contextuel
; ------------------------------------------------------------------------------
CreateContext(extension,Menu_File,Menu_Name,App_Name)
{
	Loop
	{
		IniRead, type, %Menu_File%, %Menu_Name%, type-%a_index%
		If ( type = "ERROR" or type = "" )
		{
			break
		}

		IniRead, filetype, %Menu_File%, %Menu_Name%, filetype-%a_index%, %A_Space%
		If ( ( extension = "" and filetype = "" ) or ( extension != "" and filetype != "" and InStr(filetype,extension) ) or ( filetype != "" and extension != "" and extension != "\"  and extension != "?" and InStr(filetype, ".*") ) )
		{
			If ( type ="separator" )
			{
				Menu,%Menu_Name%, add
			}

			Else If ( type ="submenu" )
			{
				IniRead, Sub_Name, %Menu_File%, %Menu_Name%, name-%a_index%
				CreateContext(extension,Menu_File,Sub_Name,App_Name)
				Menu,%Menu_Name%,add,%Sub_Name%,:%Sub_Name%
			}

			Else If ( type ="menu" )
			{
				IniRead, Item_Name, %Menu_File%, %Menu_Name%, name-%a_index%
				StringReplace, Item_Name, Item_Name, $N, %App_Name%, All
				Menu,%Menu_Name%,add,%Item_Name%,ContextAction
			}
		}
	}
}
; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------


; ------------------------------------------------------------------------------
; où on cré le menu contextuel
; ------------------------------------------------------------------------------
RemoveContext(Menu_File,Menu_Name)
{
	
	Loop
	{
		IniRead, type, %Menu_File%, %Menu_Name%, type-%a_index%
		If ( type = "ERROR" or type = "" )
		{
			break
		}

		If ( type ="separator" or type = "menu" )
		{
			Continue
		}

		If ( type ="submenu" )
		{
			IniRead, Sub_Name, %Menu_File%, %Menu_Name%, name-%a_index%
			RemoveContext(Menu_File,Sub_Name)
			Menu, %Sub_Name%, DeleteAll
		}
	}
}
; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------


; ------------------------------------------------------------------------------
; Les deux fonctions suivantes servent à convertir les codes des
; raccourcis clavier AutoHotkey en code plus compréhensible pour
; l'utilisateur de C.A.F.E., et vis et versa.
; sont utilisables les touches Alt, Ctrl, Shift, AltGr et Win, plus toutes
; les lettres et le touches F1 à F12
; ------------------------------------------------------------------------------
HK_AHK2Cafe(_hk){
	IfInString, _hk, +
		StringReplace, _hk, _hk, +, Shift+, ReplaceAll
	IfInString, _hk, #
		StringReplace, _hk, _hk, #, Win+, ReplaceAll
	IfInString, _hk, ^
		StringReplace, _hk, _hk, ^, Ctrl+, ReplaceAll
	IfInString, _hk, !
		StringReplace, _hk, _hk, !, Alt+, ReplaceAll
	IfInString, _hk, <^>!
		StringReplace, _hk, _hk, <^>!, AltGr+, ReplaceAll
	IfInString, _hk, ~Esc &
		StringReplace, _hk, _hk, ~Esc%A_Space%&%A_Space%, Esc+, ReplaceAll
	StringLeft, OutputVar, _hk, 1
	If ( OutputVar = + )
		StringTrimLeft, _hk, _hk, 1
Return, %_hk%
}

HK_Cafe2AHK(_hk){
	IfInString, _hk, +
		StringReplace, _hk, _hk, +,, ReplaceAll
	IfInString, _hk, Win
		StringReplace, _hk, _hk, Win, #, ReplaceAll
	IfInString, _hk, Ctrl
		StringReplace, _hk, _hk, Ctrl, ^, ReplaceAll
	IfInString, _hk, Alt
		StringReplace, _hk, _hk, Alt, !, ReplaceAll
	IfInString, _hk, Shift
		StringReplace, _hk, _hk, Shift, +, ReplaceAll
	IfInString, _hk, AltGr
		StringReplace, _hk, _hk, AltGr, <^>!, ReplaceAll
	IfInString, _hk, Esc
		StringReplace, _hk, _hk, Esc, ~Esc%A_Space%&%A_Space%, ReplaceAll
	
Return, %_hk%
}
; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------




; ------------------------------------------------------------------------------
; Où on crée la liste des applications liées
; ------------------------------------------------------------------------------
MakeListApps(inifile,tempfile){
	IfExist, %tempfile%
	{
		FileDelete, %tempfile%
	}

	list:=MakeListNoDoubleValue(inifile)

	Loop, Parse, list, |
	{
		SplitPath, A_LoopField,,,, OutNameNoExt,
		IniRead, thisapp, %tempfile%, AppsListe, %OutNameNoExt%, ERROR
		If thisapp = %A_LoopField%
		{
			Continue
		}

		If thisapp = ERROR
		{
			IniWrite, %A_LoopField%, %tempfile%, AppsListe, %OutNameNoExt%
			Continue
		}

		If thisapp <> %A_LoopField%
		{
			Loop
			{
				IniRead, thisapp2, %tempfile%, AppsListe, %OutNameNoExt%-%A_Index%, ERROR
				If thisapp2 = ERROR
				{
					IniWrite, %A_LoopField%, %tempfile%, AppsListe, %OutNameNoExt%-%A_Index%
					break
				}
			}
			Continue
		}
	}

	header = AppsListe
	list:=GetIniSectionListKey(tempfile,header)
	Return, list
}
; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------


; ------------------------------------------------------------------------------
; Où on crée la liste de toutes les clés des sections association et alternative
; du fichier de configuration cafe.ini
; ------------------------------------------------------------------------------
MakeListKey(inifile){

listprincipale:=GetIniSectionListKey(inifile,"associations")
listealternative:=GetIniSectionListKey(inifile,"alternative")

If (listprincipale = "" and listealternative != "")
{
	list = %listealternative%
}

If (listprincipale != "" and listealternative = "")
{
	list = %listprincipale%
}

If (listprincipale = "" and listealternative = "")
{
	list =
}

Else
{
	list = %listprincipale%
	Loop, parse, listealternative, |
	{
		altarray:=A_LoopField
		Loop, parse, listprincipale, |
		{
			If A_LoopField = %altarray%
			{
				controler = f
				break
			}
			controler = t
		}

		IfEqual,controler,t
		{
			list=%list%|%altarray%
		}

		IfEqual,controler,f
		{
			Continue
		}
	}
}

Return, list
}
; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------


; ------------------------------------------------------------------------------
; Où on crée la liste de toutes les valeurs des clés des sections association et
; alternative du fichier de configuration cafe.ini, en n'acceptant aucune
; redondances dans la liste
; ------------------------------------------------------------------------------
MakeListNoDoubleValue(inifile){

excepte = host

listprincipale:=GetIniSectionListNoDoubleValue(inifile,"associations",excepte)
listealternative:=GetIniSectionListNoDoubleValue(inifile,"alternative",excepte)

list=%listprincipale%

If listprincipale = 
{
	list=%listealternative%
	Return, list
}

Loop, parse, listealternative, |
{
	altarray:=A_LoopField
	Loop, parse, listprincipale, |
	{
		If A_LoopField=%altarray%
		{
			controler = 0
			break
		}
		controler = 1
	}
	IfEqual,controler,1
	{
		list=%list%|%altarray%
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

header1 = associations
listprincipale:=GetExtWithAppList(inifile,header1,value)

header2 = alternative
listealternative:=GetExtWithAppList(inifile,header2,value)

list=%listprincipale%

If listprincipale = 
{
	list=%listealternative%
	Return, list
}

Loop, parse, listealternative, |
{
	altarray:=A_LoopField
	Loop, parse, listprincipale, |
	{
		If A_LoopField = %altarray%
		{
			controler = f
			break
		}
		controler = t
	}

	IfEqual,controler,t
	{
		list=%list%|%altarray%
	}

	IfEqual,controler,f
	{
		Continue
	}
}

Return, list
}
; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------


; ------------------------------------------------------------------------------
; où on cré le menu contextuel
; ------------------------------------------------------------------------------
CreateContext(Menu_File,Menu_Name,Cafe_Menu)
{
	IniRead, path, %Menu_File%, GENERAL, url,
	path:=GetAbsMovPath(A_ScriptDir,path)
	
	loop
	{
		IniRead, type, %Menu_File%, %Menu_Name%, type-%a_index%
		ifEqual,type,error
		{
			break
		}
	
		ifEqual,type,separator
		{
			Menu,%Menu_Name%, add
		}
		
		ifEqual,type,submenu
		{
			IniRead, Sub_Name, %Menu_File%, %Menu_Name%, name-%a_index%
			Cafe_Menu:=CreateContext(Menu_File,Sub_Name,Cafe_Menu)
			Menu,%Menu_Name%,add,%Sub_Name%,:%Sub_Name%
		}
	
		ifEqual,type,menu
		{
			IniRead, Item_Name, %Menu_File%, %Menu_Name%, name-%a_index%
			Menu,%Menu_Name%,add,%Item_Name%,ContextAction
			
			IniRead, app, %Menu_File%, %Menu_Name%, app-%a_index%
			IfNotInString, app, $URL
				app:=GetAbsMovPath(A_ScriptDir,app)
			
			IniRead, cmd, %Menu_File%, %Menu_Name%, cmd-%a_index%, %A_Space%
			If ( cmd != "" and cmd != A_Space and cmd != "$F" )
				app = "%app%" %A_Space% %cmd%
			
			If ( cmd != "" and cmd != A_Space and cmd = "$F" )
				app = "%app%" %A_Space% "%cmd%"

			IniRead, hide, %Menu_File%, %Menu_Name%, hide-%a_index%, %A_Space%
			If ( hd = "true" )
				app = "%app%" %A_Space% *hide*

			StringReplace, app, app, $URL, %path%, All
			
			IniRead, filetype, %Menu_File%, %Menu_Name%, filetype-%a_index%, %A_Space%
			
			If ( Cafe_Menu = "" )
				Cafe_Menu = %Menu_Name%~%Item_Name%~%app%~%filetype%

			Else
				Cafe_Menu = %Cafe_Menu%`r`n%Menu_Name%~%Item_Name%~%app%~%filetype%
		}
		
		Else
		{
			Continue
		}
	}
Return, Cafe_Menu
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



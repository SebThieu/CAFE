CAFEGUI:
SplashImage,,  zh0 fs14 B1,, %extguisplashtext%
assocelist:=GetIniSectionListKey(inifile,"ASSOCIATIONS")
SplashImage, Off

Gui, Add, GroupBox, x126 y0 w460 h80 , %boxajout%
Gui, Add, Text, x136 y20 w440 h30 , %textajout%
Gui, Add, Edit, x136 y50 w330 h20 vSelectedFileToAsso, ;edit ajout d'extension
Gui, Add, Button, x516 y50 w60 h20 gaddfileextension, %boutonassocier% ;bouton pour créer une nouvelle association
Gui, Add, Button, x476 y50 w30 h20 gsearchfile, %boutonparcourir%
Gui, Add, GroupBox, x126 y80 w460 h180 , Liste des applications associées
Gui, Add, GroupBox, x126 y260 w460 h80 , Ajouter une application
Gui, Add, Text, x136 y100 w440 h30 , %textassociation%
Gui, Add, Edit, x136 y310 w330 h20 veditapp, ;application principale
Gui, Add, Button, x476 y310 w30 h20 vsearchappfirst gsearchappfirst, %boutonparcourir% ;bouton de rechercher application principale
Gui, Add, GroupBox, x6 y0 w110 h340 , %boxextensions%
Gui, Add, ListBox, x16 y20 w90 h280 glstextensions vlstextensions +Sort, %assocelist%
Gui, Add, Button, x16 y300 w90 h30 gdeleteassocext, %supprextension%
Gui, Add, Button, x516 y310 w60 h20 vassocapp gassocapp, %boutonok%
Gui, Add, Button, x546 y175 w30 h30 vdeleteapp gdeleteapp, X
Gui, Add, Button, x546 y130 w30 h30 vupappsec gupappsec, /\
Gui, Add, Button, x546 y220 w30 h30 vdownappsec gdownappsec, \/
Gui, Add, ListBox, x136 y130 w400 h130 vlstappsassos, 
Gui, Add, Text, x136 y280 w440 h30 , %textajout%
Gui, Add, Button, x486 y350 w100 h30 gGuiEscape, %btnquitapp%

Gui, Show,, %titregui%
Return

upappsec:
	GuiControlGet, selectitedextension,, lstextensions
	GuiControlGet, searchedfile,, lstappsassos
	If ( selectitedextension != "" and searchedfile != "" )
	{
		searchedfile:=GetRelativePath(A_ScriptFullPath,searchedfile)
		IniRead, var, %inifile%, ASSOCIATIONS, %selectitedextension%	
		Loop, Parse, var, |
		{
			If ( A_LoopField = searchedfile )
			{
				ind = %A_Index%
				Break
			}
		}

		StringSplit, app_array, var, |
		ind2 := ind - 1

		searchtext := app_array%ind2% . "|" . app_array%ind%
		replacetext := app_array%ind% . "|" . app_array%ind2%

		StringReplace, var, var, %searchtext%, %replacetext%, all
		IniWrite, %var%, %inifile%, ASSOCIATIONS, %selectitedextension%
		Gosub, lstextensions
	}
GuiControl, Choose,lstappsassos,%ind2%
Return

downappsec:
	GuiControlGet, selectitedextension,, lstextensions
	GuiControlGet, searchedfile,, lstappsassos
	If ( selectitedextension != "" and searchedfile != "" )
	{
		searchedfile:=GetRelativePath(A_ScriptFullPath,searchedfile)
		IniRead, var, %inifile%, ASSOCIATIONS, %selectitedextension%
		Loop, Parse, var, |
		{
			If ( A_LoopField = searchedfile )
			{
				ind = %A_Index%
				Break
			}
		}

		StringSplit, app_array, var, |
		ind2 := ind + 1

		searchtext := app_array%ind% . "|" . app_array%ind2%
		replacetext := app_array%ind2% . "|" . app_array%ind%

		StringReplace, var, var, %searchtext%, %replacetext%, all
		IniWrite, %var%, %inifile%, ASSOCIATIONS, %selectitedextension%
		Gosub, lstextensions
	}
GuiControl, Choose,lstappsassos,%ind2%
Return

; on va chercher un fichier dont on veut associer l'extension
searchfile:
	FileSelectFile, searchedfile, 3, ::{20d04fe0-3aea-1069-a2d8-08002b30309d}, %titreselectionfichier%, %toustypes% (*.*)
	if not searchedfile  ; The user canceled the dialog.
		return
	GuiControl, , SelectedFileToAsso, %searchedfile%
return

; on ajoute l'extension à la liste
addfileextension:
; on recupère l'extension à associer
GuiControlGet, searchedfile,, SelectedFileToAsso
if not searchedfile
	return
SplitPath, searchedfile,,, extension
;on vérifie si l'entré principale existe
StringSplit, ext_array, assocelist,|,
	Loop, %ext_array0%
	{
		extarray:=ext_array%a_index%
		If extarray=%extension%
		{
			MsgBox, %extensionexistante%
			Return
		}
		If ErrorLevel
		{
			MsgBox, %erreurextension%
			Return
		}
		Else
		{
			Continue
		}
	}
	GuiControl,, lstextensions,%extension%
	assocelist=%assocelist%|%extension%
	Gosub, lstextensions
	GuiControl, Choose, lstextensions,%extension%
Return

; on selectionne une entrée de la liste, alors on dégrise les boutons et les Edits
lstextensions:
GuiControlGet, selectitedextension,, lstextensions
IniRead, readedappfirst, %inifile%, ASSOCIATIONS, %selectitedextension%, 0
If ( readedappfirst != "0" )
{
	If ( readedappfirst and readedappfirst <> "host" )	
		readedappfirst:=GetAbsMovPath(A_ScriptDir,readedappfirst)

	GuiControl,, lstappsassos, |%readedappfirst%
}
Else
	GuiControl,, lstappsassos, |%A_Space%
Return

; on va chercher l'application pricincipale
searchappfirst:
	FileSelectFile, searchedfile, 3, %appspath%, %titreselectionapplication%, %typeapplication% (*.exe;*.cmd;*.bat)
	if not searchedfile  ; The user canceled the dialog.
		return
	GuiControl, , editapp, %searchedfile%
return

assocapp:
	GuiControlGet, selectitedextension,, lstextensions
	GuiControlGet, searchedfile,, editapp
	If ( selectitedextension != "" and searchedfile != "" )
	{
		searchedfile:=GetRelativePath(A_ScriptFullPath,searchedfile)
		IniRead, var, %inifile%, ASSOCIATIONS, %selectitedextension%, 0
		
		n = "0"
		Loop, Parse, var, |
		{
			If ( A_LoopField = searchedfile )
				n = "1"
		}
		
		If ( n != "1" )
		{
			If ( var != "0" )
				IniWrite, %var%|%searchedfile%, %inifile%, ASSOCIATIONS, %selectitedextension%
			Else
				IniWrite, %searchedfile%, %inifile%, ASSOCIATIONS, %selectitedextension%
		}
		Gosub, lstextensions
	}
	GuiControl,, editapp
Return


; on efface l'association pricipale
deleteapp:
	GuiControlGet, selectitedextension,, lstextensions
	GuiControlGet, searchedfile,, lstappsassos
	If ( selectitedextension != "" and searchedfile != "" )
	{
		searchedfile:=GetRelativePath(A_ScriptFullPath,searchedfile)
		IniRead, var1, %inifile%, ASSOCIATIONS, %selectitedextension%
		var =
		Loop, Parse, var1, |
		{
			If ( A_LoopField != searchedfile )
			{
				If ( var = "" )
					var = %A_LoopField%
				Else
					var = %var%|%A_LoopField%
			}
		}
		
		If ( var != "" )
		{
			IniWrite, %var%, %inifile%, ASSOCIATIONS, %selectitedextension%
			Gosub, lstextensions
		}
		Else
			Gosub, deleteassocext
	}
Return


; on efface l'association
deleteassocext:
	GuiControlGet, selectitedextension,, lstextensions
	IniDelete, %inifile%, ASSOCIATIONS, %selectitedextension%
	assocelist:=GetIniSectionListKey(inifile,"ASSOCIATIONS")
	GuiControl, , lstextensions, |%assocelist%
	Gosub, lstextensions
return

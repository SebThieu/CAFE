

CAFEGUI:
SplashImage,,  zh0 fs14 B1,, %extguisplashtext%
assocelist:=MakeListKey(inifile)
SplashImage, Off

;~ Gui, -SysMenu 
Gui, Add, GroupBox, x6 y0 w460 h80 , %boxajout%
Gui, Add, Text, x16 y15 w440 h30 , %textajout%
Gui, Add, Edit, x16 y50 w330 h20 vSelectedFileToAsso, ;edit ajout d'extension
Gui, Add, Button, x396 y50 w60 h20 gaddfileextension, %boutonassocier% ;bouton pour créer une nouvelle association
Gui, Add, Button, x356 y50 w30 h20 gsearchfile, %boutonparcourir%
Gui, Add, GroupBox, x126 y80 w340 h250 , %boxapplications%
Gui, Add, GroupBox, x136 y140 w320 h90 , %boxprincipale%
Gui, Add, Edit, x146 y160 w260 h20 veditappfirst +Disabled, ;application principale
Gui, Add, Button, x416 y160 w30 h20 vsearchappfirst gsearchappfirst +Disabled, %boutonparcourir% ;bouton de rechercher application principale
Gui, Add, GroupBox, x136 y230 w320 h90 , %boxsecondaire%
Gui, Add, Text, x136 y100 w320 h30 , %textassociation%
Gui, Add, Edit, x146 y250 w260 h20 veditappsecond +Disabled, ;application principale
Gui, Add, Button, x416 y250 w30 h20 vsearchappsec gsearchappsec +Disabled, %boutonparcourir% ;bouton de rechercher application secondaire
Gui, Add, GroupBox, x6 y80 w110 h250 , %boxextensions%

Gui, Add, ListBox, x16 y100 w90 h214 glstextensions vlstextensions +Sort, %assocelist%
Gui, Add, Button, x6 y335 w110 h30 gdeleteassocext, %supprextension%
Gui, Add, Button, x266 y190 w130 h30 vdeleteappfirst gdeleteappfirst +Disabled, %supprassoc%
Gui, Add, Button, x266 y280 w130 h30 vdeleteappsec gdeleteappsec +Disabled, %supprassoc%
Gui, Add, Button, x406 y190 w40 h30 vassocappfirst gassocappfirst +Disabled, %boutonok%
Gui, Add, Button, x406 y280 w40 h30 vassocappsec gassocappsec +Disabled, %boutonok%

Gui, Add, Button, x360 y335 w100 h30 gGuiEscape, %boutonquitter%

Gui, Show,, %titregui%
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
		}
		Else If ErrorLevel
		{
			MsgBox, %erreurextension%
		}
		Else
		{
			Continue
		}
	}
	GuiControl, , lstextensions,%extension%
	assocelist=%assocelist%|%extension%
	Goto, lstextensions
	GuiControl, Choose, lstextensions,%extension%
Return
; ###############################################

; on selectionne une entrée de la liste, alors on dégrise les boutons et les Edits
lstextensions:
GuiControl, Enable, editappfirst
GuiControl, Enable, editappsecond
GuiControl, Enable, searchappsec
GuiControl, Enable, searchappfirst
GuiControl, Enable, deleteappfirst
GuiControl, Enable, deleteappsec

GuiControlGet, selectitedextension,, lstextensions
IniRead, readedappfirst, %inifile%, associations, %selectitedextension%, %A_Space%
If ( readedappfirst and readedappfirst <> "host" )
	readedappfirst:=GetAbsMovPath(A_ScriptDir,readedappfirst)
 
IniRead, readedappsec, %inifile%, alternative, %selectitedextension%, %A_Space%
If ( readedappsec and readedappsec <> "host" )
	readedappsec:=GetAbsMovPath(A_ScriptDir,readedappsec)

GuiControl, , editappfirst, %readedappfirst%
GuiControl, , editappsecond, %readedappsec%

GuiControl, Enable, assocappfirst
GuiControl, Enable, assocappsec
return

; on va chercher l'application pricincipale
searchappfirst:
	FileSelectFile, searchedfile, 3, %appspath%, %titreselectionapplication%, %typeapplication% (*.exe;*.cmd;*.bat)
	if not searchedfile  ; The user canceled the dialog.
		return
	GuiControl, , editappfirst, %searchedfile%
return

; on va chercher l'application secondaire
searchappsec:
	FileSelectFile, searchedfile, 3, %appspath%, %titreselectionapplication%, %typeapplication% (*.exe`;*.cmd`;*.bat)
	if not searchedfile  ; The user canceled the dialog.
		return
	GuiControl, , editappsecond, %searchedfile%
return

; on écrit le chemin vers l'application pricinpale
assocappfirst:
	GuiControlGet, selectitedextension,, lstextensions
	GuiControlGet, searchedfile,, editappfirst
	if not searchedfile
		return
	searchedfile:=GetRelativePath(A_ScriptFullPath,searchedfile)
	IniWrite, %searchedfile%, %inifile%, associations, %selectitedextension%
return

; on écrit le chemin vers l'application secondaire
assocappsec:
	GuiControlGet, selectitedextension,, lstextensions
	GuiControlGet, searchedfile,, editappsecond
	if not searchedfile
		return
	searchedfile:=GetRelativePath(A_ScriptFullPath,searchedfile)
	IniWrite, %searchedfile%, %inifile%, alternative, %selectitedextension%
return

; on efface l'association pricipale
deleteappfirst:
	GuiControlGet, selectitedextension,, lstextensions
	IniDelete, %inifile%, associations, %selectitedextension%

	IniRead, readedappfirst, %inifile%, associations, %selectitedextension%, %A_Space%
	If ( readedappfirst and readedappfirst <> "host" )
		readedappfirst:=GetAbsMovPath(A_ScriptDir,readedappfirst)
	GuiControl, , editappfirst, %readedappfirst%
	
; ################################
assocelist:=MakeListKey(inifile)
GuiControl, , lstextensions, |%assocelist%
; ################################		

return

; on efface l'association secondaire
deleteappsec:
	GuiControlGet, selectitedextension,, lstextensions
	IniDelete, %inifile%, alternative, %selectitedextension%

	IniRead, readedappsec, %inifile%, alternative, %selectitedextension%, %A_Space%
	If ( readedappsec and readedappsec <> "host" )
		readedappsec:=GetAbsMovPath(A_ScriptDir,readedappsec)
	GuiControl, , editappsecond, %readedappsec%

; ################################
assocelist:=MakeListKey(inifile)
GuiControl, , lstextensions, |%assocelist%
; ################################

return

; on efface l'association
deleteassocext:
	GuiControlGet, selectitedextension,, lstextensions
	IniDelete, %inifile%, associations, %selectitedextension%
	IniDelete, %inifile%, alternative, %selectitedextension%

	IniRead, readedappfirst, %inifile%, associations, %selectitedextension%, %A_Space%
	If ( readedappfirst and readedappfirst <> "host" )
		readedappfirst:=GetAbsMovPath(A_ScriptDir,readedappfirst)
	GuiControl, , editappfirst, %readedappfirst%

	IniRead, readedappsec, %inifile%, alternative, %selectitedextension%, %A_Space%
	If ( readedappsec and readedappsec <> "host" )
		readedappsec:=GetAbsMovPath(A_ScriptDir,readedappsec)
	GuiControl, , editappsecond, %readedappsec%

; ################################
assocelist:=MakeListKey(inifile)
GuiControl, , lstextensions, |%assocelist%
; ################################

return
#NoEnv
SendMode Input
#SingleInstance, force
#Include %A_ScriptDir%
#Include library.ahk
#Include peru_library.ahk
Process, Priority,,H

inifile = peru.ini

f = %A_ScriptDir%\peru.ini

SplitPath, f, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive

IniRead, readedapp, %inifile%, ASSOCIATIONS, %OutExtension%, 0
If ( readedapp != "0" )
{
	If ( readedapp and readedapp <> "host" )	
		readedapp:=GetAbsMovPath(A_ScriptDir,readedapp)

	list = %readedapp%
}
Else
{
	list = %A_Space%
}

FileGetSize, size, %f%, K
FileGetTime, lastaccess, %f%, A
FormatTime, lastaccess, %lastaccess%, dddd d MMMM yyyy  HH:mm:ss
FileGetTime, lastmod, %f%, M
FormatTime, lastmod, %lastmod%, dddd d MMMM yyyy  HH:mm:ss
FileGetTime, creat, %f%, C
FormatTime, creat, %creat%, dddd d MMMM yyyy  HH:mm:ss

Gui, Add, Button, x366 y416 w100 h30 gGuiClose, Fermer
Gui, Add, Tab, x6 y6 w460 h400 , Général|Ouvrir avec
Gui, Tab, Général
Gui, Add, Text, x26 y46 w100 h20 , Nom :
Gui, Add, Text, x26 y76 w100 h20 , Type :
Gui, Add, Text, x26 y166 w100 h20 , Taille :
Gui, Add, Text, x26 y136 w100 h20 , Emplacement :
Gui, Add, Text, x26 y256 w110 h20 , Dernier accès :
Gui, Add, Text, x26 y286 w110 h20 , Dernière modification :
Gui, Add, Text, x26 y226 w110 h20 , Date de création :
Gui, Add, Text, x146 y76 w300 h20 , %OutExtension%
Gui, Add, Text, x146 y136 w300 h20 , %OutDir%
Gui, Add, Text, x146 y256 w300 h20 , %lastaccess%
Gui, Add, Text, x146 y286 w300 h20 , %lastmod%
Gui, Add, Text, x146 y226 w300 h20 , %creat%
Gui, Add, Edit, x146 y46 w300 h20 , %OutFileName%
Gui, Add, Text, x146 y166 w300 h20 , %size% Ko
Gui, Add, Text, x26 y346 w110 h20 , Attributs :
Gui, Add, CheckBox, x146 y346 w90 h20 , Lecture seule
Gui, Add, CheckBox, x246 y346 w90 h20 , Fichier caché
Gui, Add, CheckBox, x346 y346 w90 h20 , Archive
Gui, Add, GroupBox, x16 y26 w440 h90
Gui, Add, GroupBox, x16 y116 w440 h90
Gui, Add, GroupBox, x16 y206 w440 h120
Gui, Add, GroupBox, x16 y326 w440 h60

Gui, Tab, Ouvrir avec
Gui, Add, Text, x16 y46 w440 h60 , Sélectionnez une application pour ouvrir %OutFileName% et les autres fichiers de même type: %OutExtension%
Gui, Add, ListBox, x16 y116 w440 h210 vlstappsassos, |%list%
Gui, Add, Button, x356 y356 w100 h30 , - Enlever
Gui, Add, Button, x236 y356 w100 h30 , + Ajouter

Gui, Show,
Return

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





GuiClose:
ExitApp
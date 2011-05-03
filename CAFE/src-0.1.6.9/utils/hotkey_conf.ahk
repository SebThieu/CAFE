#Include %A_ScriptDir%
#Include ..\library.ahk
#Include ..\cafe_library.ahk
#Include ..\AHKArray.ahk

SetWorkingDir,%A_ScriptDir%

inifile = cafe.ini

Gui, Add, Text, w460 h20 , Ajouter un raccoucis clavier
Gui, Add, Edit, y+5 w320 h20 ,
Gui, Add, Button, x+10 w30 h20 , ...
Gui, Add, Button, x+10 w90 h20 , Ajouter
Gui, Add, ListView, xm r20 w460 gwritehotkey +Sort -Multi NoSortHdr Grid HwndLV_ID, Commande|Raccourcis clavier
	{
	list:=GetIniSectionListKey(inifile,"HOTKEY")
	Loop, Parse, list, |
		{
		StringReplace, hk, A_LoopField, ``#, #
		IniRead, cmd, %inifile%, HOTKEY, %A_LoopField%
				
		; SplitPath, A_ScriptDir,,,,, root
		; StringReplace, cmd, cmd, $Root, %root%, All
		
		cmd:=GetAbsMovPath(A_ScriptDir,cmd)
		
		LV_Add("", cmd, hk)
		}
	LV_ModifyCol(1)
	}
Gui, Add, Button, y+5 x260 w100 h30 gGuiClose, Quitter
Gui, Add, Button, x+10 w100 h30 , Ok
Gui, Show
Return

writehotkey:
LV_GetText(selectitedcmd, A_EventInfo)
InputBox, thishotkey, C.A.F.E.|HOTKEY, Veuillez indiquer quel raccourcis vous souhaitez utiliser pour lancer la commande : `n`t"%selectitedcmd%",,, 160
LV_Modify(2, %thishotkey%)
return

GuiClose:
ExitApp

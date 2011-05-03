#Include library.ahk
#Include peru_library.ahk

inifile = peru.ini


MenuConfig:
Gui, Add, GroupBox, x6 y6 w340 h340 +Center, Menu contextuel
Gui, Add, TreeView, x16 y26 w320 h310 gshow
MakeMenu(inifile,"CONTEXT","")
Gui, Add, GroupBox, x356 y76 w60 h190 +Center, 
Gui, Add, Button, x366 y96 w40 h30 , /\
Gui, Add, Button, x366 y136 w40 h30 , +
Gui, Add, Button, x366 y176 w40 h30 , X
Gui, Add, Button, x366 y216 w40 h30 , \/
Gui, Add, GroupBox, x426 y6 w550 h340 +Center, Informations sur l'entrée
Gui, Add, GroupBox, x436 y96 w530 h70 , Action
Gui, Add, Edit, x576 y41 w380 h20 vedit1, 
Gui, Add, GroupBox, x436 y21 w530 h70 , Element du menu
Gui, Add, Edit, x576 y116 w340 h20 vedit2, 
Gui, Add, Button, x916 y116 w40 h20 vselect, ...
Gui, Add, Text, x446 y61 w130 h20 , Type d'entrée :
Gui, Add, DropDownList, x576 y61 w380 h21 R3 vdroptype, Menu|Submenu|Separator
Gui, Add, Edit, x496 y306 w90 h20 vindex ReadOnly, Edit
Gui, Add, Edit, x496 y326 w90 h20 vmenu ReadOnly, Edit
Gui, Add, Text, x446 y306 w50 h20 , Index
Gui, Add, Text, x446 y326 w50 h20 , Menu
Gui, Add, Button, x806 y311 w60 h30 gChangeMenu, OK
Gui, Add, Text, x446 y41 w130 h20 , Etiquette :
Gui, Add, Text, x446 y116 w130 h20 , Chemin :
Gui, Add, Text, x446 y136 w130 h20 , Paramètres :
Gui, Add, Edit, x576 y136 w340 h20 , 
Gui, Add, Button, x916 y136 w40 h20 , ?
Gui, Add, Button, x876 y311 w90 h30 gGuiClose, Quitter
Gui, Add, GroupBox, x436 y176 w530 h50 , Apparaît si le fichier contient
Gui, Add, Text, x446 y196 w130 h20 , Extensions :
Gui, Add, Edit, x576 y196 w340 h20 vlistm_ext, 
Gui, Add, Button, x916 y196 w40 h20 , ?
Gui, Add, GroupBox, x436 y236 w530 h70 , Apparaît si la sélection contient
Gui, Add, Radio, x446 y256 w170 h20 , Seulement des fichiers
Gui, Add, Radio, x616 y256 w170 h20 , Seulements des dossiers
Gui, Add, Radio, x786 y256 w170 h20 , Les deux
Gui, Add, CheckBox, x446 y276 w510 h20 , Apparaît si la sélection contient plusieurs fichiers ou dossiers
Gui, Show,, New GUI Window
Return

GuiClose:
ExitApp

ChangeMenu:
GuiControlGet, n_name,, edit1
GuiControlGet, n_cmd,, edit2

n_cmd:=GetRelativePath(A_ScriptDir,n_cmd)

If ( var != n_name )
{
	IniDelete, %inifile%, %parent%, %var%
	IniWrite, %n_name%, %inifile%, %parent%, name-%count%
}

IniWrite, %n_cmd%, %inifile%, %parent%, %n_name%

TV_Delete()
MakeMenu(inifile,"CONTEXT","")

Return



show:
GuiControl,+Disabled, droptype
GuiControl,, index, %count%
GuiControl,, menu,

itemid:=TV_GetSelection()
TV_GetText(var, itemid)
pid:=TV_GetParent(itemid)
TV_GetText(parent, pid)
If ( parent = "" )
	parent = CONTEXT

IniRead, cmd, %inifile%, %parent%, %var%, %A_Space%

If ( var = "--------------------" )
{
	previtem:=TV_GetPrev(itemid)
	TV_GetText(var1, previtem)
	count:=FindIndex(inifile,parent,var1)
	++count
}
Else
{
	count:=FindIndex(inifile,parent,var)
}


IniRead, listext, %inifile%, %parent%, filetype-%count%, %A_Space%
IniRead, type, %inifile%, %parent%, type-%count%, %A_Space%

If (type = "separator" )
{
	GuiControl,+Disabled, edit1
	GuiControl,+Disabled, edit2
	GuiControl,+Disabled, select
}
Else If (type = "submenu" )
{
	GuiControl,-Disabled, edit1
	GuiControl,+Disabled, edit2
	GuiControl,+Disabled, select
}
Else If (type = "menu" )
{
	GuiControl,-Disabled, edit1
	GuiControl,-Disabled, edit2
	GuiControl,-Disabled, select	
}


cmd:=GetAbsMovPath(A_ScriptDir,cmd)
GuiControl,, edit1, %var%
GuiControl,, edit2, %cmd%
GuiControl,, listm_ext, |%listext%
GuiControl,, edit, %cmd%
GuiControl, Choose, droptype, %type%

GuiControl,, index, %count%
GuiControl,, menu, %parent%
Return


FindIndex(inifile,section,searchitem){
	Loop
	{
		IniRead, type, %inifile%, %section%, type-%A_Index%, ERROR
		
		If ( type = "ERROR" )
		{
			Break
		}
		
		IniRead, name, %inifile%, %section%, name-%A_Index%, ERROR
		If ( ( type = "menu" or type = "submenu" ) and name = searchitem )
		{
			count := A_Index
			Break
		}
	}
Return, count
}

MakeMenu(inifile,Section,P_Item){
	Loop
	{
		IniRead, type, %inifile%, %Section%, type-%a_index%
		IniRead, Item_Name, %inifile%, %Section%, name-%a_index%
		
		If ( type = "ERROR" or type = "" )
		{
			break
		}

		Else If ( type = "separator" )
		{
			TV_Add("--------------------",P_Item)
		}
		
		Else If ( type = "menu" )
		{
			TV_Add(Item_Name,P_Item)
		}
	
		Else If ( type = "submenu" )
		{
			id := TV_Add(Item_Name,P_Item)
			MakeMenu(inifile,Item_Name,id)
			TV_Modify(id, "Expand")
		}
	}
}

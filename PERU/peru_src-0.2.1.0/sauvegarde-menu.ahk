#Include library.ahk
#Include peru_library.ahk

inifile = peru.ini


MenuConfig:
Gui, Add, GroupBox, x6 y6 w260 h320 +Center, Menu contextuel
Gui, Add, TreeView, x16 y26 w240 h290 gshow -Buttons
MakeMenu(inifile,"CONTEXT","")
Gui, Add, GroupBox, x276 y76 w60 h190 +Center, 
Gui, Add, Button, x286 y96 w40 h30 , /\
Gui, Add, Button, x286 y136 w40 h30 , +
Gui, Add, Button, x286 y176 w40 h30 , X
Gui, Add, Button, x286 y216 w40 h30 , \/
Gui, Add, GroupBox, x346 y6 w380 h320 +Center, Informations sur l'entrée
Gui, Add, Text, x356 y116 w360 h20 , Action de l'entrée
Gui, Add, Edit, x356 y96 w360 h20 vedit1
Gui, Add, Text, x356 y26 w360 h70 , Nom de l'entrée
Gui, Add, Edit, x356 y136 w330 h20 vedit2
Gui, Add, Button, x686 y136 w30 h20 vselect, ...
Gui, Add, Text, x356 y166 w80 h20 , Type d'entrée
Gui, Add, DropDownList, x356 y186 w80 h20 R3 vdroptype, Menu|Submenu|Separator
Gui, Add, ListBox, x646 y166 w70 h130 vlistm_ext Center,
Gui, Add, Button, x646 y296 w70 h20 , Supprimer

Gui, Add, Edit, x406 y226 w90 h20 vindex ReadOnly, Edit
Gui, Add, Edit, x406 y256 w90 h20 vmenu ReadOnly, Edit
Gui, Add, Text, x356 y226 w50 h20 , Index
Gui, Add, Text, x356 y256 w50 h20 , Menu

Gui, Add, Button, x516 y286 w60 h30 gChangeMenu, OK

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

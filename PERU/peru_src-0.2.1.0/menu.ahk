#Include library.ahk
#Include peru_library.ahk
#Include peru_lang.ahk
inifile = peru.ini
IniRead, appspath, %inifile%, configuration, appspath, %A_ScriptDir%
appspath:=GetAbsMovPath(A_ScriptDir,appspath)
   
   
;~ #########################################################################
;~ #########################################################################

MenuConfig:
Gui, Add, GroupBox, x6 y6 w480 h340 +Center, Menu contextuel
    Gui, Add, TreeView, x16 y26 w456 h310 gGM_Show_Sel_Item,
    MakeMenu("CONTEXT","")

Gui, Add, GroupBox, x496 y76 w60 h190 +Center,
    Gui, Add, Button, x506 y96 w40 h30 gGM_Up_Item, /\
    Gui, Add, Button, x506 y136 w40 h30 gGM_Add_Item, +
    Gui, Add, Button, x506 y176 w40 h30 gGM_Rmv_Item, X
    Gui, Add, Button, x506 y216 w40 h30 gGM_Down_Item, \/

Gui, Add, GroupBox, x6 y356 w550 h350 +Center, Informations sur l'entrée
    Gui, Add, GroupBox, x16 y371 w530 h70 , Element du menu
        Gui, Add, Text, x26 y391 w130 h20 , Etiquette :
        Gui, Add, Edit, x156 y391 w380 h20 vMenu_Name,

        Gui, Add, Text, x26 y411 w130 h20 , Type d'entrée :
        Gui, Add, DropDownList, x156 y411 w380 h21 R3 vMenu_Type, Menu|Submenu|Separator

    Gui, Add, GroupBox, x16 y446 w530 h70 , Action
        Gui, Add, Text, x26 y466 w130 h20 , Chemin :
        Gui, Add, Edit, x156 y466 w340 h20 vMenu_App_Path,
        Gui, Add, Button, x496 y466 w40 h20 vMenu_Sel_App gGM_Sel_App, ...

;~         Gui, Add, Text, x26 y486 w130 h20 , Paramètres :
;~         Gui, Add, Edit, x156 y486 w340 h20 vMenu_Param,
;~         Gui, Add, Button, x496 y486 w40 h20 gGM_Info_Param, ?

    Gui, Add, GroupBox, x16 y526 w530 h50 , Apparaît si le fichier contient
        Gui, Add, Text, x26 y546 w130 h20 , Extensions :
        Gui, Add, Edit, x156 y546 w340 h20 vMenu_File_Type,
        Gui, Add, Button, x496 y546 w40 h20 gGM_Info_Extt, ?

    Gui, Add, GroupBox, x16 y586 w530 h70 , Apparaît si la sélection contient
        Gui, Add, Radio, x26 y606 w150 h20 gGM_Enabe_Multi, Seulement des fichiers
        Gui, Add, Radio, x186 y606 w150 h20 gGM_Enabe_Multi, Seulements des dossiers
        Gui, Add, Radio, x346 y606 w80 h20 gGM_Enabe_Multi, Les deux
        Gui, Add, Radio, x436 y606 w100 h20 gGM_Disable_Multi, Aucun des deux
        Gui, Add, CheckBox, x26 y626 w510 h20 vcheckmulti, Apparaît si la sélection contient plusieurs fichiers ou dossiers

    Gui, Add, Button, x386 y666 w60 h30 gGM_Change_Menu, OK
    Gui, Add, Button, x456 y666 w90 h30 gGuiClose , Quitter

Gui, Add, Edit, x76 y656 w90 h20 vindex ReadOnly, Edit
Gui, Add, Edit, x76 y676 w90 h20 vmenu ReadOnly, Edit
Gui, Add, Text, x26 y656 w50 h20 , Index
Gui, Add, Text, x26 y676 w50 h20 , Menu

Gui, Show,, New GUI Window
Return

GuiClose:
ExitApp

GM_Enabe_Multi:
GuiControl,-Disabled, checkmulti
Return

GM_Disable_Multi:
GuiControl, +Disabled, checkmulti
GuiControl,, checkmulti, 0
Return

GM_Sel_App:
FileSelectFile, newpath, 3, %appspath%, %titreselectionapplication%, %typeapplication% (*.exe`;*.cmd`;*.bat)
If newpath
	GuiControl,, Menu_App_Path, %newpath%
Return

GM_Add_Item:
GuiControl,, Menu_Name
GuiControl, -Disabled, Menu_Name
GuiControl, -Disabled, Menu_Type
GuiControl,, Menu_App_Path
GuiControl, -Disabled, Menu_App_Path
GuiControl,, Menu_Param
GuiControl, -Disabled, Menu_Param
GuiControl, -Disabled, Menu_Sel_App
GuiControl,, Menu_File_Type
GuiControl, -Disabled, Menu_File_Type
Return

GM_Up_Item:
ParentIndex()
IniRead, type, %inifile%, %parent%, type-%index%, %A_Space%
IniRead, name, %inifile%, %parent%, name-%index%, %A_Space%
IniRead, filetype, %inifile%, %parent%, type-%index%, %A_Space%

index2 := --index

;~ msgbox, %index2%

IniRead, type2, %inifile%, %parent%, type-%index2%, %A_Space%
IniRead, name2, %inifile%, %parent%, name-%index2%, %A_Space%
IniRead, filetype2, %inifile%, %parent%, type-%index2%, %A_Space%

IniWrite, type, %inifile%, %parent%, type-%index2%
IniWrite, name, %inifile%, %parent%, name-%index2%
IniWrite, filetype, %inifile%, %parent%, type-%index2%

IniWrite, type2, %inifile%, %parent%, type-%index%
IniWrite, name2, %inifile%, %parent%, name-%index%
IniWrite, filetype2, %inifile%, %parent%, type-%index%

TV_Delete()
MakeMenu("CONTEXT","")

Return

GM_Down_Item:
ParentIndex()
IniRead, type, %inifile%, %parent%, type-%index%, %A_Space%
IniRead, name, %inifile%, %parent%, name-%index%, %A_Space%
IniRead, filetype, %inifile%, %parent%, type-%index%, %A_Space%

index2 := ++index

;~ msgbox, %index2%

IniRead, type2, %inifile%, %parent%, type-%index2%, %A_Space%
IniRead, name2, %inifile%, %parent%, name-%index2%, %A_Space%
IniRead, filetype2, %inifile%, %parent%, type-%index2%, %A_Space%

IniWrite, type, %inifile%, %parent%, type-%index2%
IniWrite, name, %inifile%, %parent%, name-%index2%
IniWrite, filetype, %inifile%, %parent%, type-%index2%

IniWrite, type2, %inifile%, %parent%, type-%index%
IniWrite, name2, %inifile%, %parent%, name-%index%
IniWrite, filetype2, %inifile%, %parent%, type-%index%

TV_Delete()
MakeMenu("CONTEXT","")

Return

GM_Rmv_Item:
MsgBox, GM_Rmv_Item
Return

GM_Info_Extt:
MsgBox, info extensions
Return

GM_Info_Param:
MsgBox, info parametres
Return

GM_Change_Menu:
GuiControlGet, n_name,, Menu_Name
GuiControlGet, n_filetype,, Menu_File_Type
GuiControlGet, state, Enabled, Menu_File_Type

If ( state = "0" )
{
    GuiControlGet, n_cmd,, Menu_App_Path

    n_cmd:=GetRelativePath(A_ScriptDir,n_cmd)

    If ( etiquette != n_name )
    {
        IniDelete, %inifile%, %parent%, %etiquette%
        IniWrite, %n_name%, %inifile%, %parent%, name-%index%
    }

    IniWrite, %n_cmd%, %inifile%, %parent%, %n_name%
}

Else If ( state = "1" )
{
    GuiControlGet, n_type,, Menu_Type
    ParentIndex()

    IniRead, i_type, %inifile%, %parent%, type-%index%, %A_Space%

    ++index

    If ( n_type = "Menu" )
    {
        GuiControlGet, n_cmd,, Menu_App_Path
        IniWrite, %n_cmd%, %inifile%, %parent%, %n_name%
    }
    Else If ( n_type = "Separator" )
    {
        n_name =
    }

    Loop
    {
        IniRead, type, %inifile%, %parent%, type-%index%, %A_Space%
        IniRead, name, %inifile%, %parent%, name-%index%, %A_Space%
        IniRead, filetype, %inifile%, %parent%, type-%index%, %A_Space%
        
        If ( n_type = "Submenu" )
        {
            IniRead, s_type, %inifile%, %n_name%, type-1, %A_Space%
            If ( s_type = "" or s_type = A_Space )
            {
                IniWrite, Menu, %inifile%, %n_name%, type-1
                IniWrite, %A_Space%, %inifile%, %n_name%, name-1
            }
        }
                
        IniWrite, %n_type%, %inifile%, %parent%, type-%index%
        If ( n_name != "" )
            IniWrite, %n_name%, %inifile%, %parent%, name-%index%   
        IniWrite, %n_filetype%, %inifile%, %parent%, filetype-%index%

        If ( type = "" )
            Break

        n_type =  %type%
        n_name = %name%
        n_type = %filetype%

        ++index
    }
}

Return


GM_Show_Sel_Item:
;~ pas forcement utiles
GuiControl,, Menu_Name
GuiControl, -Disabled, Menu_Name
GuiControl, +Disabled, Menu_Type
GuiControl,, Menu_App_Path
GuiControl, -Disabled, Menu_App_Path
GuiControl,, Menu_Param
GuiControl, -Disabled, Menu_Param
GuiControl, -Disabled, Menu_Sel_App
GuiControl,, Menu_File_Type
GuiControl, -Disabled, Menu_File_Type
;~ ######################################


;~ # à retirer
GuiControl,, index, %index%
GuiControl,, menu,
;~ ##########

ParentIndex()

IniRead, listext, %inifile%, %parent%, filetype-%index%, %A_Space%
IniRead, type, %inifile%, %parent%, type-%index%, %A_Space%

If (type = "separator" )
{
    GuiControl,+Disabled, Menu_Name
    GuiControl,+Disabled, Menu_App_Path
    GuiControl,+Disabled, Menu_Sel_App
}
Else If (type = "submenu" )
{
    GuiControl,-Disabled, Menu_Name
    GuiControl,+Disabled, Menu_App_Path
    GuiControl,+Disabled, Menu_Sel_App
}
Else If (type = "menu" )
{
    GuiControl,-Disabled, Menu_Name
    GuiControl,-Disabled, Menu_App_Path
    GuiControl,-Disabled, Menu_Sel_App
}

IniRead, cmd, %inifile%, %parent%, %etiquette%, %A_Space%
cmd:=GetAbsMovPath(A_ScriptDir,cmd)

GuiControl,, Menu_Name, %etiquette%
GuiControl,, Menu_App_Path, %cmd%
GuiControl,, Menu_File_Type, |%listext%
GuiControl,, edit, %cmd%
GuiControl, Choose, Menu_Type, %type%

;~ # à retirer
GuiControl,, index, %index%
GuiControl,, menu, %parent%
;~ #########
Return


ParentIndex(){
    global inifile, index, parent, etiquette
    
    itemid:=TV_GetSelection()
    TV_GetText(etiquette, itemid)
    pid:=TV_GetParent(itemid)
    TV_GetText(parent, pid)
    If ( parent = "" )
        parent = CONTEXT

    If ( etiquette = "--------------------" )
    {
        previtem:=TV_GetPrev(itemid)
        TV_GetText(etiquette1, previtem)
        FindIndex(parent,etiquette1)
        ++index
    }
    Else
    {
        FindIndex(parent,etiquette)
    }
}

FindIndex(section,searchitem){
    global inifile, index
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
            index := A_Index
            Break
        }
    }
}

MakeMenu(Section,P_Item){
    global inifile
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
            MakeMenu(Item_Name,id)
            TV_Modify(id, "Expand")
        }
    }
}

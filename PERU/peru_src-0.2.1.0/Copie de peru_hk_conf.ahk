
HK_Gui:
indlist = 1,2,3,4,5,6,7,8,9,10,11
indm = 12

Gui,Add, ListView, x10 y10 w460 h260 gLoad_HK vListViewItem, %hkacthk%
GoSub, HK_List
Gui,Add, Text, x6 y280 w240 h20 , %hkdblonline%
Gui,Add, Text, x10 y310 h20 , %hkhotkey%`t
Gui,Add, Edit, x+10 y310 w90 h20 vChosenHotkey, 
Gui,Add, Text, x10 y335 h20 , %hkaction%`t`t
Gui,Add, Edit, x+10 y335 w280 h20 vAct, 
Gui,Add, Button, x+10 y335 w30 h20 gSelect_Act vSelect_Act, *.*
Gui,Add, Button, x+10 y335 w30 h20 gSelect_Dir vSelect_Dir, \
Gui,Add, Button, x10 y370 h30 gAdd_HK vAdd_HK, %hkadd%
Gui,Add, Button, x+10 y370 h30 gDelete_HK vDel_HK, %hkdelete%
Gui,Add, Button, x+10 y370 h30 gMod_HK vMod_HK, %hkmodify%
Gui,Add, Button, x+30 y370 h30 gRefresh_HK_Gui, %hkclean%
Gui,Add, Button, x280 y370 w90 h30 gApply_HK, %hkapply%
Gui,Add, Button, x380 y370 w90 h30 gGuiEscape, %boutonquitter%
Gui,Show,, %hktitlegui%
Gosub, Refresh_HK_Gui
Return

HK_List:
	IniRead, var, %inifile%, configuration, HK_MouseCong
	If ( var = "" or var = "ERROR" )
		var = Win+M
	LV_Add("", dblclickset, var)
	
	IniRead, var, %inifile%, configuration, HK_AssoConf
	If ( var = "" or var = "ERROR" )
		var = Win+X
	LV_Add("", configassoc, var)
	
	IniRead, var, %inifile%, configuration, HK_AppsConf
	If ( var = "" or var = "ERROR" )
		var = Win+A
	LV_Add("", configapplis, var)
	
	IniRead, var, %inifile%, configuration, HK_HKConf
	If ( var = "" or var = "ERROR" )
		var = Win+H
	LV_Add("", confighotkeys, var)

	IniRead, var, %inifile%, configuration, HK_WinConf
	If ( var = "" or var = "ERROR" )
		var = Win+W
	LV_Add("", configwinds, var)

	IniRead, var, %inifile%, configuration, HK_Reload
	If ( var = "" or var = "ERROR" )
		var = Win+R
	LV_Add("", relaneccafe, var)
	
	IniRead, var, %inifile%, configuration, HK_FS_Pause
	If ( var = "" or var = "ERROR" )
		var = Win+Alt+F
	LV_Add("", fs_pause_item_txt, var)
		
	IniRead, var, %inifile%, configuration, HK_Menu_Pause
	If ( var = "" or var = "ERROR" )
		var = Win+Alt+M
	LV_Add("", menu_pause_item_txt, var)
		
	IniRead, var, %inifile%, configuration, HK_HotKey_Pause
	If ( var = "" or var = "ERROR" )
		var = Win+Alt+H
	LV_Add("", hk_pause_item_txt, var)
	
	IniRead, var, %inifile%, configuration, HK_Pause
	If ( var = "" or var = "ERROR" )
		var = Win+P
	LV_Add("", pause, var)
	
	IniRead, var, %inifile%, configuration, HK_Quit
	If ( var = "" or var = "ERROR" )
		var = Esc+C
	LV_Add("", quit, var)
	
	LV_Add("", "--------------------------------------------------------------------------------", "--------------------")

	hklist:=GetIniSectionListKey(inifile,"HOTKEY")
	Loop, parse, hklist, |
	{
		IniRead, var, %inifile%, HOTKEY, %A_LoopField%
		var:=GetAbsMovPath(A_ScriptDir,var)
		LV_Add("", var, A_LoopField)
	}

	LV_ModifyCol()
Return

Load_HK:
GuiControl, Disable, ListViewItem

hk =
section = 
LV_GetText(RowText, A_EventInfo)
LV_GetText(hk, A_EventInfo, 2)
ind := A_EventInfo
hkold = %hk%

If ( ind = indm )
{
	GoSub, Refresh_HK_Gui
	Return
}

Else If ind in %indlist%
{
	GuiControl, Enable, Mod_HK
	GuiControl, Disable, Act
	GuiControl, Disable, Select_Act
	GuiControl, Disable, Select_Dir
	GuiControl, Disable, Add_HK
	GuiControl, Disable, Del_HK
	section = configuration
}

Else
{
	GuiControl, Enable, Act
	GuiControl, Enable, Select_Act
	GuiControl, Enable, Select_Dir
	GuiControl, Disable, Add_HK
	GuiControl, Enable, Del_HK
	GuiControl, Enable, Mod_HK
	section = HOTKEY
}
;~ hk:=HK_Cafe2AHK(hk)
GuiControl,, ChosenHotkey, %hk%
GuiControl,, Act, %RowText%
Return

Mod_HK:
GuiControlGet, act,, Act
GuiControlGet, hk,, ChosenHotkey

id = 0
Loop % LV_GetCount()
{
	LV_GetText(var, A_Index, 2)
	If ( var = hk )
	{
		id = %A_Index%
	}
}

;~ If ( act != "" and hk != "" and id != "0" )
If ( act != "" and hk != "" and (( id != "0" and id < indm ) or ind < indm ))
{
	LV_GetText(var, id, 1)
	StringReplace, hkerror, hkerror, $hk, %hk%, All
	StringReplace, hkerror, hkerror, $var, %var%, All
	MsgBox, 48, %CAFEERREUR%, %hkerror%
	StringReplace, hkerror, hkerror, %hk%, $hk, All
	StringReplace, hkerror, hkerror, %var%, $var, All
}

Else If ind in %indlist%
{
	If ( RowText = dblclickset )
		RowText = HK_MouseCong	
	
	Else If ( RowText = configassoc )
		RowText = HK_AssoConf	
	
	Else If ( RowText = configapplis )
		RowText = HK_AppsConf	
	
	Else If ( RowText = confighotkeys )
		RowText = HK_HKConf	
	
	Else If ( RowText = configwinds )
		RowText = HK_WinConf
	
	Else If ( RowText = relaneccafe )
		RowText = HK_Reload	
	
	Else If ( RowText = fs_pause_item_txt )
		RowText = HK_FS_Pause	
	
	Else If ( RowText = menu_pause_item_txt )
		RowText = HK_Menu_Pause	
	
	Else If ( RowText = hk_pause_item_txt )
		RowText = HK_HotKey_Pause
	
	Else If ( RowText = pause )
		RowText = HK_Pause	
	
	Else If ( RowText = quit )
		RowText = HK_Quit	
	
	IniWrite, %hk%, %inifile%, configuration, %RowText%
}

;~ Else If ( act != "" and hk != "" and ind = "0")
Else If ( act != "" and hk != "" )
{
	act:=GetRelativePath(A_ScriptFullPath,act)
	IniDelete, %inifile%, %section%, %hkold%
	IniWrite, %act%, %inifile%, HOTKEY, %hk%
}

LV_Delete()
GoSub, HK_List
Gosub, Refresh_HK_Gui
Return

Select_Act:
FileSelectFile, var, 3, %appspath%, %titreselectionfichier%, %toustypes% (*.*)
If not var
	Return
GuiControl,, Act, %var%
Return

Select_Dir:
FileSelectFolder, var,,, %titreselectionfichier%
If not var
	Return
GuiControl,, Act, %var%
Return

Add_HK:
GuiControlGet, act,, Act
GuiControlGet, hk,, ChosenHotkey

ind = 0
Loop % LV_GetCount()
{
	LV_GetText(var, A_Index, 2)
	If ( var = hk )
	{
		ind = %A_Index%
	}
}

If ( act != "" and hk != "" and ind != "0" )
{
	LV_GetText(var, ind, 1)
	StringReplace, hkerror, hkerror, $hk, %hk%, All
	StringReplace, hkerror, hkerror, $var, %var%, All
	MsgBox, 48, %CAFEERREUR%, %hkerror%
	GuiControl,, ChosenHotkey
}

Else If ( act != "" and hk != "" and ind = "0")
{
	LV_Add("", act, hk)
	act:=GetRelativePath(A_ScriptFullPath,act)
	IniWrite, %act%, %inifile%, HOTKEY, %hk%
	Gosub, Refresh_HK_Gui
}
Return

Delete_HK:
LV_Delete()
IniDelete, %inifile%, %section%, %hkold%
Gosub, HK_List
Gosub, Refresh_HK_Gui
Return

Refresh_HK_Gui:
GuiControl,, Act
GuiControl,, ChosenHotkey
GuiControl, Enable, ListViewItem
GuiControl, Enable, Add_HK
GuiControl, Disable, Del_HK
GuiControl, Disable, Mod_HK
GuiControl, Enable, Act
GuiControl, Enable, Select_Act
GuiControl, Enable, Select_Dir
Return

Apply_HK:
If A_IsCompiled
	Run, %A_ScriptName% /hkconf, %A_ScriptDir%
Else
	Run, %A_AhkPath% %A_ScriptFullPath% /hkconf, %A_ScriptDir%
Return

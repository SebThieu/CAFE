;~ voir ce que je peut faire pour le raccourcis clavier, si possible sans
;~ finir l'internationnalisation


; create GUI for window config
STARTHERE:
	Gui, Add, GroupBox, x326 y10 w210 h220 , %boxwins%
	Gui, Add, GroupBox, x6 y10 w310 h150 , %addwind%
	Gui, Add, ListBox, x336 y30 w190 h190 vlistofwindows, 
	Gui, Add, Button, x186 y230 w120 h30 gdelmanagedwin, %delmanagedwin%
	Gui, Add, Edit, x16 y130 w250 h20 vwinclassshower, 
	Gui, Add, Button, x276 y130 w30 h20 gaddchanges, %boutonok%
;~ 	Gui, Add, Button, x326 y240 w100 h30 grelancer, %hkapply%
	Gui, Add, Button, x326 y240 w100 h30 gApply_WIND, %hkapply%
	Gui, Add, Button, x436 y240 w100 h30 gGuiDestroy, %quit%
	Gui, Add, GroupBox, x6 y170 w310 h100, %delmanagedwin%
	Gui, Add, Text, x16 y190 w290 h40 , %helpout2%
	Gui, Add, Text, x16 y30 w290 h90 , %helpout%
	Gui, Show,, %wintitlegui%
	GuiControl, Focus,winclassshower
	Gosub, showlist

; display list of managed windows
showlist:
	IniRead, list, %inifile%, configuration, fenetresAdditionnelles, %A_Space%
	list = ahk_class Progman|ahk_class ExploreWClass|ahk_class CabinetWClass|ahk_class WorkerW|-------------------------------|%list%
	If ( list = "" )
		list = |
	Else
		list = |%list%
	GuiControl,, listofwindows, %list%
Return

; delete managed window
delmanagedwin:
	GuiControlGet, selectedwin,,listofwindows
	
	IniRead, list, %inifile%, configuration, fenetresAdditionnelles, %A_Space%
	
	If ( list = "ERROR" or list = A_Space or list = "" )
		IniWrite,%A_Space%, %inifile%, configuration, fenetresAdditionnelles
	Else
	{
		newmanwind =
		Loop, parse, list, |, %A_Space%
		{
			IfNotInString, A_LoopField, %selectedwin%
			{
				If ( newmanwind = "" )
					newmanwind = %A_LoopField%
				Else
					newmanwind = %newmanwind%|%A_LoopField%
			}
		}
		IniWrite, %newmanwind%, %inifile%, configuration, fenetresAdditionnelles
	}
	
	Gosub, showlist
Return


; add windows hotkey
selwin:
	Click
	Sleep 200
	WinGetClass, manwind, A
	GuiControl, ,winclassshower, ahk_class %manwind%
	WinActivate, %wintitlegui%
Return

; apply newly added windows
addchanges:
	Gui, +OwnDialogs
	GuiControlGet, manwind,,winclassshower

	If  ( manwind = "" )
	{
		MsgBox, 262192, %cafeerreur%,%noclass%
		Return
	}

	Iniread, list, %inifile%, configuration, fenetresAdditionnelles, %A_Space%
	managedWindows = ahk_class Progman|ahk_class ExploreWClass|ahk_class CabinetWClass|ahk_class WorkerW|%list%

	WinGetClass, classwind, %manwind%
	
	IfInString, managedWindows, %manwind%
		MsgBox, 262192, %cafeerreur%, %alreadymanaged%

	Else IfInString, managedWindows, %manwind%
		MsgBox, 262192, %cafeerreur%, %alreadymanaged%

	Else
	{
		If ( list = A_Space )
			list = %manwind%
		Else
			list = %list%|%manwind%
		
		IniWrite, %list%, %inifile%, configuration, fenetresAdditionnelles
;~ 		GroupAdd, Interception, %manwind%
		Gosub, showlist
	}

	GuiControl,,winclassshower,
	GuiControl, Focus,winclassshower,
Return

Apply_WIND:
If A_IsCompiled
	Run, %A_ScriptName% /winconf, %A_ScriptDir%
Else
	Run, %A_AhkPath% %A_ScriptFullPath% /winconf, %A_ScriptDir%
Return
#Persistent


#IfWinActive ahk_class CabinetWClass
#d::
;~ ControlGet, var, List, Selected Col1, SysListView321, ahk_class CabinetWClass
;~ msgbox, var = %var%

;~ LV_Modify("1", "Select")

;~ SendMessage, Msg [, wParam, lParam, Control, WinTitle, WinText, ExcludeTitle, ExcludeText
;~ PostMessage, 0x185, 1, -1, SysListView321, ahk_class CabinetWClass

Loop % LV_GetCount()
{
    LV_GetText(RetrievedText, A_Index)
	MsgBox, RetrievedText = %RetrievedText%
}
Return
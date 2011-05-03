#Persistent
#Include %A_ScriptDir%
#Include library.ahk



If A_IsCompiled
	Menu, tray, NoStandard
Menu, tray, UseErrorLevel
CreatMenu(A_ScriptDir . "\applications","tray")
Menu, tray, add
Menu, tray, add, Relancer, relancer
Menu, tray, Add, Quitter, Quit
Return

test:
cmd:=Find("Exec",A_ThisMenu,A_ThisMenuItem,A_ScriptDir . "\applications")
cmd:=GetAbsMovPath(A_ScriptDir,cmd)
Run, %cmd%
Return

relancer:
Reload
Return

Quit:
ExitApp

Find(key,menu,item,path){
	Loop, %path%\*.desktop,, 1
	{
		SplitPath, A_LoopFileDir, dir_name
		IniRead, name, %A_LoopFileLongPath%, Desktop Entry, NAME, %A_Space%
		If ( dir_name = menu and name = item )
		{
			IniRead, cmd, %A_LoopFileLongPath%, Desktop Entry, %key%
			Return, cmd
		}
	}
}

CreatMenu(path,menu_name){	
	Loop, %path%\*, 1
	{
		dossier := InStr(FileExist(A_LoopFileLongPath), "D")
		
		If ( dossier = "1" )
		{
			CreatMenu(A_LoopFileLongPath,A_LoopFileName)
			Menu,%menu_name%,add,%A_LoopFileName%,:%A_LoopFileName%
		}
		
		Else If ( A_LoopFileExt = "desktop" and dossier != "1" )
		{
			IniRead, name, %A_LoopFileLongPath%, Desktop Entry, NAME
			IniRead, icon, %A_LoopFileLongPath%, Desktop Entry, Icon
			Menu, %menu_name%, Add, %name%, test
;~ 			unused1 =
;~ 			unused2 = 
;~ 			MI_SetMenuItemIcon(menu_name, A_Index, icon,"1","16",unused1,unused2)
		}
	}
}

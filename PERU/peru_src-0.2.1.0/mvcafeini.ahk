#Include library.ahk


inifile = cafe.ini

FileCopy, %inifile%, back-%inifile%, 1

altlist:=GetIniSectionListKey(inifile,"alternative")

Loop, Parse, altlist, |
{
	IniRead, appalt, %inifile%, alternative, %A_LoopField%
	IniRead, appasso, %inifile%, associations, %A_LoopField%
	If ( appasso = "ERROR" or appasso = "" )
	{
		IniWrite, %appalt%, %inifile%, associations, %A_LoopField%
	}
	Else If ( appasso != "ERROR" and appasso != "" )
	{
		IniWrite, %appasso%|%appalt%, %inifile%, associations, %A_LoopField%
	}
}

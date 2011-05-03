
GUICONFAPPS:
SplashImage,, zh0 fs14 B1,, %appguisplashtext%
list:=MakeListApps(inifile)
SplashImage, Off

Gui, Add, GroupBox, x6 y0 w330 h180 +Center, %boxapplications%
Gui, Add, ListBox, x16 y20 w310 h150 gshowpath&ext vlistofapps +Sort, %list%
Gui, Add, GroupBox, x346 y0 w100 h180 +Center, %boxappassext%
Gui, Add, ListBox, x356 y20 w80 h150 vshowassext +Sort +ReadOnly, 
Gui, Add, Button, x406 y200 w30 h20 gchoosenewapp vbtnparcourirapp +Disabled, %btnparcourirapp%
Gui, Add, GroupBox, x6 y180 w440 h50 +Center, %labelcheminabs%
Gui, Add, Edit, x16 y200 w390 h20 vpathappshower +Disabled, 
Gui, Add, GroupBox, x6 y230 w440 h50 +Center, Description de l'application
Gui, Add, Edit, x16 y250 w390 h20 vnameappshower +Disabled, 
Gui, Add, Button, x296 y290 w50 h30 gwritechanges vbtnokapp +Disabled, %btnokapp%
Gui, Add, Button, x366 y290 w80 h30 gGuiEscape vbtnquitapp, %btnquitapp%

 
Gui,Show,, %titreguiapp%
Return

showpath&ext:
GuiControl,+Disabled, btnparcourirapp
GuiControl,+Disabled, btnquitapp
GuiControl,+Disabled, listofapps
GuiControl,+Disabled, showassext
GuiControl,+Disabled, pathappshower
GuiControl,+Disabled, btnokapp
GuiControl,+Disabled, nameappshower


GuiControlGet, thisapp,, listofapps
abspath:=GetAbsMovPath(A_ScriptDir,thisapp)
itsextlist:=MakeListExtWithApp(inifile,thisapp)

StringReplace, thisapp, thisapp, =,, All
IniRead, desc, %inifile%, DESCRIPTION, %thisapp%, %A_Space%

GuiControl,, showassext, |%itsextlist%
GuiControl,, pathappshower, %abspath%
GuiControl,, nameappshower, %desc%
GuiControl,-Disabled, btnparcourirapp
GuiControl,-Disabled, btnquitapp
GuiControl,-Disabled, listofapps
GuiControl,-Disabled, showassext
GuiControl,-Disabled, pathappshower
GuiControl,-Disabled, btnokapp
GuiControl,-Disabled, nameappshower
Return

choosenewapp:
FileSelectFile, newpath, 3, %appspath%, %titreselectionapplication%, %typeapplication% (*.exe`;*.cmd`;*.bat)
If newpath
	GuiControl,, pathappshower, %newpath%
GuiControl,-Disabled, btnokapp
return

writechanges:
Gui,+Disabled
GuiControl,+Disabled, btnparcourirapp
GuiControl,+Disabled, btnquitapp
GuiControl,+Disabled, listofapps
GuiControl,+Disabled, showassext
GuiControl,+Disabled, pathappshower
GuiControl,+Disabled, btnokapp
GuiControl,+Disabled, nameappshower

GuiControlGet, thisapp,, listofapps
GuiControlGet, thisnewapp,, pathappshower
GuiControlGet, desc,, nameappshower
SplashImage,, zh0 fs14 B1,, %splashchgmnt%

StringReplace, thisapp, thisapp, =,, All
IniDelete, %inifile%, DESCRIPTION, %thisapp%

thisnewapp:=GetRelativePath(A_ScriptFullPath,thisnewapp)

If ( desc != "" )
{
	IniWrite, %desc%, %inifile%, DESCRIPTION, %thisnewapp%
}

If ( thisnewapp != thisapp )
{
	ChangeAss(inifile,thisapp,thisnewapp)
}

list:=MakeListApps(inifile)
GuiControl,,listofapps,|%list%

SplashImage, Off
SplashImage,, zh0 fs14 B1,, %splashfin%
Sleep, 1000
SplashImage, Off

GuiControl, Choose,listofapps,%thisnewapp%
Gosub, showpath&ext

GuiControl,-Disabled, btnparcourirapp
GuiControl,-Disabled, btnquitapp
GuiControl,-Disabled, listofapps
GuiControl,-Disabled, showassext
GuiControl,-Disabled, pathappshower
GuiControl,-Disabled, btnokapp
GuiControl,-Disabled, nameappshower
Gui,-Disabled
Return

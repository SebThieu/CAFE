
GUICONFAPPS:
tempfile = %A_Temp%\temp_cafe.temp
;~ tempfile = %A_ScriptDir%\temp_cafe.temp

SplashImage,, zh0 fs14 B1,, %appguisplashtext%
list:=MakeListApps(inifile,tempfile)
SplashImage, Off

Gui, Add, GroupBox, x6 y0 w240 h180 +Center, %boxapplications%
Gui, Add, ListBox, x16 y20 w220 h150 gshowpath&ext vlistofapps +Sort, %list%
Gui, Add, GroupBox, x256 y0 w80 h180  +Center, %boxappassext%
Gui, Add, ListBox, x266 y20 w60 h150 vshowassext +Sort +ReadOnly, 
Gui, Add, Button, x296 y200 w30 h20 gchoosenewapp vbtnparcourirapp +Disabled, %btnparcourirapp%
Gui, Add, Button, x186 y240 w50 h30 gwritechanges vbtnokapp +Disabled, %btnokapp%
Gui, Add, Button, x256 y240 w80 h30 gGuiClose vbtnquitapp, %btnquitapp%
Gui, Add, GroupBox, x6 y180 w330 h50 +Center, %labelcheminabs%
Gui, Add, Edit, x16 y200 w280 h20 vpathappshower +Disabled, 
Gui,Show,, %titregui%
Return

showpath&ext:
GuiControl,, showassext, |
GuiControl,, pathappshower,
GuiControl,+Disabled, btnparcourirapp
GuiControl,+Disabled, btnquitapp
GuiControl,+Disabled, listofapps
GuiControl,+Disabled, showassext
GuiControl,+Disabled, pathappshower
GuiControl,+Disabled, btnokapp


GuiControlGet, thisapp,, listofapps
IniRead, relpath, %tempfile%, AppsListe, %thisapp%
abspath:=GetAbsMovPath(A_ScriptDir,relpath)
itsextlist:=MakeListExtWithApp(inifile,relpath)

GuiControl,, showassext, |%itsextlist%
GuiControl,, pathappshower, %abspath%
GuiControl,-Disabled, btnparcourirapp
GuiControl,-Disabled, btnquitapp
GuiControl,-Disabled, listofapps
GuiControl,-Disabled, showassext
GuiControl,-Disabled, pathappshower
GuiControl,-Disabled, btnokapp
return

choosenewapp:
Gui,+Disabled
FileSelectFile, newpath, 3, %appspath%, %titreselectionapplication%, %typeapplication% (*.exe`;*.cmd`;*.bat)
If newpath
	GuiControl,, pathappshower, %newpath%
Gui,-Disabled
GuiControl,-Disabled, btnokapp
return

writechanges:
Gui,+Disabled
GuiControlGet, thisapp,, listofapps
GuiControlGet, thisnewapp,, pathappshower
SplashImage,, zh0 fs14 B1,, %splashchgmnt%

thisnewapp:=GetRelativePath(A_ScriptFullPath,thisnewapp)

IniRead, holdpath, %tempfile%, AppsListe, %thisapp%
IniWrite, %thisnewapp%, %tempfile%, AppsListe, %thisapp%

ReplaceInFile(inifile,holdpath,thisnewapp)

list:=MakeListApps(inifile,tempfile)

GuiControl,,listofapps,|%list%

SplashImage, Off
SplashImage,, zh0 fs14 B1,, %splashfin%
Sleep, 1000
SplashImage, Off

SplitPath, thisnewapp,,,, thisapp
GuiControl, Choose,listofapps,%thisapp%
Gosub, showpath&ext
Gui,-Disabled
return

GuiClose:
FileDelete, %tempfile%
GoSub, GuiEscape
return

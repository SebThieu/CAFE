
GUICONFAPPS:
tempfile = %A_Temp%\temp_cafe.temp

SplashImage,, zh0 fs14 B1,, %appguisplashtext%
list:=MakeListApps(inifile,tempfile)
SplashImage, Off

;~ Gui, -SysMenu 
Gui,Add, GroupBox, x6 y0 w120 h160 , %boxapplications%
Gui,Add, ListBox, x16 y20 w100 h140 gshowpath&ext vlistofapps +Sort, %list%

Gui,Add, GroupBox, x136 y0 w120 h160 , %boxappassext%
Gui,Add, ListBox, x146 y20 w100 h140 vshowassext +Sort,

Gui,Add, Text, x266 y10 w300 h30 , %labelcheminabs% ; le chemin absolu
Gui,Add, Edit, x266 y35 w300 h20 vpathappshower,
Gui,Add, Text, x266 y70 w300 h30 , %labelcheminrel%
Gui,Add, Edit, x266 y95 w300 h20 vrelpathappshower,
Gui,Add, Button, x366 y130 w40 h30 gchoosenewapp vbtnparcourirapp, %btnparcourirapp%
Gui,Add, Button, x426 y130 w40 h30 gwritechanges vbtnokapp +Disabled, %btnokapp%
Gui,Add, Button, x486 y130 w80 h30 g3GuiClose vbtnquitapp, %btnquitapp%
Gui,Show,, %titregui%
Return

showpath&ext:
GuiControl,, showassext, |
GuiControl,, relpathappshower,
GuiControl,, pathappshower,
GuiControl,+Disabled, btnparcourirapp
GuiControl,+Disabled, btnquitapp
GuiControl,+Disabled, listofapps
GuiControl,+Disabled, showassext
GuiControl,+Disabled, relpathappshower,
GuiControl,+Disabled, pathappshower,

GuiControlGet, thisapp,, listofapps
IniRead, relpath, %tempfile%, AppsListe, %thisapp%
abspath:=GetAbsMovPath(A_ScriptDir,relpath)
itsextlist:=MakeListExtWithApp(inifile,relpath)

GuiControl,, showassext, |%itsextlist%
GuiControl,, relpathappshower, %relpath%
GuiControl,, pathappshower, %abspath%
GuiControl,-Disabled, btnparcourirapp
GuiControl,-Disabled, btnquitapp
GuiControl,-Disabled, listofapps
GuiControl,-Disabled, showassext
GuiControl,-Disabled, relpathappshower
GuiControl,-Disabled, pathappshower
return

choosenewapp:
GuiControlGet, thisapp,, listofapps
FileSelectFile, newpath, 3, %appspath%, %titreselectionapplication%, %typeapplication% (*.exe`;*.cmd`;*.bat)
if not newpath  ; The user canceled the dialog.
	return
relnewpath:=GetRelativePath(A_ScriptFullPath,newpath)
GuiControl,, pathappshower, %newpath%
GuiControl,, relpathappshower, %relnewpath%
GuiControl,-Disabled, btnokapp
return

writechanges:
GuiControlGet, thisapp,, listofapps
GuiControlGet, thisrelpath,, relpathappshower
GuiControlGet, thispath,, pathappshower
SplashImage,, zh0 fs14 B1,, %splashchgmnt%

Gui,+Disabled

IniRead, holdpath, %tempfile%, AppsListe, %thisapp%

IniWrite, %relnewpath%, %tempfile%, AppsListe, %thisapp%

ReplaceInFile(inifile,holdpath,relnewpath)
list:=MakeListApps(inifile,tempfile)

GuiControl,,listofapps,|%list%
GuiControl, Choose,listofapps,%thisapp%

SplashImage, Off
SplashImage,, zh0 fs14 B1,, %splashfin%
Sleep, 2000
SplashImage, Off


Gui,-Disabled
GuiControl,+Disabled, btnokapp
return

3GuiClose:
FileDelete, %tempfile%
Gui,destroy
GoSub, GuiEscape
return

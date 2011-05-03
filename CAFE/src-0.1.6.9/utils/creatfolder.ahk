

#NoEnv
SendMode Input
#SingleInstance, force

IniRead, DefaultFolderName, createfolder.ini, GENERALE, DefaultFolderName, Nouveau_dossier


IfNotEqual, 1
	path = %1%

Click

IfWinActive, ahk_class CabinetWClass
	ControlGetText, path, Edit1, ahk_class CabinetWClass

IfWinActive, ahk_class Progman
	path = %A_Desktop%

InputBox, name, Nouveau dossier, Entrez le nom du nouveau dossier à créer,, 300, 130
If ( ErrorLevel = "1" )
	ExitApp
	
IfEqual, name
	name = %DefaultFolderName%

file = %path%\%name%

IfExist, %file%
{
	Loop,
	{
		IfNotExist, %file%_(%A_Index%)
		{
			file = %file%_(%A_Index%)
			Break
		}
	}
}

FileCreateDir, %file%
;~ MsgBox %file%

ExitApp

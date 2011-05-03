

AjoutInfo(fichier){
	If not ErrorLevel
		Lire(fichier)
	StringReplace, titreDialogue, fichier,.txt
	Menu, info, Add, %titreDialogue%, Lire
	Menu, tray, Add, Informations, :info
	return
}


;lecture de fichiers textes
Lire(fichier){
	Loop
	{
		Gui, %A_Index%:+LastFoundExist
		IfWinExist
			Continue
		Else
			{
			numero = %A_Index%
			Break
			}
	}

	Gui, %numero%: +AlwaysOnTop +ToolWindow +LabelDialog
	FileRead, FileContents, %fichier%
	Gui, %numero%: Add, Edit, R20 W500 ReadOnly, %FileContents%
	StringReplace, titreDialogue, fichier,.txt
	Gui, %numero%: Show, Center, %titreDialogue%
	Send, {pgup}{pgup}
return
}

InfoMenu(){
global
Lire:
	fichier = %A_ThisMenuItem%.txt
	Lire(fichier)
return
DialogClose:
	Gui, %A_Gui% : Destroy
return
}
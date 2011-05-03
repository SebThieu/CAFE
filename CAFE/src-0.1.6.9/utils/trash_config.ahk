


If ( showIcon = "true" )
	sIcon = Checked
If ( showIcon = "false" )
	sIcon =

If ( UseWinDeleteHotKey = "true" )
	UWDHK = Checked
If ( UseWinDeleteHotKey = "false" )
	UWDHK =

If ( UseDeleteHotKey = "true" )
	UDHK = Checked
If ( UseDeleteHotKey = "false" )
	UDHK =

SplitPath, lng,,,, deflng

lngpath := GetAbsMovPath(A_ScriptDir,lngdir)

Loop, %lngdir%\*.lng
	{
	SplitPath, A_LoopFileName,,,, namelng
	If ( lnglist = "" )
		lnglist = %namelng%
	Else
		lnglist = %lnglist%|%namelng%
		
	IfEqual, namelng, %deflng%
		deflng = %A_Index%
	}

	; on définit la taille maximum de la Corbeille
	Gui, Add, Text, x16 y21 w250 h20 , de la Corbeille
	Gui, Add, Edit, x16 y41 w220 h20 , %MaxTrashFolderSize%
	Gui, Add, Button, x236 y41 w30 h20 gcMTSize, Ok

	; on définit la taille maximum des fichiers dans la Corbeille
	Gui, Add, Text, x16 y66 w250 h20 , des fichiers dans la Corbeille
	Gui, Add, Edit, x16 y86 w220 h20 , %MaxTrashFileSize%
	Gui, Add, Button, x236 y86 w30 h20 gcMTFSize, Ok

	; on définit le chemin vers la Corbeille
	Gui, Add, Text, x296 y21 w280 h20 , la Corbeille
	Gui, Add, Edit, x296 y41 w220 h20 , %trashpath%
	Gui, Add, Button, x516 y41 w30 h20 , ...
	Gui, Add, Button, x546 y41 w30 h20 , Ok

	; on définit le chemin vers le son qui est joué lorsqu'on vide la Corbeille
	Gui, Add, Text, x296 y66 w280 h20 , le son de la Corbeille
	Gui, Add, Edit, x296 y86 w220 h20 , %trashsound%
	Gui, Add, Button, x516 y86 w30 h20 , ...
	Gui, Add, Button, x546 y86 w30 h20 , Ok

	; on définit le chemin vers le dossier qui contient les fichiers de langue
	Gui, Add, Text, x296 y126 w280 h20 , Chemin vers le dossier des langues
	Gui, Add, Edit, x296 y146 w220 h20 , %lngpath%
	Gui, Add, Button, x516 y146 w30 h20 , ...
	Gui, Add, Button, x546 y146 w30 h20 , Ok

	; on choisit la langue à utiliser
	Gui, Add, Text, x296 y176 w220 h20 , Choix de la langue
	Gui, Add, DropDownList, x456 y176 w60 Sort Choose%deflng%, %lnglist%
	Gui, Add, Button, x531 y176 w30 h20 , Ok
	
	; on définit l'url à utiliser pour faire la mise à jour
	Gui, Add, Text, x16 y216 w250 h20 , URL de mise à jour
	Gui, Add, Edit, x16 y236 w345 h20 , %updateurl%
	Gui, Add, Button, x361 y236 w30 h20 , Ok
	Gui, Add, Button, x391 y236 w80 h20 , Par Défaut

	; quelques options cochables
	; Gui, Add, CheckBox, x16 y131 w240 h30 %sIcon%, Utiliser en ligne de commande uniquement`n(pas d'icône dans la zone de notification)
	Gui, Add, CheckBox, x16 y151 w240 h20 %UDHK%, Utiliser le raccourcis clavier "Delete"
	; Gui, Add, CheckBox, x16 y181 w240 h20 %UWDHK%, Utiliser le raccourcis clavier "Win + Delete"
	
	Gui, Add, GroupBox, x6 y6 w270 h110 , Tailles maximales en Octets ...
	Gui, Add, GroupBox, x286 y6 w300 h110 , Chemin vers ...
	Gui, Add, GroupBox, x6 y116 w270 h90 , 
	Gui, Add, GroupBox, x286 y116 w300 h90 , 
	Gui, Add, GroupBox, x6 y206 w470 h60 , 
	Gui, Add, Button, x486 y226 w100 h30 gGuiClose, Quitter
	Gui, Show,, ?.?.?.|La Corbeille de C.A.F.E.

Return

cMTSize:
	; GuiControlGet, 
return

cMTFSize:
	; GuiControlGet, 
return

#NoEnv
SendMode Input
	Iniread, lng, cafe.ini, configuration, langue, lng\fr.lng
	Iniread, updateimp, %lng%, update, updateimp, Impossible de télécharger la mise à jour.`nRécupération de la version précédente.
	StringReplace, updateimp, updateimp, ``n, `n, All
	Iniread, updateerror, %lng%, update, updateerror, Une erreur s'est produite lors de la mise à jour.`nRécupération de la version précédente.
	StringReplace, updateerror, updateerror, ``n, `n, All
	Iniread, updateprogress, %lng%, update, updateprogress, Mise à jour de C.A.F.E en cours
	
	
	Progress, zh0 fs14 B1, %updateprogress%
	
	Iniread, lng, cafe.ini, configuration, langue, lng\fr.lng
	Loop, %lng%
		{
		lng = %A_LoopFileLongPath%
		lngdir = %A_LoopFileDir%
		}

	; on sauvegarde l'ancienne version de cafe
	Run, cafe.exe /exit

	IniRead, updateurl, cafe.ini, configuration, updateurl, http://clef.usb.googlepages.com

	Loop, %lngdir%\*.lng
		{
		FileCopy, %lngdir%/%A_LoopFileName%, %lngdir%/%A_LoopFileName%.backup, 1
		UrlDownloadToFile, %updateurl%/%lngdir%/%A_LoopFileName%, %lngdir%/%A_LoopFileName%
		If ErrorLevel
			{
			Progress, Off
			MsgBox, %updateimp%
			Loop, %lngdir%\*.lng
				{
				FileCopy, %lngdir%/%A_LoopFileName%.backup, %lngdir%/%A_LoopFileName%, 1
				}
			return
			}
		}

	FileCopy, cafe.exe, cafe.exe.backup, 1
	UrlDownloadToFile, %updateurl%/cafe.exe, cafe.exe
	If not ErrorLevel
		{
		Progress, Off
		Run, cafe.exe /cafeupdated,, UseErrorLevel
		If ErrorLevel
			{
			MsgBox, %updateerror%
			FileCopy, cafe.exe.backup, cafe.exe, 1
			Loop, %lngdir%\*.lng
				{
				FileCopy, %lngdir%/%A_LoopFileName%.backup, %lngdir%/%A_LoopFileName%, 1
				}
			Run, cafe.exe,, UseErrorLevel
			}
		Else
			FileDelete, cafe.exe.backup
		}
	Else
		{
		Progress, Off
		MsgBox, %updateimp%
		FileCopy, cafe.exe.backup, cafe.exe, 1
		Loop, %lngdir%\*.lng
			{
			FileCopy, %lngdir%/%A_LoopFileName%.backup, %lngdir%/%A_LoopFileName%, 1
			}
		Run, cafe.exe,, UseErrorLevel
		}
Return


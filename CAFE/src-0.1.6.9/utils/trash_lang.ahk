;********************************************************
;internationalisation
	Iniread, lng, %inifile%, configuration, langue, lng\fr.lng
	Loop, %lng%
		{
		lng = %A_LoopFileLongPath%
		lngdir = %A_LoopFileDir%
		}

	
	;corbeille menu
	Iniread, ouvrecorb, %lng%, corb, ouvrecorb, Ouvrir la Corbeille
	Iniread, vidcorb, %lng%, corb, vidcorb, Vider la Corbeille
	Iniread, launchtrash, %lng%, corb, launchtrash, Lancer T.R.A.S.H.
	Iniread, quit, %lng%, tray, quit, Quitter
	Iniread, pause, %lng%, tray, pause, Pause
	
	; traytooltip
	Iniread, trash_enpause, %lng%, traytip, trash_enpause, Mise en pause de T.R.A.S.H.
	Iniread, trash_actif, %lng%, traytip, trash_actif, Activation de T.R.A.S.H.
	
	; pour trash
	Iniread, confirmdscorb, %lng%, messages, confirmdscorb, T.R.A.S.H.|Confirmation de mise dans la Corbeille
	
	Iniread, unfichcorb, %lng%, messages, unfichcorb, Voulez vous vraiment mettre '$OutFileName$' à la Corbeille?`noui = dans la Corbeille de C.A.F.E.`nnon = dans le Corbeille de Windows
	Iniread, plusfichcorb, %lng%, messages, plusfichcorb, Voulez vous vraiment mettre ces fichiers à la Corbeille?`noui = dans la Corbeille de C.A.F.E.`nnon = dans le Corbeille de Windows
	
	Iniread, unfichcorb2, %lng%, messages, unfichcorb2, $OutFileName$ est plus grand que la corbeille.`nSouhaitez vous le supprimer?
	Iniread, plusfichcorb2, %lng%, messages, plusfichcorb2, Les fichiers à mettre à la corbeille dépassent sa taille maximale.`nSouhaitez vous les supprimer?
	
	Iniread, confirmvidcorb, %lng%, messages, confirmvidcorb, T.R.A.S.H.|Confirmation de vidange de la Corbeille
	Iniread, vidcorbquest, %lng%, messages, vidcorbquest, Voulez vous vraiment vider la corbeille?
	
	Iniread, corbpleine, %lng%, messages, corbpleine, T.R.A.S.H.
	Iniread, vidpleinecorbquest, %lng%, messages, vidpleinecorbquest, La corbeille est pleine.`nVoulez vous la vider avant d'y mettre d'autre fichiers?
	StringReplace, vidpleinecorbquest, vidpleinecorbquest, ``n, `n, All
	
	; ##################################################################
	
;********************************************************
;********************************************************
;internationalisation
	Iniread, lng, %inifile%, configuration, langue, lng\fr.lng
	Loop, %lng%
	{
		lng = %A_LoopFileLongPath%
		lngdir = %A_LoopFileDir%
	}

	;tray menu
	Iniread, pref, %lng%, tray, pref, Pr�f�rences
	Iniread, maj, %lng%, tray, maj, Mise � Jour
	Iniread, exec, %lng%, tray, exec, Ex�cuter
	Iniread, pause, %lng%, tray, pause, Pause
	Iniread, quit, %lng%, tray, quit, Quitter
	IniRead, fs_pause_item, %lng%, tray, fs_pause_item, Associations de fichiers en pause
	fs_pause_item_txt := fs_pause_item
	IniRead, menu_pause_item, %lng%, tray, menu_pause_item, Menu contextuel en pause
	menu_pause_item_txt := menu_pause_item
	IniRead, hk_pause_item, %lng%, tray, hk_pause_item, Raccourcis clavier en pause
	hk_pause_item_txt := hk_pause_item
	IniRead, pauses, %lng%, tray, pauses, Pauses
	
	
	; ##################################################################
	Iniread, relaneccafe, %lng%, tray, relaneccafe, Relancer C.A.F.E
	Iniread, cafecorb, %lng%, tray, cafecorb, Corbeille de C.A.F.E.
	
	;context menu
	Iniread, ouvrir, %lng%, context, ouvrir, Ouvrir
	Iniread, ouvriralt, %lng%, context, ouvriralt, Ouvrir (alternatif)
	Iniread, ouvriravec, %lng%, context, ouvriravec, Ouvrir avec...
	Iniread, metdscorb, %lng%, context, metdscorb, Mettre � la corbeille
	Iniread, apartirmodel, %lng%, context, apartirmodel, A partir d'un mod�le...

	; traytooltip
	Iniread, cafeoperationel, %lng%, traytip, cafeoperationel, C.A.F.E. est op�rationel
	Iniread, utilisationpossible, %lng%, traytip, utilisationpossible, Vous pouvez maintenant l'utiliser
	Iniread, enpause, %lng%, traytip, enpause, Mise en pause de C.A.F.E.
	Iniread, actif, %lng%, traytip, actif, Activation de C.A.F.E.
	
	Iniread, fs_pause_msg_1, %lng%, traytip, fs_pause_msg_1, Les associations de fichier sont en pause
	Iniread, fs_pause_msg_0, %lng%, traytip, fs_pause_msg_0, Les associations de fichier sont actives
	
	Iniread, menu_pause_msg_1, %lng%, traytip, menu_pause_msg_1, Le menu contextuel est en pause
	Iniread, menu_pause_msg_0, %lng%, traytip, menu_pause_msg_0, Le menu contextuel est actif
	
	Iniread, hk_pause_msg_1, %lng%, traytip, hk_pause_msg_1, Les raccourcis clavier sont en pause
	Iniread, hk_pause_msg_0, %lng%, traytip, hk_pause_msg_0, Les raccourcis clavier sont actifs
	
	; ##################################################################
	
	;pref menu
	Iniread, langage, %lng%, pref, langage, Choix du Langage
	Iniread, dblclickset, %lng%, pref, dblclickset, R�glage du Double-clic gauche
	Iniread, configassoc, %lng%, pref, configassoc, Configurer les associations
	Iniread, configapplis, %lng%, pref, configapplis, Configurer les applications li�es
	Iniread, confighotkeys, %lng%, pref, confighotkeys, Configurer les raccourcis claviers
	Iniread, configwinds, %lng%, pref, configwinds, Configurer les fen�tres additionnelles
	Iniread, autoassoc, %lng%, pref, autoassoc, Associer automatiquement les nouvelles extensions
	IniRead, configwin, %lng%, pref, configwin, Configuration des fen�tres aditionnelles
	Iniread, confedit, %lng%, pref, confedit, Editer les fichiers de configuration
	Iniread, ttconfedit, %lng%, pref, ttconfedit, Tous les fichiers
	
	;messages
	Iniread, fichiernonrepertorie, %lng%, messages, fichiernonrepertorie, Les fichiers "$extension" ne sont pas repertori�s par Caf�.`nSouhaitez vous que Caf� determine comment les ouvrir ?`n(il est d�conseill� de r�pondre oui pour les fichiers exe et com)
	StringReplace, fichiernonrepertorie, fichiernonrepertorie, ``n, `n, All
		
	Iniread, erreurverifversion, %lng%, messages, erreurverifversion, Impossible de v�rifier la version disponible actuellement sur internet.`nMise � jour interrompue.
	StringReplace, erreurverifversion, erreurverifversion, ``n, `n, All
	Iniread, erreurprogmaj, %lng%, messages, erreurprogmaj, Impossible de lancer le programme de mise � jour.`nVeuillez r�essayer plus tard
	StringReplace, erreurprogmaj, erreurprogmaj, ``n, `n, All
	Iniread, erreurrecupprogmaj, %lng%, messages, erreurrecupprogmaj, Impossible de t�l�charger le programme de mise � jour.`nMise � jour interrompue
	StringReplace, erreurrecupprogmaj, erreurrecupprogmaj, ``n, `n, All
	Iniread, majinutile, %lng%, messages, majinutile, Vous disposez d�j� de la derni�re version disponible de C.A.F.E.
	Iniread, logicielintrouvable, %lng%, messages, logicielintrouvable, Le logiciel design� pour ouvrir ce type de fichier est introuvable.`nSouhaitez vous choisir un nouveau logiciel pour ouvrir ce type de fichiers ?
	StringReplace, logicielintrouvable, logicielintrouvable, ``n, `n, All
	
	Iniread, logicielintrouvable2, %lng%, messages, logicielintrouvable2, Le logiciel "$cmd".`nCorrespondant au raccourci clavier "$hk" est introuvable.
	StringReplace, logicielintrouvable2, logicielintrouvable2, ``n, `n, All
	
	Iniread, logicielintrouvable3, %lng%, messages, logicielintrouvable3, Le logiciel:`n"$CafeExecStr".`nest introuvable.
	StringReplace, logicielintrouvable3, logicielintrouvable3, ``n, `n, All
	
	; ##################################################################
	Iniread, cafeerreur, %lng%, messages, cafeerreur, C.A.F.E.|ERREUR
	Iniread, cafeinfo, %lng%, messages, cafeinfo, C.A.F.E.|INFO
	
	Iniread, progInexistant, %lng%, messages, iniProgInexistant, Le programme $prog`ndesign� pour ouvrir les fichiers ini `ndans $inifile est introuvable.`nUtilisez Win+clic pour red�finir l'association des fichiers ini.
	
	Iniread, badDeskPath, %lng%, messages, badDeskPath, Le chemin vers le Bureau n'est plus le bon!`nVeuillez indiquer le bon chemin vers le dossier "Bureau".
	StringReplace, badDeskPath, badDeskPath, ``n, `n, All
	Iniread, promtbadDeskPath, %lng%, messages, promtbadDeskPath, Le chemin vers le dossier "Bureau" est g�n�ralement de la forme : "C:\Documents and Settings\[nom de l'utilisateur courant]\Bureau"

	Iniread, nocontextfile, %lng%, messages, nocontextfile, Le fichier "$contextfile" est absent!
	
	Iniread, assocboxtitle, %lng%, messages, assocboxtitle, Choisissez le programe qui ouvrira les fichiers $extension
	
	; ##################################################################
	
	;interface de r�glage du double-clic
	Iniread, labelrapide, %lng%, dblclickgui, labelrapide, Rapide
	Iniread, labellent, %lng%, dblclickgui, labellent, Lent
	Iniread, boutontest, %lng%, dblclickgui, boutontest, Double-cliquez`nsur ce bouton`npour tester`nla sensibilit�`n� la vitesse choisie
	StringReplace, boutontest, boutontest, ``n, `n, All
	Iniread, dblclicktooltip, %lng%, dblclickgui, dblclicktooltip, double-clic !
	Iniread, labelvalider, %lng%, dblclickgui, labelvalider, Valider
	Iniread, labelannuler, %lng%, dblclickgui, labelannuler, Annuler
	Iniread, titredblclick, %lng%, dblclickgui, titredblclick, R�glage du Double-clic
	Iniread, oneclicktooltip, %lng%, dblclickgui, oneclicktooltip, simple-clic :`n- temps �coul� depuis le pr�c�dent : $deltaClickms`n- temps autoris� entre 2 clics : $vitessems
	
	;interface de configuration  des applications
	Iniread, appguisplashtext, %lng%, appgui, appguisplashtext, Cr�ation de la liste ! Veuillez patienter.
	Iniread, boxapplications, %lng%, appgui, boxapplications, Applications li�es.
	Iniread, labelcheminabs, %lng%, appgui, labelcheminabs, Chemin absolu vers l'application
	Iniread, labelcheminrel, %lng%, appgui, labelcheminrel, Chemin relatif vers l'application
	Iniread, titregui, %lng%, appgui, titregui, C.A.F.E |Configuration des applications li�es
	Iniread, titreselectionapplication, %lng%, appgui, titreselectionapplication, S�lectionner une application pour l'association
	Iniread, typeapplication, %lng%, appgui, typeapplication, Application
	Iniread, splashchgmnt, %lng%, appgui, splashchgmnt, Un moment s'il vous plait! Le temps de modifier le chemin.
	Iniread, splashfin, %lng%, appgui, splashfin, Termin� !
	Iniread, boxappassext, %lng%, appgui, boxappassext, Extensions associ�es.
	Iniread, pleasewait, %lng%, appgui, pleasewait, Un moment s'il vous plait!

	;interface de configuration  des associations
	Iniread, extguisplashtext, %lng%, extgui, extguisplashtext, Cr�ation de la liste ! Veuillez patienter.
	Iniread, boxajout, %lng%, extgui, boxajout, Ajouter une association
	Iniread, textajout, %lng%, extgui, textajout, Vous pouvez soit aller chercher un fichier ayant l'extension que vous souhaitez associer. Soit directement entrer le nom de l'extension sans oublier de commencer par un point.
	Iniread, boutonassocier, %lng%, extgui, boutonassocier, Associer
	IniRead, boxapplications, %lng%, extgui, boxapplications, Applications associ�es
	IniRead, boxprincipale, %lng%, extgui, boxprincipale, Application principale
	IniRead, boxsecondaire, %lng%, extgui, boxsecondaire, Application secondaire
	Iniread, textassociation, %lng%, extgui, textassociation, Pour utiliser l'application par d�faut de l'ordinateur �crivez host dans le champ.
	Iniread, boxextensions, %lng%, extgui, boxextensions, Liste des extensions
	Iniread, supprextension, %lng%, extgui, supprextension, Supprimer l'extension
	Iniread, supprassoc, %lng%, extgui, supprassoc, Supprimer l'association
	Iniread, titregui, %lng%, extgui, titregui, C.A.F.E |Configurer les associations
	Iniread, titreselectionfichier, %lng%, extgui, titreselectionfichier, S�lectionner un fichier � associer
	Iniread, toustypes, %lng%, extgui, toustypes, Tous les fichiers
	Iniread, extensionexistante, %lng%, extgui, extensionexistante, L'extension existe d�ja !
	Iniread, erreurextension, %lng%, extgui, erreurextension, Erreur pour l'ajout de l'extension
	Iniread, titreselectionapplication, %lng%, extgui, titreselectionapplication, S�lectionner une application pour l'association
	Iniread, typeapplication, %lng%, extgui, typeapplication, Application
	
	;interface de configuration des raccourcis clavier
	IniRead, hktitlegui, %lng%, hkgui, hktitlegui,  C.A.F.E. | Configuration des raccourcis claviers
	IniRead, hkdblonline, %lng%, hkgui, hkdblonline,  Double cliquez sur la ligne pour la changer
	IniRead, hkadd, %lng%, hkgui, hkadd,  + Ajouter
	IniRead, hkdelete, %lng%, hkgui, hkdelete,  - Enlever
	IniRead, hkmodify, %lng%, hkgui, hkmodify,  Modifier
	IniRead, hkclean, %lng%, hkgui, hkclean,  Effacer
	IniRead, hkhotkey, %lng%, hkgui, hkhotkey,  Raccourci :
	IniRead, hkaction, %lng%, hkgui, hkaction,  Action :
	IniRead, hkapply, %lng%, hkgui, hkapply,  Appliquer
	IniRead, hkerror, %lng%, hkgui, hkerror,  Le raccourcis clavier "$hk" est d�j� utilis� pour l'action : "$var" !
	IniRead, hkacthk, %lng%, hkgui, hkacthk,  Action|Raccourci

	
	
	Iniread, btnokapp, %lng%, appgui, btnokapp, OK
;~ 	Iniread, boutonok, %lng%, extgui, boutonok, OK
	boutonok = %btnokapp%
	Iniread, btnquitapp, %lng%, appgui, btnquitapp, Quitter
;~ 	Iniread, boutonquitter, %lng%, extgui, boutonquitter, Quitter
	boutonquitter = %btnquitapp%
;~ 	Iniread, btnparcourirapp, %lng%, appgui, btnparcourirapp, ...
	btnparcourirapp = ...
;~ 	Iniread, boutonparcourir, %lng%, extgui, boutonparcourir, ...
	boutonparcourir = %btnparcourirapp%
	
	
	;interface de configuration des fen�tres additionnelles
	IniRead, wintitlegui, %lng%, wingui, wintitlegui, CAFE | Configuration des fen�tres additionelles
	IniRead, boxwins, %lng%, wingui, boxwins, Liste de fen�tre
	IniRead, addwind, %lng%, wingui, addwind, Ajouter une fen�tre
	IniRead, delmanagedwin, %lng%, wingui, delmanagedwin, Supprimer la fen�tre
	
	Iniread, helpout, %lng%, wingui, helpout, Pour que CAFE fonctionne sur une nouvelle fen�tre, pressez Shift + Win et cliquez sur la bare de titre de la fen�tre.`n`nVous devez cliquer sur OK pour appliquer le changement.`n`nPour ajouter une fen�tre � l'aide de son titre, inscrivez le enti�rement ou partiellement ci dessous.
	StringReplace, helpout, helpout, ``n, `n, All
	
	Iniread, helpout2, %lng%, wingui, helpout2, Pour supprimer une fen�tre s�lectionnez la dans la liste et cliquez sur le bouton ci dessous. Les fen�tres audessus du s�parateur ne sont pas supprimables.
	StringReplace, helpout2, helpout2, ``n, `n, All
	

	IniRead, noclass, %lng%, wingui, noclass, Aucune fen�tre s�lectionn�e!
	IniRead, alreadymanaged, %lng%, wingui, alreadymanaged, La fen�tre est d�j� dans la liste!
	
;********************************************************
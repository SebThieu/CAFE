;
; AutoHotkey Version: 1.x
; Langage:        Français
; Plateforme:     WinXP
; Auteur:         Yann Perrin <yann.perrin+clef@gmail.com> et Lahire Biette <tuxmouraille@gmail.com>
;
; Utilité du Script :
;	Crée des associations de fichiers temporaires, tant que le script est en cours d'utilisation
;

#NoTrayIcon
#NoEnv
SendMode Input
#SingleInstance, off
SetBatchLines, -1  ; Make the operation run at maximum speed.

;inclusion des fonctions relatives aux chemins de fichiers et à la lecture des fichiers ini
#Include %A_ScriptDir%
#Include ..\library.ahk

defURL = http://download.tuxfamily.org/nomadsofts/C.A.F.E./trash

;ajouter un label à la section auto executable permet d'utiliser ce script dans un autre script

FormatTime, date,, yyyyMMddHHmmss
; msgbox, %date%
FileCopy, %1%, %1%.%date%.back, 1
;
; AutoHotkey Version: 1.x
; Langage:        Français
; Plateforme:    WinXP
; Auteur:         Lahire Biette <tuxmouraille@gmail.com>
;
; Utilité du Script :
;    Crée des associations de fichiers temporaires, tant que le script est en cours d'utilisation
;

#NoTrayIcon
#NoEnv
SendMode Input
#SingleInstance, off
; #SingleInstance, force
SetBatchLines, -1  ; Make the operation run at maximum speed.
#Persistent

;inclusion des fonctions relatives aux chemins de fichiers et à la lecture des fichiers ini
#Include %A_ScriptDir%
#Include ..\library.ahk

; cette variable sert pour annuler la dernière suppression
lastrashedfiles =

_pause = 0

;initialisation
Process, Priority,,H
CoordMode,Mouse,Screen
SetWorkingDir,%A_ScriptDir%
StringReplace, inifile, A_ScriptName, .ahk, .ini
StringReplace, inifile, inifile, .exe, .ini
Loop, %inifile%
    inifile = %A_LoopFileLongPath%
    
#Include trash_lang.ahk

; création du groupe de fenêtres sur lequel il doit être actif
GroupAdd, Interception, ahk_class ExploreWClass
GroupAdd, Interception, ahk_class Progman
GroupAdd, Interception, ahk_class CabinetWClass
GroupAdd, Interception, ahk_class WorkerW

;lecture du chemin vers la corbeille
IniRead, trashpath, %inifile%, configuration, trashpath, %A_ScriptDir%\trash
If (trashpath = "")
    trashpath = %A_ScriptDir%\trash
trashpathinfo = %trashpath%\info
trashpath = %trashpath%\files

trashpath:=GetAbsMovPath(A_ScriptDir,trashpath)
IfNotExist, trashpath
    {
    FileCreateDir, %trashpath%
    }

trashpathinfo:=GetAbsMovPath(A_ScriptDir,trashpathinfo)
IfNotExist, trashpathinfo
    {
    FileCreateDir, %trashpathinfo%
    }


;lecture du chemin vers le son de la corbeille
IniRead, trashsound, %inifile%, configuration, trashsound, %A_Space%
    trashsound:=GetAbsMovPath(A_ScriptDir,trashsound)
    
; l'option du double click
IniRead, dcopt, %inifile%, configuration, DoubeClickOption, 0

; variable pour l'habillage de l'icone, par défaut on habille pour le script non compilé
iconopt = 1

If A_IsCompiled
    {
    Menu, tray, NoStandard
    ; si le script est compilé on peut choisir ou non l'habillage, par défaut ce sera les icones du binaire
    IniRead, iconopt, %inifile%, configuration, SkinIcon, 0
    If (iconopt = "")
        iconopt = 0
    }

Hotkey, IfWinActive, ahk_group Interception
Hotkey, Delete, PushInTrash, UseErrorLevel
Hotkey, !z, WillBeCancel, UseErrorLevel
Hotkey, #z, WillBeCancelMenu, UseErrorLevel

; pour mettre à la corbeille
If 1 = /pushintrash
{
    GoSub, pushInTrash
    ExitApp
}

; pour supprimer les fichiers
If 1 = /deletefiles
{
    GoSub, DeleteFiles
    ExitApp
}

; vide la corbeille en ligne de commande
If 1 = /empty
{
    Gosub, vidcorb
    ExitApp
}

; vide la corbeille et lance trash
If 1 = /emptystart
{
    Gosub, vidcorb
}

If 1 = /menu
{
    MenuMaker("trashcontext", cafecorb, ouvrecorb, vidcorb, trashpath, pause,_pause,launchtrash,quit,dcopt, iconopt)
    Menu, trashcontext, show
    ExitApp
}


;~ #########################################
;~ #########################################
If 1 = /restore
{
    Gosub, Restaure
    ExitApp
}
;~ #########################################
;~ #########################################


Menu, Tray, Icon
MenuMaker("Tray", cafecorb, ouvrecorb, vidcorb, trashpath, pause,_pause,launchtrash,quit,dcopt, iconopt)
SetTimer, TrashVerif, 250
Return

TrashVerif:
TrashVerif("Tray", trashpath, vidcorb,_pause, iconopt)
return

; #####################################
; a finir
; permettra avec un Win + Z de faire apparaitre un menu avec la liste
; des fichiers suprrimés et présent dans la corbeille pour les restaurés
WillBeCancelMenu:
Menu, DelMenu, UseErrorLevel
Menu, DelMenu, DeleteAll
Loop, %trashpathinfo%\*.trashinfo, 1, 0
    {
    SplitPath, A_LoopFileName,,,, OutName
    Menu, DelMenu, Add, %OutName%, Restaure
    }
Menu, DelMenu, Show
return

Restaure:
    IniRead, origpath, %trashpathinfo%\%A_ThisMenuItem%.trashinfo, Trash Info, Path
    If (origpath = "ERROR")
        return
    origpath := GetAbsMovPath(A_ScriptDir,origpath)
    
    dossier := InStr(FileExist(origpath), "D")

    If dossier = 1
        {
        FileMoveDir, %trashpath%\%A_ThisMenuItem%, %origpath%, 1
        }
    Else
        {
        FileMove, %trashpath%\%A_ThisMenuItem%, %origpath%, 1
        }
    FileDelete, %trashpathinfo%\%A_ThisMenuItem%.trashinfo
Return

;mise en place des raccourcis spécifiques
; #IfWinActive, ahk_group Interception
; !z::
WillBeCancel:
    Loop, Parse, lastrashedfiles , |
        {
        If (A_LoopField = "")
            continue
        StringSplit, array, A_LoopField, /

        SplitPath, array2,, OutDir, OutExtension, OutNameNoExt

        IfExist, %array2%
            {
            loop
                {
                array2 = %OutDir%\%OutNameNoExt%%A_Space%(%A_Index%).%OutExtension%
                IfNotExist, %array2%
                    {
                    break
                    }
                }
            }

        dossier := InStr(FileExist(array1), "D")
        If dossier = 1
            {
            FileMoveDir, %array1%, %array2%, 1
            }
        Else
            {
            FileMove, %array1%, %array2%, 1
            }
        }

    lastrashedfiles = 
return

; section pour mettre à la corbeille
; Delete::
PushInTrash:
    #IfWinActive, ahk_group Interception
    MouseGetPos,,,,OutputVarControl

    If (OutputVarControl != "SysListView321")
        Send, {Delete}

    filename:=GetFileName()
    
    If ( filename = "" )
        {
        Send, {Delete}
        return
        }

    StringSplit, array, filename, `r`n
    IfNotExist, %array1%
        {
        Send, {Delete}
        return
        }

    ; Vérification de la taille de la corbeille
    CorbSize = 0
    Loop, %trashpath%\*.*, , 1
        {
        CorbSize += %A_LoopFileSizeKB%
        }

    ; taille maximum autorisée de la corbeille .
    IniRead, CorbMaxSize, %inifile%, configuration, CorbMaxSize, 0
    
    ; si la taille maximum de la corbeille est 0k, il n'y a pas de taille maximum
    If (CorbMaxSize = "0" or CorbMaxSize = "")
        Goto, NoTrashMaxSize
    
    ; Vérification de la taille des fichiers à supprimer
    Size = 0
    SizeTotale = 0
    Loop, parse, filename, `r`n
        {
        dossier := InStr(FileExist(A_LoopField), "D")
            If dossier = 1
            {
            SplitPath, A_LoopField, ,OutDir, ,OutNameNoExt
            Loop, %OutDir%\%OutNameNoExt%\*.*, , 1
                SizeTotale += %A_LoopFileSizeKB%
            }
            Else
            {
            FileGetSize, Size, %A_LoopField%, K
            SizeTotale += Size
            }
        }

    ; Si la taille totale des fichiers a supprimer est plus grande que celle de la corbeille,
    ; que doit on faire?
    If (SizeTotale > CorbMaxSize)
    {
        IfInString, filename, `r`n
            {
            questcorb2 = %plusfichcorb2%
            }
        Else
            {
            SplitPath, filename, OutFileName
            StringReplace, questcorb2, unfichcorb2, $OutFileName$, %OutFileName%, All
            }
        StringReplace, questcorb, questcorb, ``n, `n, All
        MsgBox, 262193, %corbpleine%, %questcorb2%
        
        IfMsgBox Ok
            {
            Loop, parse, filename, `r`n
                {
                dossier := InStr(FileExist(A_LoopField), "D")
                If ( dossier = "1" )
                    FileRemoveDir, %A_LoopField%,1
                If ( dossier = "0" )
                    FileDelete, %A_LoopField%
                }
            return
            }
        
        IfMsgBox Cancel
            return
    }
    
    NoTrashMaxSize:
    ; si vous souhaitez que tout les fichiers soit mis dans la corbeille
    IniRead, allintrash, %inifile%, configuration, AllInTrash, 0
    If (allintrash != "1")
        {
        IfInString, filename, `r`n
            {
            questcorb = %plusfichcorb%
            }
        Else
            {
            SplitPath, filename, OutFileName
            StringReplace, questcorb, unfichcorb, $OutFileName$, %OutFileName%, All
            }
        StringReplace, questcorb, questcorb, ``n, `n, All
        MsgBox, 262179, %confirmdscorb%, %questcorb%
        
        IfMsgBox No
            Goto, Recycle
        
        IfMsgBox Cancel
            Return
        }
    
    If (CorbMaxSize != "0" and CorbMaxSize != "")
    {
        ; Si la corbeille est pleine ou n'a plus assez de place pour recevoir les fichiers supprimés
        CorbSizeTotale := SizeTotale + CorbSize
        If (Corbsize > CorbMaxSize or CorbSizeTotale > CorbMaxSize)
        {
            MsgBox, 52, %corbpleine%, %vidpleinecorbquest%
            IfMsgBox Yes
            {
            Loop, %trashpath%\*.*, 1, 1
                {
                dossier := InStr(FileExist(A_LoopFileFullPath), "D")
                If ( dossier = "1" )
                    FileRemoveDir, %A_LoopFileFullPath%,1
                If ( dossier = "0" )
                    FileDelete, %A_LoopFileFullPath%
                }
            }
        }
    }
    
    lastrashedfiles =
    
    ; maintenant que les vérifications sur la taille de la corbeille est faites on va mettre les fichiers à la corbeille
    Loop, Parse, filename , `r`n
        {
        If (A_LoopField = "")
            continue
        dossier := InStr(FileExist(A_LoopField), "D")
        SplitPath, A_LoopField, OutFileName,, OutExtension, OutNameNoExt

        trashfile = %trashpath%\%OutFileName%

        IfExist, %trashfile%
            {
            loop
                {
                If dossier = 1
                    {
                    trashfile = %trashpath%\%OutNameNoExt%%A_Space%(%A_Index%)
                    }
                Else
                    {
                    trashfile = %trashpath%\%OutNameNoExt%%A_Space%(%A_Index%).%OutExtension%
                    }
                IfNotExist, %trashfile%
                    {
                    break
                    }
                }
            }

        ; ici est créée la liste des derniers fichiers effacés
        lastrashedfiles = %lastrashedfiles%|%trashfile%/%A_LoopField%
        
        SplitPath, trashfile, OutFileName

        dossier := InStr(FileExist(A_LoopField), "D")
        If dossier = 1
            {
            FileMoveDir, %A_LoopField%, %trashfile%
            }
        Else
            {
            FileMove, %A_LoopField%, %trashfile%
            }
        
        
;~         origpath := GetRelativePath(A_ScriptDir,A_LoopField)
        SplitPath, A_ScriptDir,,,,, Root
        origpath := GetRelativePath(Root,A_LoopField)
        FormatTime, deletiondate,, yyyy-MM-ddTHH:mm:ss
        IniWrite, %origpath%, %trashpathinfo%\%OutFileName%.trashinfo, Trash Info, Path
        IniWrite, %deletiondate%, %trashpathinfo%\%OutFileName%.trashinfo, Trash Info, DeletionDate
        }
Return

; section pour vider la corbeille
vidcorb:
    MsgBox, 52, %confirmvidcorb%, %vidcorbquest%
    IfMsgBox No
        {
        return
        }

    Loop, %trashpath%\*.*, 1, 1
        {
        dossier := InStr(FileExist(A_LoopFileFullPath), "D")
        If ( dossier = "1" )
            FileRemoveDir, %A_LoopFileFullPath%,1
        If ( dossier = "0" )
            FileDelete, %A_LoopFileFullPath%
        }
    
    Loop, %trashpathinfo%\*.*, 1, 1
        {
        FileDelete, %A_LoopFileFullPath%
        }
        
    SoundPlay, %trashsound%, wait
return

; section pour supprimer les fichiers
; s'utilise uniquement en ligne de commande
DeleteFiles:
    #IfWinActive, ahk_group Interception
    MouseGetPos,,,,OutputVarControl

    If (OutputVarControl = "SysListView321")
    {
        filename:=GetFileName()
            
        If ( filename = "" )
            {
            return
            }

        ; maintenant que les vérifications sur la taille de la corbeille est faites on va mettre les fichiers à la corbeille
        Loop, Parse, filename , `r`n
            {
            If (A_LoopField = "")
                continue

            dossier := InStr(FileExist(A_LoopFileFullPath), "D")
            If ( dossier = "1" )
                FileRemoveDir, %A_LoopFileFullPath%,1
            If ( dossier = "0" )
                FileDelete, %A_LoopFileFullPath%
            }
    }
return

; où on met dans le Corbeille de Windows
Recycle:
    Loop, Parse, filename , `r`n
        {
        If (A_LoopField = "")
            continue
        FileRecycle, %A_LoopField%
        }
return

; section pour ouvrir la corbeille
opencorb:
    Run, explorer.exe "%trashpath%"
    WinWaitActive,  ahk_class CabinetWClass
    ControlSetText, Edit1, T.R.A.S.H., ahk_class CabinetWClass
    WinSetTitle, ahk_class CabinetWClass,, T.R.A.S.H.
return

Launch:
Run, trash.exe,, UseErrorLevel
return

Suspension:
Suspend
Menu, tray, ToggleCheck, %pause%
If ( _pause = "0")
    {
    _pause = 1
    TrayTip,, %trash_enpause%
    return
    }
If ( _pause = "1")
    {
    _pause = 0
    TrayTip,, %trash_actif%
    return
    }

return


fin:
ExitApp


; --------------------------------------------------------------------------------------------------------
; --------------------------------------------------------------------------------------------------------
; si dessous commencent les fonctions pour trash
; --------------------------------------------------------------------------------------------------------
; --------------------------------------------------------------------------------------------------------

; la fonction qui crée la menu de trash
MenuMaker(_Menu, cafecorb, ouvrecorb, vidcorb, trashpath, pause,_pause,launchtrash,quit,dcopt, iconopt){
    Menu, %_Menu%, Add, %ouvrecorb%, opencorb
    Menu, %_Menu%, Add, %vidcorb%, vidcorb

    TrashVerif(_Menu, trashpath, vidcorb,_pause, iconopt)
    
    Menu, tray, Add, %pause%, Suspension
    Menu, trashcontext, Add, %launchtrash%, Launch ; a localiser
    Menu, tray, Add, %quit%, Fin
    If (_menu = "tray")
        {
        If (dcopt = "1")
            Menu, tray, Default, %ouvrecorb%
        If (dcopt = "2")
            Menu, tray, Default, %vidcorb%
        If (dcopt = "3")
            Menu, tray, Default, %pause%
        If (dcopt = "4")
            Menu, tray, Default, %quit%
        }
    Menu, tray, Tip, T.R.A.S.H.
Return
}

; cette fonction vérifie si le dossier de la corbeille est vide ou pas
; elle change l'icone du tray et grise l'entré menu "Vider la corbeille" en fonction
TrashVerif(_Menu, trashpath, vidcorb,_pause, iconopt){
    filetrash = 
    Loop, %trashpath%\*.*, 1, 1
        {
        filetrash = %A_LoopFileName%
        }
        
    i_n =  %A_ScriptName%
    _i = 1
        
    If ( filetrash = "" )
        Menu, %_Menu%, Disable, %vidcorb%
    If ( filetrash != "" )
        Menu, %_Menu%, Enable, %vidcorb%
    
    ; on habille
    If (iconopt = "1" and filetrash = "" and _pause = "1")
        {
        i_n = img\pause_empty_trash.ico
        }
    
    If (iconopt = "1" and filetrash = "" and _pause = "0")
        {
        i_n = img\empty_trash.ico
        }
    
    If (iconopt = "1" and filetrash != "" and _pause = "1")
        {
        i_n = img\pause_full_trash.ico
        }
    
    If (iconopt = "1" and filetrash != "" and _pause = "0")
        {
        i_n = img\full_trash.ico
        }
    
    ; on n'habille pas
    If (iconopt != "1" and filetrash = "" and _pause = "0")
        {
        _i = 1
        }
    
    If (iconopt != "1" and filetrash = "" and _pause = "1")
        {
        _i = 2
        }
    
    If (iconopt != "1" and filetrash != "" and _pause = "0")
        {
        _i = 3
        }
    
    If (iconopt != "1" and filetrash != "" and _pause = "1")
        {
        _i = 4
        }
        
    Menu, Tray, Icon, %i_n%, %_i%, 1

return
}


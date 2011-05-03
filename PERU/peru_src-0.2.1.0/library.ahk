

; ------------------------------------------------------------------------------
; où on récupère le chemin vers le fichier sélectionnés
; ------------------------------------------------------------------------------
GetFileName() {
	BlockInput, Mousemove  ;Block mousemovement
	oldclip := ClipboardAll
	clipboard =
	send, ^c
	ClipWait, 0.1
	filename := Clipboard
	clipboard := oldclip
	BlockInput, MousemoveOff ;Enable mousemovement
	Return, filename
}
; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------


; ------------------------------------------------------------------------------
; où on crée le chemin relatif vers le fichier, uniquement pour les périphériques
; amovibles
; ------------------------------------------------------------------------------
GetRelativePath(from,to){
	SplitPath, from,,,,, Root
	StringReplace, to, to, %Root%, ?:, All
	Return, to
}
; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------


; ------------------------------------------------------------------------------
; où on remplace toutes les même occurences d'une variable par une autre occurence
; ------------------------------------------------------------------------------
StrReplace(string, param1 = "", param2 = "") {
	param1 := RegExReplace(param1, "([\[\\\^\$\.\|\?\*\+\(\)])", "\$1")
	new := RegExReplace(string, "i)" . param1, param2)
	Return, new
}
; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------


; ------------------------------------------------------------------------------
; où on remplace toutes les même occurences dans fichier texte par une autre occurence
; ------------------------------------------------------------------------------
;~ ReplaceInFile(filepath,SearchText,ReplaceText){
;~ 	IfNotExist, %filepath%
;~ 	{
;~ 		return
;~ 	}

;~ 	SplitPath, filepath, OutFileName, OutDir,,,

;~ 	newfilepath = %OutDir%\new.%OutFileName%

;~ 	FileCopy, %filepath%, %filepath%.old, 1
;~ 	
;~ 	IfExist, %newfilepath%
;~ 	{
;~ 		FileDelete, %newfilepath%
;~ 	}
;~ 	
;~ 	Loop, read, %filepath%, %newfilepath%
;~ 	{
;~ 		newstr:=StrReplace(A_LoopReadLine,SearchText,ReplaceText)
;~ 		FileAppend, %newstr%`n		
;~ 	}

;~ 	FileMove, %newfilepath%, %filepath%, 1
;~ }
; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------


; ------------------------------------------------------------------------------
; où on trouve le dossier parent
; ------------------------------------------------------------------------------
GetParentDirectory(path){
	StringSplit, PathArray, path, \,	
	Loop, %PathArray0%
	{
		index = %A_Index%
		count := ----index
	}
	
	parentdir = %PathArray1%
	
	Loop, %count%
	{
		index = %A_Index%
		index := ++index
		path := PathArray%index%
		parentdir = %parentdir%\%path%
	}

	Return, parentdir
}
; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------


; ------------------------------------------------------------------------------
; où on cré le chemin absolut si besoin est, à partir d'un chemin relatif, de la
; forme:
;   \ce\chemin
;   .\ce\chemin
;   ..\ce\chemin
;
; ou les chemins commençant par une variable d'environnement
;   %userprofile%\Mes documents
;
; n'accepte pas les chemins de la forme
;   F:\ce\..\..\chemin
;
; ------------------------------------------------------------------------------
GetAbsMovPath(from,to){
	StringSplit, PathArray, from, \,
	If (( PathArray1 = "" ) and ( PathArray2 = "" ))
	{
		; this for UNC path
		Root = %PathArray1%\%PathArray2%\%PathArray3%\%PathArray4%
	}
	Else
	{
		SplitPath, from,,,,, Root
	}
	
	
	StringSplit, PathArray, to,, "
	If ( PathArray1 = "." and PathArray2 = "." )
	{
		newpath =
		Loop, parse, to, \,
		{
			IfEqual,A_LoopField,..
				from:=GetParentDirectory(from)
			Else
				newpath = %newpath%\%A_LoopField%
		}	
	to=%from%%newpath%
	}

	Else If ( PathArray1 = "." and PathArray2 = "\" )
	{
	   StringReplace, to, to, .\,,
	   to=%from%\%to%
	}

	Else If (( PathArray1 = "\" ) and ( PathArray2 != "\" ))
	{
		to=%from%%to%
	}

	Else If ( PathArray1 = "%" )
	{
		StringSplit, VarLabel, to, \, `%
		EnvGet, Variable, %VarLabel1%
		StringReplace, to, to, `%%VarLabel1%`%, %Variable%, All
	}

	StringReplace, to, to, ?:, %Root%, All

	Return, to
}
; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------ 

; ------------------------------------------------------------------------------
; Où on liste toutes les clés d'une section de fichier ini
; ------------------------------------------------------------------------------
GetIniSectionListKey(inifile,header){
	Loop
	{
		FileReadLine, line, %inifile%, %A_Index%
		If ErrorLevel
			break
		IfEqual,line,[%header%]
		{
			count := A_Index
			break
		}
	}

	Loop
	{
		count := count +1
		FileReadLine, valeur,%inifile%, %count%
		if ErrorLevel
		{
			break
		}

		StringSplit, CaracArray, valeur,,%A_Space%

		if caracArray1 = [
		{
			Loop, %CaracArray0%
			{
				last_carac := caracArray%a_index%
				controler=%caracArray1%%last_carac%
				if controler = [`;
				{
					break
				}
				
				if controler = []
				{
					break
				}
			}
		}

		if controler = []
		{
			break
		}

		if caracArray1 = `;
		{
			Continue
		}

		if caracArray1 = `#
		{
			Continue
		}


		if caracArray1 = `!
		{
			Continue
		}

		if valeur =
		{
			break
		}

		else
		{
			; TestString = %valeur%
			StringSplit, word_array, valeur, =, .  ; Omits periods.
			If list=
			{
				; TestString = %valeur%
				; StringSplit, word_array, TestString, =, .  ; Omits periods.
				list=%word_array1%
			}
			Else
			{
				; TestString = %valeur%
				; StringSplit, word_array, TestString, =, .  ; Omits periods.
				list=%list%|%word_array1%
			}
		}
		; Continue
	}
	Return, list
}
; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------


; ------------------------------------------------------------------------------
; Où on liste toutes les valeurs de clé d'une section de fichier ini,
; en se souciant des redondences
; ------------------------------------------------------------------------------
GetIniSectionListNoDoubleValue(inifile,header,excepte){
	Loop
	{
		FileReadLine, line, %inifile%, %A_Index%
		If ErrorLevel
			break
		IfEqual,line,[%header%]
		{
			count := A_Index
			break
		}
	}
		
		Loop
	{
		count := ++count
		FileReadLine, valeur,%inifile%, %count%
		if ErrorLevel
		{
			break
		}

		StringSplit, CaracArray, valeur,,
		
		if CaracArray1 = [
		{
			Loop, %CaracArray0%
			{
				last_carac := caracArray%a_index%
				controler=%caracArray1%%last_carac%
				if controler = [`;
				{
					break
				}
				
				if controler = []
				{
					break
				}
			}
		}

		if controler = []
		{
			break
		}	

		if caracArray1 = `;
		{
			Continue
		}

		if caracArray1 = `#
		{
			Continue
		}

		if caracArray1 = `!
		{
			Continue
		}

		if valeur =
		{
			break
		}

		else
		{
			If list=
			{
				TestString = %valeur%
				StringSplit, word_array, TestString, =,  ; Omits periods.
				if word_array2 = %excepte%
				{
					Continue
				}
				list=%word_array2%
			}
			Else
			{
				TestString = %valeur%
				StringSplit, word_array, TestString, =,  ; Omits periods.
				if word_array2 = %excepte%
				{
					Continue
				}
				Loop, Parse, list, |
				{
					IfEqual, A_LoopField, %word_array2%
					{
						controler2 = 0
						break
					}
					controler2 = 1
				}

				IfEqual,controler2,1
				{
					list=%list%|%word_array2%
				}
			}
		}
		; Continue
	}
	Return, list
}
; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------


; ------------------------------------------------------------------------------
; Où on crée la liste des extensions associées à l'application sélectionnée
; ------------------------------------------------------------------------------
GetExtWithAppList(inifile,header,value){
	Loop
	{
		FileReadLine, line, %inifile%, %A_Index%
		If ErrorLevel
			break
		IfEqual,line,[%header%]
		{
			count := A_Index
			break
		}
	}
		
		Loop
	{
		count := count +1
		FileReadLine, valeur,%inifile%, %count%

		StringSplit, CaracArray, valeur,,%A_Space%
		if caracArray1 = [
		{
			Loop, %CaracArray0%
			{
				last_carac := caracArray%a_index%
				controler=%caracArray1%%last_carac%
				if controler = [`;
				{
					break
				}
				
				if controler = []
				{
					break
				}
			}
		}

		if controler = []
		{
			break
		}

		if caracArray1 = `;
		{
			Continue
		}

		if ErrorLevel
		{
			break
		}

		if valeur =
		{
			break
		}

		else
		{
			StringSplit, word_array, valeur, =, .  ; Omits periods.
			IniRead, thisvalue, %inifile%, %header%, %word_array1%, Il y a une erreur.
			If thisvalue = %value%
			{
				If list=
				{
					list=%word_array1%
				}
				Else
				{
					list=%list%|%word_array1%
				}
			}
		}
	}
	Return, list
}
; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; Où on crée la liste des sections d'un fichier ini
; ------------------------------------------------------------------------------
GetIniSectionList(inifile){
	Loop
	{
		FileReadLine, thisline,%inifile%, %a_index%
		If ErrorLevel
			break
		StringLeft, leftVar, thisline, 1
		StringRight, rightVar, thisline, 1

		controler = %leftVar%%rightVar%

		if ( controler = "[]" )
		{
			StringTrimLeft, thisline, thisline, 1
			StringTrimRight, thisline, thisline, 1
			If ( list = "" )
				list = %thisline%
			Else
				list = %list%|%thisline%
		}
	}
	Return, list
}
; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------


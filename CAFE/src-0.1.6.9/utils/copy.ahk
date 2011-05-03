
#Include %A_ScriptDir%

IniRead, Desk_Path, %A_ScriptDir%\copy.ini, PATH, Desk_Path

; file_path = %1%

SplitPath, 1, OutName

FileMove, %1%, %Desk_Path%\%OutName%
; msgbox, %1%, %Desk_Path%\%OutName%
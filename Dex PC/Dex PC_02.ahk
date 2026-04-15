; Salve como confirmar_dex.ahk
#NoEnv
SetWorkingDir %A_ScriptDir%

MsgBox, 64, Samsung DeX, Tentando confirmar o início do DeX...

; Dá um foco no ADB
Run, adb shell input keyevent 61 ; Envia um TAB para selecionar o botão
Sleep, 500
Run, adb shell input keyevent 61 ; Envia outro TAB por segurança
Sleep, 500
Run, adb shell input keyevent 66 ; Envia o ENTER
return
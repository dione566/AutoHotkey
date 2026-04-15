; Salve como ativar_adb.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

MsgBox, 64, ADB Setup, Certifique-se de que o celular está conectado via USB.

; Tenta conceder permissão de escrita de configurações
RunWait, adb shell pm grant com.samsung.android.app.aodservice android.permission.WRITE_SECURE_SETTINGS,, Hide
RunWait, adb shell pm grant com.samsung.android.oneconnect android.permission.WRITE_SECURE_SETTINGS,, Hide

; Comando para simular o "OK" na tela caso o pop-up de permissão apareça
; O 66 é o código para a tecla 'ENTER' no Android
MsgBox, 4, Autorização, Deseja tentar enviar o comando 'ENTER' para aceitar o pop-up invisível?
IfMsgBox Yes
{
    Run, adb shell input keyevent 66
}

MsgBox, 48, Concluído, Comandos enviados. Verifique se o espelhamento iniciou.
Return
; Script para Limpar Cache de Ícones do Windows
; Compatível com AHK v1.1+

#NoEnv
SetWorkingDir %A_ScriptDir%
SendMode Input

; Verifica se o script está rodando como Administrador
if not A_IsAdmin
{
    Run *RunAs "%A_ScriptFullPath%"
    ExitApp
}

MsgBox, 4, Limpar Ícones, Deseja fechar o Windows Explorer e limpar o cache de ícones agora?
IfMsgBox No
    Return

; 1. Fecha o Windows Explorer de forma forçada
Process, Close, explorer.exe

; 2. Aguarda um momento para garantir que o processo fechou
Sleep, 1000

; 3. Caminho do cache de ícones local
IconCache := A_LocalAppData . "\IconCache.db"
IconCacheDir := A_LocalAppData . "\Microsoft\Windows\Explorer"

; 4. Deleta o arquivo IconCache.db principal
IfExist, %IconCache%
{
    FileSetAttrib, -H, %IconCache%
    FileDelete, %IconCache%
}

; 5. Deleta os arquivos de cache da pasta Explorer (thumbnails e ícones específicos)
FileDelete, %IconCacheDir%\iconcache*.db
FileDelete, %IconCacheDir%\thumbcache*.db

; 6. Reinicia o Windows Explorer
Run, explorer.exe

MsgBox, 64, Concluído, O cache de ícones foi limpo e o Explorer reiniciado.
Return
; --- Script para Limpar Listas de Histórico Internas ---
#NoEnv
SetBatchLines, -1

MsgBox, 4, Limpeza Profunda, Deseja limpar as listas de histórico internas do VLC e Windows?
IfMsgBox No
    ExitApp

; 1. VLC MEDIA PLAYER (Limpeza no arquivo de configuração)
VLC_Config := A_AppData . "\vlc\vlc-qt-interface.ini"
if FileExist(VLC_Config) {
    ; Remove as seções que guardam os caminhos dos vídeos
    IniDelete, %VLC_Config%, RecentMru
    IniDelete, %VLC_Config%, RecentsMru
    IniDelete, %VLC_Config%, MediaLibrary
}

; 2. WINDOWS MEDIA PLAYER (Limpeza no Registro)
; Apaga a lista de arquivos e URLs abertas recentemente
RegDelete, HKEY_CURRENT_USER\Software\Microsoft\MediaPlayer\Player\RecentFileList_WMP
RegDelete, HKEY_CURRENT_USER\Software\Microsoft\MediaPlayer\Player\RecentURLList

; 3. FILMES E TV / WINDOWS (Jump Lists)
; Isso limpa o que aparece quando você clica com o botão direito no ícone da barra de tarefas
FileRemoveDir, %A_AppData%\Microsoft\Windows\Recent\AutomaticDestinations, 1
FileCreateDir, %A_AppData%\Microsoft\Windows\Recent\AutomaticDestinations
FileRemoveDir, %A_AppData%\Microsoft\Windows\Recent\CustomDestinations, 1
FileCreateDir, %A_AppData%\Microsoft\Windows\Recent\CustomDestinations

; 4. REGISTRO GERAL DE EXTENSÕES (OpenSavePidlMRU)
; O Windows guarda o histórico por extensão de arquivo (mp4, avi, etc)
RegDelete, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\OpenSavePidlMRU

MsgBox, 64, Concluído, As listas de histórico internas foram resetadas!
ExitApp
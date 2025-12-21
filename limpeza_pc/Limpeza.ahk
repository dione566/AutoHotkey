; Script para Limpar Histórico de Mídia e Arquivos Recentes
; Salve como .ahk e execute como Administrador para melhores resultados

SetTitleMatchMode, 2

MsgBox, 4, Limpeza, Deseja limpar o histórico de arquivos recentes e miniaturas?
IfMsgBox, No
    Return

; 1. Limpa a pasta de Itens Recentes (Recent Items)
FileRemoveDir, %A_AppData%\Microsoft\Windows\Recent, 1
FileCreateDir, %A_AppData%\Microsoft\Windows\Recent

; 2. Limpa o histórico do Acesso Rápido (Frequent Files/Folders)
Run, cmd.exe /c "del /f /q /s `%AppData`%\Microsoft\Windows\Recent\AutomaticDestinations\*", , Hide
Run, cmd.exe /c "del /f /q /s `%AppData`%\Microsoft\Windows\Recent\CustomDestinations\*", , Hide

; 3. Limpa o cache de miniaturas (thumbnails) de imagens e vídeos
; Nota: O Explorer precisa ser reiniciado para liberar os arquivos de cache
Run, taskkill /f /im explorer.exe, , Hide
Sleep, 2000  ; Espera 2 segundos para o sistema processar o fechamento
Run, explorer.exe

; 4. Esvazia a Lixeira
FileRecycleEmpty

MsgBox, 64, Concluído, O histórico de arquivos e miniaturas foi limpo com sucesso!
Return
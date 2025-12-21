; Script para localizar vídeos no computador
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; Selecionar a pasta de busca
FileSelectFolder, PastaBusca, , 3, Selecione a pasta ou unidade para buscar vídeos:
if (PastaBusca = "") {
    MsgBox, Nenhuma pasta selecionada. Encerrando.
    ExitApp
}

MsgBox, 64, Buscando..., A busca começou. Isso pode demorar dependendo do tamanho do disco. Você será avisado ao terminar.

; Definir o arquivo de saída na Área de Trabalho
ArquivoLog := A_Desktop . "\videos_encontrados.txt"

; Se já existir um log antigo, deleta para criar um novo
IfExist, %ArquivoLog%
    FileDelete, %ArquivoLog%

; Extensões de vídeo comuns
Extensoes := "*.mp4;*.mkv;*.avi;*.mov;*.wmv;*.flv;*.mpg;*.mpeg"

; Loop de busca (R = Recursivo, busca em subpastas)
Loop, Files, %PastaBusca%\*.*, R
{
    ; Verifica se a extensão do arquivo atual está na lista de vídeos
    if A_LoopFileExt in mp4,mkv,avi,mov,wmv,flv,mpg,mpeg
    {
        ; Escreve o caminho completo do vídeo no arquivo de texto
        FileAppend, %A_LoopFileFullPath%`n, %ArquivoLog%
    }
}

; Verificar se encontrou algo
IfExist, %ArquivoLog%
{
    MsgBox, 64, Concluído, A busca terminou! Os locais dos vídeos foram salvos em:`n%ArquivoLog%
    Run, %ArquivoLog% ; Abre o arquivo com os resultados
}
else
{
    MsgBox, 48, Resultado, Nenhum vídeo foi encontrado na pasta selecionada.
}

Return
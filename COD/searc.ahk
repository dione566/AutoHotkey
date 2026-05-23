; Atalho: Ctrl + Clique Esquerdo do mouse
^LButton::
    ; 1. Pega a posição atual do mouse
    MouseGetPos, MouseX, MouseY
    
    ; 2. Captura a cor do pixel nessa posição (no formato RGB)
    PixelGetColor, CorCapturada, %MouseX%, %MouseY%, RGB
    
    ; 3. Define o caminho do arquivo TXT na Área de Trabalho
    CaminhoArquivo := A_Desktop . "\CoresLista.txt"
    
    ; 4. Lê o arquivo se ele já existir para não apagar o que você já salvou
    ConteudoAtual := ""
    if FileExist(CaminhoArquivo) {
        FileRead, ConteudoAtual, %CaminhoArquivo%
    }
    
    ; 5. Processa ou cria a lista no formato: CoresLista := [0x111111, 0x222222]
    if (ConteudoAtual = "") {
        ; Se o arquivo estiver vazio, cria a primeira linha
        NovoConteudo := "CoresLista    := [" . CorCapturada . "]"
    } else {
        ; Se já tiver cores, remove o "]" do final, adiciona a nova cor e fecha o "]" novamente
        ; Usamos StringReplace para limpar quebras de linha que possam atrapalhar
        ConteudoLimpo := RegExReplace(ConteudoAtual, "\s*\]\s*$", "")
        NovoConteudo := ConteudoLimpo . ", " . CorCapturada . "]"
    }
    
    ; 6. Grava de volta no arquivo da Área de Trabalho (sobrescrevendo o antigo com a lista atualizada)
    FileDelete, %CaminhoArquivo%
    FileAppend, %NovoConteudo%, %CaminhoArquivo%
    
    ; 7. Mostra um aviso rápido perto do mouse para você saber que funcionou
    ToolTip, Cor %CorCapturada% copiada!, % MouseX + 10, % MouseY + 10
    SetTimer, RemoveToolTip, -1000
return

RemoveToolTip:
    ToolTip
return
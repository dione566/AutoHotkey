#NoEnv
SetWorkingDir %A_ScriptDir%

; Atalho: Pressione F1 para selecionar a pasta e renomear os arquivos em Base64 sequencial
F1::
    ; 1. Abre a janela para selecionar a pasta
    FileSelectFolder, PastaSelecionada, , 3, Selecione a pasta para renomear os arquivos
    
    ; Se o usuário cancelar ou não selecionar nada, interrompe o script
    if (PastaSelecionada = "") {
        MsgBox, 48, Cancelado, Nenhuma pasta foi selecionada.
        return
    }
    
    ; 2. Pergunta ao usuário qual será o nome base inicial
    InputBox, NomeBase, Nome Inicial, Digite o nome base para os arquivos (ex: Foto):,, 250, 130
    if ErrorLevel {
        MsgBox, 48, Cancelado, Operação cancelada pelo usuário.
        return
    }
    
    ; Se o usuário deixar em branco, define um padrão para não quebrar o script
    if (NomeBase = "")
        NomeBase := "Arquivo"

    ; --- NOVA ADIÇÃO: Pergunta o número inicial do contador ---
    InputBox, NumeroInicial, Contador Inicial, Digite o número onde a contagem deve começar (ex: 1 ou 9):,, 250, 150,,,,, 1
    if ErrorLevel {
        MsgBox, 48, Cancelado, Operação cancelada pelo usuário.
        return
    }

    ; Valida se o que foi digitado é realmente um número. Se não for ou estiver em branco, vira 1.
    if NumeroInicial is not integer
        Contador := 1
    else
        Contador := NumeroInicial
    ; ---------------------------------------------------------

    ArquivosProcessados := 0
    
    ; Loop através de todos os arquivos da pasta selecionada
    Loop, Files, %PastaSelecionada%\*.*, F
    {
        ; Separa o nome do arquivo da extensão
        SplitPath, A_LoopFileName, , , Extensao, NomeSemExtensao
        
        ; --- GERAÇÃO DO NOME SEQUENCIAL EM BASE64 ---
        ; Junta o Nome Base com o número atual (ex: Foto1, Foto2...)
        NomeSequencial := NomeBase . Contador
        
        ; Codifica essa junção para Base64
        NomeEmBase64 := Base64Enc(NomeSequencial)
        ; --------------------------------------------
        
        ; Remove quebras de linha que o Windows injeta na criptografia antes de validar
        NomeEmBase64 := RegExReplace(NomeEmBase64, "[\r\n]")
        
        ; Remove caracteres inválidos para arquivos no Windows e os parênteses solicitados
        NomeEmBase64 := StrReplace(NomeEmBase64, "/", "-")
        NomeEmBase64 := StrReplace(NomeEmBase64, "\", "-")
        NomeEmBase64 := StrReplace(NomeEmBase64, "=", "")
        NomeEmBase64 := StrReplace(NomeEmBase64, "(", "") 
        NomeEmBase64 := StrReplace(NomeEmBase64, ")", "") 
        
        ; Se falhou na conversão ou ficou vazio, ignora
        if (NomeEmBase64 = "" || NomeEmBase64 = "0")
            continue
            
        ; Monta o novo caminho completo mantendo a extensão original
        NovoNome := PastaSelecionada "\" NomeEmBase64 "." Extensao
        
        ; Verifica se já existe um arquivo com esse mesmo nome (segurança extra)
        if FileExist(NovoNome)
            NovoNome := PastaSelecionada "\" NomeEmBase64 "_" Contador "." Extensao
        
        ; Renomeia o arquivo
        FileMove, %A_LoopFileFullPath%, %NovoNome%
        
        Contador++
        ArquivosProcessados++
    }
    
    MsgBox, 64, Sucesso, Processo concluido!`n%ArquivosProcessados% arquivos foram renomeados usando a base Base64 de "%NomeBase%" começando do número %NumeroInicial%.
return

; ==============================================================================
; FUNÇÃO AUXILIAR UNIVERSAL: Codificador Base64
; ==============================================================================
Base64Enc(String) {
    static CryptBinaryToString := "Crypt32.dll\CryptBinaryToString" . (A_IsUnicode ? "W" : "A")
    if (String = "")
        return ""
    
    ; Prepara o tamanho do buffer baseado no tipo do AHK (Unicode ou ANSI)
    VarSetCapacity(Bin, StrPut(String, "UTF-8"))
    Len := StrPut(String, &Bin, "UTF-8") - 1
    
    ; 0x40000001 = CRYPT_STRING_BASE64 | CRYPT_STRING_NOCR
    if !(DllCall(CryptBinaryToString, "Ptr", &Bin, "UInt", Len, "UInt", 0x40000001, "Ptr", 0, "UInt*", Size))
        return 0
    
    VarSetCapacity(B64, Size * (A_IsUnicode ? 2 : 1), 0)
    if !(DllCall(CryptBinaryToString, "Ptr", &Bin, "UInt", Len, "UInt", 0x40000001, "Str", B64, "UInt*", Size))
        return 0
        
    return B64
}
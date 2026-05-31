#Requires AutoHotkey v2.0

; --- CONFIGURAÇÃO ---
CaminhoFFmpeg := "D:\vPFS\my\CONVERTER\ffmpeg-2026-02-04-git-627da1111c-essentials_build\bin\ffmpeg.exe"
; --------------------

F1:: {
    if !FileExist(CaminhoFFmpeg) {
        MsgBox("FFmpeg não encontrado!")
        return
    }

    if !(PastaOrigem := DirSelect())
        return

    PastaSaida := PastaOrigem "\novos"
    if !DirExist(PastaSaida)
        DirCreate(PastaSaida)

    Arquivos := []
    Loop Files, PastaOrigem "\*.*"
        if (A_LoopFileExt ~= "i)^(mp4|mkv|avi|mov)$")
            Arquivos.Push({Caminho: A_LoopFileFullPath, Nome: A_LoopFileName})

    Total := Arquivos.Length
    if (Total = 0)
        return

    ; --- Interface Simples ---
    Prog := Gui("+MinSize +AlwaysOnTop", "Conversor Ultra Rápido (Apenas Áudio)")
    Prog.SetFont("s10", "Segoe UI")
    
    StatusTxt := Prog.Add("Text", "w450 Center", "Iniciando...")
    TempoTxt := Prog.Add("Text", "w450 Center cBlue", "Aguarde...")
    
    Prog.OnEvent("Close", (*) => ExitApp())
    Prog.Show()

    InicioGeral := A_TickCount

    for i, Arq in Arquivos {
        StatusTxt.Value := "Copiando Vídeo e Comprimindo Áudio (" i "/" Total "): " Arq.Nome
        
        ; COMANDO ULTRA RÁPIDO:
        ; -c:v copy -> COPIA O VÍDEO ORIGINAL SEM MEXER NA QUALIDADE (Zero processamento de vídeo)
        ; -c:a aac -ac 1 -b:a 32k -> Comprime apenas o áudio para o mínimo
        Comando := '"' CaminhoFFmpeg '" -i "' Arq.Caminho '" -c:v copy -c:a aac -ac 1 -b:a 32k -y "' PastaSaida '\' Arq.Nome '"'
        
        RunWait(Comando, , "Hide")
    }

    TempoTxt.Value := "Concluído em " Round((A_TickCount - InicioGeral) / 1000, 1) " segundos."
    StatusTxt.Value := "Finalizado!"
    
    SoundBeep(750, 500)
    MsgBox "Sucesso! Áudio comprimido e vídeo preservado.", "FFmpeg", "Iconi"
    Prog.Destroy()
}
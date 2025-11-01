; --- Variável de Controle e Configuração Inicial ---
; Define a variável de controle para o loop:
; 1 = PODE rodar (Ativo)
; 0 = NÃO PODE rodar (Parado)
LoopControl := 1

; Chama a rotina uma vez para definir o ToolTip inicial ao carregar o script
GoSub, CheckLoopState 

; --- HOTKEY para PARAR o Loop (Desativar) ---
; Z: Para a execução do autoclicker
z::
{
    LoopControl := 0 ; Define a flag como PARADO
    GoSub, CheckLoopState ; Atualiza o ToolTip e define o timer para ele sumir
    return
}

; --- HOTKEY para PERMITIR o Loop (Ativar) ---
; F1: Permite a execução do autoclicker
F1::
{
    LoopControl := 1 ; Define a flag como ATIVO
    GoSub, CheckLoopState ; Atualiza o ToolTip e define o timer para ele sumir
    return
}

; --- ROTINA DE VERIFICAÇÃO DO ESTADO ---
; Gerencia a exibição do ToolTip com base na variável LoopControl.
CheckLoopState:
{
    ; Cancela qualquer ToolTipOff pendente antes de exibir um novo
    SetTimer, ToolTipOff, Off
    
    if (LoopControl = 0)
    {
        ; Exibe o ToolTip de SCRIPT DESATIVADO
        ToolTip, 🔴 SCRIPT DESATIVO (Parado). Pressione F1 para Ativar., A_ScreenWidth/2 - 100, A_ScreenHeight/2 - 50
    }
    else
    {
        ; Exibe o ToolTip de SCRIPT ATIVO
        ToolTip, 🟢 SCRIPT ATIVO (Rodando). Pressione Z para Parar., A_ScreenWidth/2 - 100, A_ScreenHeight/2 - 50
    }
    
    ; Define um temporizador para chamar ToolTipOff em 2000ms (3 segundos).
    ; O sinal negativo (-2000) faz com que o timer se execute APENAS UMA VEZ.
    SetTimer, ToolTipOff, -2000
    
    return
}

; --- ROTINA PARA DESLIGAR O TOOLTIP ---
ToolTipOff:
{
    ToolTip ; Chamando ToolTip sem argumentos remove a dica da tela.
    return
}


; --- HOTKEY PRINCIPAL (Loop de Repetição) ---
; O til (~) permite que o LButton execute sua função normal (clicar) E inicie o script.
~LButton::
{
    ; O 'While' só começa E só continua rodando se o LButton estiver pressionado E a flag LoopControl for 1 (ATIVO)
    While GetKeyState("LButton", "P") AND (LoopControl = 1)
    {
        ; --- INÍCIO DA SEQUÊNCIA DE COMANDOS ---
        
        ; Simulação do clique (LButton Down + LButton Up)
        Send {LButton Down}
        Sleep 5
        Send {LButton Up}

        ; Simulação da tecla q (Down + Up)
        Send {q Down}
        Sleep 5
        Send {q Up}

        ; Simulação da tecla q (Down + Up)
        Send {q Down}
        Sleep 5
        Send {q Up}
        
        ; Tempo de ESPERA entre uma sequência COMPLETA e a próxima.
        Sleep 410 
    }
    return ; O script sai do loop quando você solta o LButton OU quando LoopControl é 0
}
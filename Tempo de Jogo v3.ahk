; -------------------------------------------------------------------------
; VARIÁVEIS DE CONFIGURAÇÃO
; -------------------------------------------------------------------------

; !!! SENHAS DIFERENTES !!!
SenhaCorretaAtivacao := "123" 	; Senha para ATIVAR o temporizador (F7)
SenhaCorretaCancelamento := "263899" ; Senha para CANCELAR o temporizador (F8)

; Posição onde o ToolTip irá aparecer (topo esquerdo)
PosicaoX := 10 ; <<--- ESTE VALOR BAIXO (10) GARANTE O LADO ESQUERDO
PosicaoY := 10

; Variáveis globais para o temporizador
Contador := 0
TempoLegivel := ""
; Variável para controlar o estado do temporizador (0 = Inativo, 1 = Ativo)
TemporizadorAtivo := 0 

; -------------------------------------------------------------------------
; EXECUÇÃO AUTOMÁTICA (AUTO-EXECUTE SECTION)
; -------------------------------------------------------------------------

; Esta seção é executada automaticamente quando o script é iniciado.
ToolTip, Pressione F7 para definir o tempo de bloqueio de tela., %PosicaoX%, %PosicaoY%, 1
return ; Finaliza a seção de auto-execução

; -------------------------------------------------------------------------
; HOTKEY PRINCIPAL (F7) - ATIVAÇÃO
; -------------------------------------------------------------------------

*F7::
	; VERIFICA SE O TEMPORIZADOR JÁ ESTÁ ATIVO (O BLOQUEIO)
	if (TemporizadorAtivo = 1)
	{
		MsgBox, 48, Bloqueio de Tela, O temporizador já está ativo! Pressione F8 para cancelar antes de redefinir.
		return ; BLOQUEIA A EXECUÇÃO DO F7 se o temporizador estiver rodando
	}

	; 1. SOLICITAÇÃO DE SENHA DE ATIVAÇÃO
	InputBox, SenhaDigitada, Bloqueio de Tela - Ativação, Digite a senha, HIDE

	; Verifica se a senha está correta
	if (SenhaDigitada != SenhaCorretaAtivacao)
	{
		MsgBox, 48, Bloqueio de Tela, Senha incorreta! A ativação foi cancelada.
		ToolTip, Pressione F7 para definir o tempo de bloqueio de tela., %PosicaoX%, %PosicaoY%, 1
		return
	}
	
	; 2. SOLICITAÇÃO DE TEMPO (OPÇÕES 1, 2 E 4)
	MensagemTempo := "Agora digite a opção de tempo:" . "`n`n"
					. "1 = 1 hora" . "`n" ; *** MODIFICADO DE 30 MINUTOS ***
					. "2 = 2 horas" . "`n" ; *** MODIFICADO DE 60 MINUTOS ***
					. "3 = (OPÇÃO REMOVIDA)" . "`n" ; *** REMOVIDO PARA EVITAR CONFUSÃO, USAMOS APENAS 1, 2 E 4 ***
					. "4 = (digitar o tempo em minutos)"

	; *ATENÇÃO*: Tive que manter a Opção 3 na mensagem para que "4" ainda fosse a opção de tempo livre, ou ajustar a lógica
	; A lógica abaixo foi ajustada para usar 1 (1h), 2 (2h) e 4 (livre). A mensagem foi ajustada para refletir isso.
	MensagemTempo := "Agora digite a opção de tempo:" . "`n`n"
					. "1 = 1 hora" . "`n"
					. "2 = 2 horas" . "`n"
					. "4 = (digitar o tempo em minutos)"
					
	InputBox, Opcao, Bloqueio de Tela - Seleção de Tempo, %MensagemTempo%, , 350, 210
	
	; Verifica se o usuário cancelou
	if (ErrorLevel)
	{
		MsgBox, , Bloqueio de Tela, Seleção de tempo cancelada.
		ToolTip, Pressione F7 para definir o tempo de bloqueio de tela., %PosicaoX%, %PosicaoY%, 1
		return
	}

	; 3. CONVERSÃO E VALIDAÇÃO DA OPÇÃO
	MinutosTemporizador := 0
	
	; ***************************************************************
	; *** NOVA LÓGICA DE TEMPO: 1 (1H), 2 (2H), OUTROS INVÁLIDOS, 4 (LIVRE) ***
	; ***************************************************************
	if (Opcao = 1)
	{
		MinutosTemporizador := 60
		TempoLegivel := "1 hora"
	}
	else if (Opcao = 2)
	{
		MinutosTemporizador := 120
		TempoLegivel := "2 horas"
	}
	; ***************************************************************
	; NOVA OPÇÃO DE TEMPO LIVRE (4)
	; ***************************************************************
	else if (Opcao = 4)
	{
		Loop ; Cria um loop para garantir que um valor válido seja digitado
		{
			InputBox, MinutosDigitados, Bloqueio de Tela - Tempo Livre, Digite o tempo desejado (em minutos):
			
			; Verifica se o usuário cancelou a entrada de tempo livre
			if (ErrorLevel)
			{
				MsgBox, , Bloqueio de Tela, Seleção de tempo cancelada.
				ToolTip, Pressione F7 para definir o tempo de bloqueio de tela., %PosicaoX%, %PosicaoY%, 1
				return ; Sai da Hotkey F7
			}

			; Verifica se o valor digitado é um número inteiro e positivo
			if (MinutosDigitados is integer) and (MinutosDigitados > 0)
			{
				MinutosTemporizador := MinutosDigitados
				TempoLegivel := MinutosDigitados . " minutos (Livre"
				break ; Sai do Loop, o tempo é válido
			}
			else
			{
				MsgBox, 48, Bloqueio de Tela, Entrada inválida! Digite apenas um número inteiro positivo de minutos.
			}
		}
	}
	; ***************************************************************
	; FIM DA NOVA OPÇÃO
	; ***************************************************************
	else
	{
		MsgBox, 48, Bloqueio de Tela, Opção inválida digitada. O bloqueio foi cancelado.
		ToolTip, Pressione F7 para definir o tempo de bloqueio de tela., %PosicaoX%, %PosicaoY%, 1
		return
	}
	
	; 4. INICIALIZAÇÃO DO TEMPORIZADOR
	Contador := MinutosTemporizador * 60
	TemporizadorAtivo := 1 ; *** DEFINE O TEMPORIZADOR COMO ATIVO ***
	
	SetTimer, ContagemRegressiva, 1000
	
	MsgBox, , Bloqueio de Tela, Temporizador de %TempoLegivel% ATIVADO. Pressione F8 para cancelar.
return

; -------------------------------------------------------------------------
; HOTKEY (F8) - CANCELAMENTO
; -------------------------------------------------------------------------

F8::
	; Verifica se há algo para cancelar
	if (TemporizadorAtivo = 0)
	{
		MsgBox, , Bloqueio de Tela, Nenhum temporizador ativo para cancelar.
		return
	}

	; 1. Solicita a senha de cancelamento
	InputBox, SenhaDigitada, Bloqueio de Tela - Cancelamento, Digite a senha de cancelamento, HIDE

	; Verifica a senha de cancelamento
	if (SenhaDigitada = SenhaCorretaCancelamento)
	{
		; Senha correta: Interrompe o temporizador e limpa a tela.
		SetTimer, ContagemRegressiva, Off
		ToolTip, , , , 1 ; Limpa o ToolTip
		TemporizadorAtivo := 0 ; *** DEFINE O TEMPORIZADOR COMO INATIVO ***
		MsgBox, 64, Bloqueio de Tela, CANCELADO COM SUCESSO
		ToolTip, Pressione F7 para definir o tempo de bloqueio de tela., %PosicaoX%, %PosicaoY%, 1
	}
	else
	{
		; Senha incorreta.
		MsgBox, 48, Bloqueio de Tela, Senha de cancelamento incorreta! O temporizador continua ATIVO.
	}
return

; -------------------------------------------------------------------------
; HOTKEY DE SAÍDA FINAL (F10)
; -------------------------------------------------------------------------

; Use F10 (ou outra tecla) para fechar o script completamente, se necessário.
F10::
	ExitApp
return

; -------------------------------------------------------------------------
; ROTINA DE CONTAGEM REGRESSIVA (Chamada a cada 1 segundo por SetTimer)
; -------------------------------------------------------------------------

ContagemRegressiva:
	if (Contador <= 0)
	{
		; 1. Fim do tempo: desliga o temporizador e limpa o ToolTip
		SetTimer, ContagemRegressiva, Off
		ToolTip, , , , 1
		TemporizadorAtivo := 0 ; *** DEFINE O TEMPORIZADOR COMO INATIVO ***
		
		; 2. Bloqueia o computador
		DllCall("LockWorkStation")
		
		; 3. Finaliza a rotina
		return
	}

	; 4. Atualiza o ToolTip com o tempo restante
	TempoRestanteFormatado := FormatarTempo(Contador)
	
	Mensagem := "" TempoRestanteFormatado . "`n"
			 . "(" TempoLegivel ")"
	
	; O ToolTip é exibido usando %PosicaoX% e %PosicaoY%
	ToolTip, %Mensagem%, %PosicaoX%, %PosicaoY%, 1
	
	; 5. Reduz o contador para a próxima chamada
	Contador--
return

; -------------------------------------------------------------------------
; FUNÇÃO AUXILIAR DE FORMATAÇÃO DE TEMPO (NO FINAL DO SCRIPT)
; -------------------------------------------------------------------------

FormatarTempo(TotalSegundos)
{
	Horas := Floor(TotalSegundos / 3600)
	RestoSegundos := Mod(TotalSegundos, 3600)
	Minutos := Floor(RestoSegundos / 60)
	Segundos := Mod(RestoSegundos, 60)
	
	Minutos := (Minutos < 10 ? "0" : "") Minutos
	Segundos := (Segundos < 10 ? "0" : "") Segundos
	
	if (Horas > 0)
	{
		Horas := (Horas < 10 ? "0" : "") Horas
		return Horas ":" Minutos ":" Segundos	
	}
	else
	{
		return Minutos ":" Segundos
	}
}
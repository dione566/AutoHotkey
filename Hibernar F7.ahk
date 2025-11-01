; Pressionar F7 para Hibernar o Sistema
F7::
    ; DllCall("PowrProf\SetSuspendState", "Int", 1, "Int", 0, "Int", 0)
    ; Parâmetros do DllCall("PowrProf\SetSuspendState", A, B, C):
    ; A = 1 (Hibernar) ou 0 (Suspender/Dormir)
    ; B = 0 (Permitir que aplicativos se recusem) ou 1 (Suspender Imediatamente)
    ; C = 0 (Não desabilitar eventos de ativação) ou 1 (Desabilitar eventos de ativação)
    
    ; Aqui, Int, 1 => Hibernar
    ; Int, 0 => Permitir que aplicativos se recusem (melhor para a maioria dos casos)
    ; Int, 0 => Não desabilitar eventos de ativação (o sistema pode ser ativado normalmente)
    DllCall("PowrProf\SetSuspendState", "Int", 1, "Int", 0, "Int", 0)
return
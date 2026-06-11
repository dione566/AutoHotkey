$Host.UI.RawUI.WindowTitle = "Revelador Multiformato Profundo (Anti-Corrupção)"
[console]::InputEncoding = [System.Text.Encoding]::UTF8
[console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "      REVELADOR DE MÍDIAS UNIFICADO (Modo Seguro)     " -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Escaneando todas as subpastas para restaurar arquivos..." -ForegroundColor Yellow
Write-Host ""

$processouAlgo = $false

# Define a pasta temporária no MESMO DISCO do script para evitar erro de partição
$localTempDir = Join-Path (Get-Location).Path ".tmp_revelador"
if (-not (Test-Path $localTempDir)) {
    $novaPasta = New-Item -Path $localTempDir -ItemType Directory -Force
    (Get-Item $localTempDir).Attributes = 'Directory', 'Hidden'
}

# Função auxiliar para corrigir o Base64 sem os caracteres '='
function ConvertFrom-Base64Custom ($stringB64) {
    $mod = $stringB64.Length % 4
    if ($mod -gt 0) {
        $stringB64 += "=" * (4 - $mod)
    }
    $bytes = [Convert]::FromBase64String($stringB64)
    return [System.Text.Encoding]::UTF8.GetString($bytes)
}

# Busca todas as subpastas recursivamente
Get-ChildItem -Recurse -Directory | Where-Object { $_.FullName -notlike "*\.tmp_*" } | ForEach-Object {
    $pasta = $_
    
    # Filtra apenas arquivos que pareçam estar no formato ocultado (NomeBase64.ExtensaoBase64)
    # A regex valida se o nome e a extensão contêm apenas caracteres válidos de Base64
    $arquivosOcultos = Get-ChildItem -Path $pasta.FullName -File | Where-Object { 
        $_.BaseName -match '^[A-Za-z0-9+/]+$' -and $_.Extension -match '^\.[A-Za-z0-9+/]+$' 
    }
    
    if ($arquivosOcultos) {
        Write-Host "--------------------------------------------------" -ForegroundColor Green
        Write-Host "Restaurando pasta: $($pasta.FullName.Replace((Get-Location).Path, '.'))" -ForegroundColor Green
        Write-Host "--------------------------------------------------" -ForegroundColor Green
        
        foreach ($file in $arquivosOcultos) {
            try {
                # 1. Decodifica o Nome e a Extensão originais
                $extSemPonto = $file.Extension.TrimStart('.')
                $nomeOriginal = ConvertFrom-Base64Custom $file.BaseName
                $extOriginal  = ConvertFrom-Base64Custom $extSemPonto
                
                $nomeArquivoRestaurado = "$nomeOriginal.$extOriginal"
                Write-Host "   -> Revelando: $nomeArquivoRestaurado" -ForegroundColor White
                
                $tempOutFile = Join-Path $localTempDir "temp_reveal_$(New-Guid).tmp"
                $finalOutFile = Join-Path $pasta.FullName $nomeArquivoRestaurado
                
                $fsIn = $null
                $fsOut = $null
                
                # 2. Processa o arquivo para remover os 32 bytes de lixo
                $fsIn = [System.IO.File]::OpenRead($file.FullName)
                
                # Verifica se o arquivo tem pelo menos os 32 bytes inseridos
                if ($fsIn.Length -ge 32) {
                    $fsOut = [System.IO.File]::Create($tempOutFile)
                    
                    # Pula (ignora) os primeiros 32 bytes de lixo (0x55)
                    [void]$fsIn.Seek(32, [System.IO.SeekOrigin]::Begin)
                    
                    # Copia o restante do arquivo original
                    $buffer = New-Object Byte[] 65536
                    while (($bytesRead = $fsIn.Read($buffer, 0, $buffer.Length)) -gt 0) {
                        $fsOut.Write($buffer, 0, $bytesRead)
                    }
                    
                    $fsIn.Close(); $fsIn.Dispose()
                    $fsOut.Close(); $fsOut.Dispose()
                    
                    # 3. Substitui o arquivo oculto pelo arquivo original restaurado
                    Move-Item -Path $tempOutFile -Destination $finalOutFile -Force
                    Remove-Item $file.FullName -Force
                    $processouAlgo = $true
                } else {
                    $fsIn.Close(); $fsIn.Dispose()
                    Write-Host "   [AVISO] Arquivo muito pequeno para conter a estrutura oculta: $($file.Name)" -ForegroundColor Yellow
                }
                
            } catch {
                Write-Host "   [ERRO] Falha ao restaurar $($file.Name): $($_.Exception.Message)" -ForegroundColor Red
                if ($fsIn) { $fsIn.Close(); $fsIn.Dispose() }
                if ($fsOut) { $fsOut.Close(); $fsOut.Dispose() }
                if (Test-Path $tempOutFile) { Remove-Item $tempOutFile -Force }
            }
        }
        Write-Host ""
    }
}

# Limpeza da pasta temporária local
if (Test-Path $localTempDir) {
    Remove-Item $localTempDir -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "======================================================" -ForegroundColor Cyan
if ($processouAlgo) {
    Write-Host "  CONCLUÍDO! Todos os arquivos foram restaurados ao estado original." -ForegroundColor Green
} else {
    Write-Host "  [AVISO] Nenhum arquivo ocultado foi encontrado para restauração." -ForegroundColor Red
}
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host ""
Read-Host "Pressione Enter para fechar..."
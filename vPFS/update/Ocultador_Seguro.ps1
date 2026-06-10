# Ocultador de Mídias Unificado (Recursivo, Seguro e Multi-Disco)
$Host.UI.RawUI.WindowTitle = "Ocultador Multiformato Profundo (Anti-Corrupção)"
[console]::InputEncoding = [System.Text.Encoding]::UTF8
[console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "     OCULTADOR DE MÍDIAS UNIFICADO (Modo Seguro)       " -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Escaneando todas as subpastas de forma profunda..." -ForegroundColor Yellow
Write-Host ""

# Lista de formatos suportados
$formatos = '.mp4','.mkv','.avi','.mov','.wmv','.flv','.webm','.3gp','.jpg','.jpeg','.png','.gif','.webp','.bmp','.mpg','.m4v'
$processouAlgo = $false

# Define a pasta temporária no MESMO DISCO do script para evitar erro de partição
$localTempDir = Join-Path (Get-Location).Path ".tmp_ocultador"
if (-not (Test-Path $localTempDir)) {
    $novaPasta = New-Item -Path $localTempDir -ItemType Directory -Force
    # Opcional: Deixa a pasta oculta no sistema para não incomodar
    (Get-Item $localTempDir).Attributes = 'Directory', 'Hidden'
}

# Busca todas as subpastas recursivamente
Get-ChildItem -Recurse -Directory | Where-Object { $_.FullName -notlike "*\.tmp_ocultador*" } | ForEach-Object {
    $pasta = $_
    $arquivos = Get-ChildItem -Path $pasta.FullName -File | Where-Object { $formatos -contains $_.Extension.ToLower() }
    
    if ($arquivos) {
        Write-Host "--------------------------------------------------" -ForegroundColor Green
        Write-Host "Processando pasta: $($pasta.FullName.Replace((Get-Location).Path, '.'))" -ForegroundColor Green
        Write-Host "--------------------------------------------------" -ForegroundColor Green
        
        foreach ($file in $arquivos) {
            Write-Host "   -> Ocultando: $($file.Name)" -ForegroundColor White
            
            # Garante que o arquivo temporário seja criado no mesmo disco (E:)
            $tempOutFile = Join-Path $localTempDir "temp_hide_$(New-Guid).tmp"
            $nomeSemExt = $file.BaseName
            $extSemPonto = $file.Extension.TrimStart('.')
            
            $nomeB64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($nomeSemExt)).Replace('=', '')
            $extB64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($extSemPonto)).Replace('=', '')
            
            $novoNome = "$nomeB64.$extB64"
            $finalOutFile = Join-Path $pasta.FullName $novoNome
            
            $fsIn = $null
            $fsOut = $null
            
            try {
                $fsOut = [System.IO.File]::Create($tempOutFile)
                
                $lixo = New-Object Byte[] 32
                for($i=0; $i -lt 32; $i++) { $lixo[$i] = 0x55 }
                $fsOut.Write($lixo, 0, $lixo.Length)
                
                $fsIn = [System.IO.File]::OpenRead($file.FullName)
                $buffer = New-Object Byte[] 65536
                while (($bytesRead = $fsIn.Read($buffer, 0, $buffer.Length)) -gt 0) {
                    $fsOut.Write($buffer, 0, $bytesRead)
                }
                
                $fsIn.Close(); $fsIn.Dispose()
                $fsOut.Close(); $fsOut.Dispose()
                
                # Agora o Move-Item funciona perfeitamente por estar no mesmo disco
                Move-Item -Path $tempOutFile -Destination $finalOutFile -Force
                Remove-Item $file.FullName -Force
                $processouAlgo = $true
                
            } catch {
                Write-Host "   [ERRO] Falha ao processar $($file.Name): $($_.Exception.Message)" -ForegroundColor Red
                if ($fsIn) { $fsIn.Close(); $fsIn.Dispose() }
                if ($fsOut) { $fsOut.Close(); $fsOut.Dispose() }
                if (Test-Path $tempOutFile) { Remove-Item $tempOutFile -Force }
            }
        }
        Write-Host ""
    }
}

# Limpeza da pasta temporária local no final do processo
if (Test-Path $localTempDir) {
    Remove-Item $localTempDir -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "======================================================" -ForegroundColor Cyan
if ($processouAlgo) {
    Write-Host "  CONCLUÍDO! Todas as subpastas profundas foram atualizadas." -ForegroundColor Green
} else {
    Write-Host "  [AVISO] Nenhuma mídia compatível foi encontrada." -ForegroundColor Red
}
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host ""
Read-Host "Pressione Enter para fechar..."
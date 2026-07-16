# Certifique-se de executar o PowerShell como Administrador!

# 0. Inicia o Escaneamento Completo do Windows Defender
Write-Host "Iniciando escaneamento completo do Windows Defender..." -ForegroundColor Cyan
& "C:\Program Files\Windows Defender\MpCmdRun.exe" -Scan -ScanType 2

---

# 1. Fecha processos que costumam rodar de pastas temporárias
Write-Host "Encerrando processos suspeitos..." -ForegroundColor Yellow
Get-Process | Where-Object { $_.Path -like "*\AppData\Local\Temp\*" -or $_.Path -like "*\ProgramData\*" } | Stop-Process -Force -ErrorAction SilentlyContinue

# 2. Reinicia o Explorer caso o código do vírus esteja injetado nele
Write-Host "Reiniciando o Explorer para limpar a memória..." -ForegroundColor Yellow
Stop-Process -Name explorer -Force

# 3. Remove tarefas agendadas criadas recentemente ou sem descrição
Write-Host "Limpando tarefas agendadas suspeitas..." -ForegroundColor Yellow
Get-ScheduledTask | Where-Object { $_.TaskPath -eq "\" -and ($_.Author -eq $null -or $_.Author -eq "") } | ForEach-Object {
    Unregister-ScheduledTask -TaskName $_.TaskName -Confirm:$false -ErrorAction SilentlyContinue
}

# 4. Remove políticas de restrição que o vírus injeta no registro
Write-Host "Removendo travas do Registro..." -ForegroundColor Yellow
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableAntiVirus" -ErrorAction SilentlyContinue

# 5. Força o serviço do Windows Defender a reiniciar
Write-Host "Forçando inicialização dos serviços de segurança..." -ForegroundColor Yellow
Set-Service -Name WinDefend -StartupType Automatic -ErrorAction SilentlyContinue
Start-Service -Name WinDefend -ErrorAction SilentlyContinue

# 6. Limpa os arquivos temporários do usuário (Corrigido: -Recurse)
Write-Host "Limpando a pasta Temp..." -ForegroundColor Yellow
Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue

---

Write-Host "`nProcedimento concluído. Reinicie o PC imediatamente." -ForegroundColor Green
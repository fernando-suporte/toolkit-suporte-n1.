<#
.SYNOPSIS
    Script de diagnóstico rápido para estações de trabalho (Suporte N1).
.DESCRIPTION
    Coleta informações de rede, sistema operacional, hardware e integridade de disco,
    gerando um resumo em tela para suporte técnico.
#>

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   COLETA DE DIAGNÓSTICO RÁPIDO - SUPORTE N1" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# 1. Informações Básicas do Host e SO
$HostName = $env:COMPUTERNAME$LoggedUser = $env:USERNAME$OS = (Get-CimInstance Win32_OperatingSystem).Caption

Write-Host "`n[ESTAÇÃO & USUÁRIO]" -ForegroundColor Yellow
Write-Host "Computador : $HostName"
Write-Host "Utilizador Atual : $LoggedUser"
Write-Host "Sistema Operacional: $OS"

# 2. Informações de Conectividade de Rede
Write-Host "`n[CONECTIVIDADE DE REDE]" -ForegroundColor Yellow
$NetAdapters = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike "*Loopback*" -and $_.IPAddress -notlike "169.254*" }

foreach ($adapter in$NetAdapters) {
    Write-Host "Interface : $($adapter.InterfaceAlias)"
    Write-Host "Endereço IPv4: $($adapter.IPAddress)"
}

$DefaultGateway = (Get-NetRoute -DestinationPrefix "0.0.0.0/0" -ErrorAction SilentlyContinue).NextHop
Write-Host "Gateway Padrão: $DefaultGateway"

# Teste básico de saída e DNS
$TestPing = Test-Connection -ComputerName 8.8.8.8 -Count 1 -Quiet
Write-Host "Acesso à Internet (Ping 8.8.8.8): $(if ($TestPing) {'OK'} else {'FALHA'})"

# 3. Espaço em Disco
Write-Host "`n[ARMAZENAMENTO]" -ForegroundColor Yellow
Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
    $TotalGB = [math]::Round($_.Size / 1GB, 2)
    $FreeGB = [math]::Round($_.FreeSpace / 1GB, 2)
    Write-Host "Unidade $($_.DeviceID) - Livre: $FreeGB GB de $TotalGB GB"
}

Write-Host "`nDiagnóstico concluído com sucesso." -ForegroundColor Green

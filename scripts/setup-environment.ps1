# Script para configurar o ambiente PowerShell com codificação UTF-8
# Execute este script antes de usar o start-all.ps1 se houver problemas de codificação

Write-Host "[SETUP] Configurando ambiente PowerShell..." -ForegroundColor Cyan

# Configurar codificação para UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Verificar se o Docker está instalado
$dockerVersion = docker --version 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "[DOCKER] Docker encontrado: $dockerVersion" -ForegroundColor Green
} else {
    Write-Host "[ERRO] Docker nao encontrado. Instale o Docker Desktop primeiro." -ForegroundColor Red
    Write-Host "[INFO] Download: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    exit 1
}

# Verificar se o Docker Compose está instalado
$composeVersion = docker-compose --version 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "[COMPOSE] Docker Compose encontrado: $composeVersion" -ForegroundColor Green
} else {
    Write-Host "[ERRO] Docker Compose nao encontrado." -ForegroundColor Red
    exit 1
}

# Verificar se os arquivos de secrets existem
$secretsPath = ".\secrets"
$requiredSecrets = @("postgres_user.txt", "postgres_password.txt", "rabbitmq_user.txt", "rabbitmq_password.txt")

Write-Host "[SECRETS] Verificando arquivos de secrets..." -ForegroundColor Yellow

if (-not (Test-Path $secretsPath)) {
    Write-Host "[ERRO] Diretorio secrets nao encontrado. Criando..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $secretsPath -Force
}

$missingSecrets = @()
foreach ($secret in $requiredSecrets) {
    $secretFile = Join-Path $secretsPath $secret
    if (-not (Test-Path $secretFile)) {
        $missingSecrets += $secret
    } else {
        Write-Host "[OK] $secret encontrado" -ForegroundColor Green
    }
}

if ($missingSecrets.Count -gt 0) {
    Write-Host "[AVISO] Arquivos de secrets ausentes:" -ForegroundColor Yellow
    foreach ($missing in $missingSecrets) {
        Write-Host "  - $missing" -ForegroundColor Red
    }
    Write-Host ""
    Write-Host "[INFO] Criando arquivos de exemplo..." -ForegroundColor Cyan
    
    # Criar arquivos de exemplo
    "postgres" | Out-File -FilePath (Join-Path $secretsPath "postgres_user.txt") -Encoding UTF8 -NoNewline
    "postgres123" | Out-File -FilePath (Join-Path $secretsPath "postgres_password.txt") -Encoding UTF8 -NoNewline
    "rabbitmq" | Out-File -FilePath (Join-Path $secretsPath "rabbitmq_user.txt") -Encoding UTF8 -NoNewline
    "rabbitmq123" | Out-File -FilePath (Join-Path $secretsPath "rabbitmq_password.txt") -Encoding UTF8 -NoNewline
    
    Write-Host "[CRIADO] Arquivos de secrets criados com valores padrao" -ForegroundColor Green
    Write-Host "[AVISO] ALTERE as senhas em producao!" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "[SUCESSO] Ambiente configurado com sucesso!" -ForegroundColor Green
Write-Host "[INFO] Agora voce pode executar: .\scripts\start-all.ps1 all" -ForegroundColor Cyan

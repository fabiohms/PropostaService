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

# Limpar arquivos existentes para evitar problemas de BOM
foreach ($secret in $requiredSecrets) {
    $secretFile = Join-Path $secretsPath $secret
    if (Test-Path $secretFile) {
        Remove-Item $secretFile -Force
        Write-Host "[LIMPEZA] Removido arquivo existente: $secret" -ForegroundColor Yellow
    }
}

Write-Host "[INFO] Criando arquivos de secrets sem BOM..." -ForegroundColor Cyan

# Criar arquivos de secrets com valores de compatibilidade (sem BOM)
[System.IO.File]::WriteAllText((Join-Path $secretsPath "postgres_user.txt"), "postgres", [System.Text.Encoding]::ASCII)
[System.IO.File]::WriteAllText((Join-Path $secretsPath "postgres_password.txt"), "postgres", [System.Text.Encoding]::ASCII)
[System.IO.File]::WriteAllText((Join-Path $secretsPath "rabbitmq_user.txt"), "guest", [System.Text.Encoding]::ASCII)
[System.IO.File]::WriteAllText((Join-Path $secretsPath "rabbitmq_password.txt"), "guest", [System.Text.Encoding]::ASCII)

Write-Host "[CRIADO] Arquivos de secrets criados com valores de compatibilidade:" -ForegroundColor Green
Write-Host "  - PostgreSQL: postgres/postgres" -ForegroundColor White
Write-Host "  - RabbitMQ: guest/guest" -ForegroundColor White

# Verificar arquivos foram criados corretamente
Write-Host "[VERIFICACAO] Validando arquivos criados..." -ForegroundColor Yellow
foreach ($secret in $requiredSecrets) {
    $secretFile = Join-Path $secretsPath $secret
    if (Test-Path $secretFile) {
        $content = [System.IO.File]::ReadAllText($secretFile, [System.Text.Encoding]::ASCII)
        $size = (Get-Item $secretFile).Length
        Write-Host "[OK] $secret ($size bytes): '$content'" -ForegroundColor Green
    } else {
        Write-Host "[ERRO] $secret (ausente)" -ForegroundColor Red
    }
}

Write-Host "[AVISO] ALTERE as senhas em producao!" -ForegroundColor Yellow

Write-Host ""
Write-Host "[SUCESSO] Ambiente configurado com sucesso!" -ForegroundColor Green
Write-Host "[INFO] Agora voce pode executar: .\scripts\start-all.ps1 all" -ForegroundColor Cyan

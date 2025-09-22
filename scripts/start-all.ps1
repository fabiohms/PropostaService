# Script PowerShell para configurar toda a aplicação no Windows

param(
    [Parameter(Position=0)]
    [ValidateSet("infra", "migrations", "proposta", "all", "stop", "status", "logs", "help")]
    [string]$Action = "all"
)

function Show-Usage {
    Write-Host "Configuracao completa do ambiente PropostaService" -ForegroundColor Cyan
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Uso: .\start-all.ps1 [opcao]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Opcoes:" -ForegroundColor Green
    Write-Host "  infra       Apenas infraestrutura (PostgreSQL + RabbitMQ)" -ForegroundColor White
    Write-Host "  migrations  Apenas executar migrations" -ForegroundColor White
    Write-Host "  proposta    Apenas PropostaService" -ForegroundColor White
    Write-Host "  all         Configuracao completa (padrao)" -ForegroundColor White
    Write-Host "  stop        Parar todos os servicos" -ForegroundColor White
    Write-Host "  status      Mostrar status dos servicos" -ForegroundColor White
    Write-Host "  logs        Mostrar logs de todos os servicos" -ForegroundColor White
    Write-Host ""
}

function Wait-ForHealthy {
    param (
        [string]$ServiceName,
        [int]$MaxAttempts = 30
    )
    
    Write-Host "[HEALTH] Aguardando $ServiceName ficar saudavel..." -ForegroundColor Yellow
    
    for ($i = 1; $i -le $MaxAttempts; $i++) {
        $healthStatus = docker inspect --format='{{.State.Health.Status}}' $ServiceName 2>$null
        
        if ($healthStatus -eq "healthy") {
            Write-Host "[HEALTH] $ServiceName esta saudavel!" -ForegroundColor Green
            return $true
        }
        
        Write-Host "[HEALTH] Tentativa $i/$MaxAttempts - Status: $healthStatus" -ForegroundColor Gray
        Start-Sleep 2
    }
    
    Write-Host "[ERRO] $ServiceName nao ficou saudavel apos $MaxAttempts tentativas" -ForegroundColor Red
    return $false
}

function Start-Infra {
    Write-Host "[INFRA] Iniciando infraestrutura..." -ForegroundColor Cyan
    
    # Subir a infraestrutura (que já cria sua própria rede)
    Write-Host "[DOCKER] Subindo PostgreSQL e RabbitMQ..." -ForegroundColor Yellow
    $env:COMPOSE_IGNORE_ORPHANS = "True"
    docker-compose -f docker-compose.infra.yml up -d
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[DOCKER] Containers iniciados, aguardando ficarem saudaveis..." -ForegroundColor Yellow
        
        # Aguardar PostgreSQL ficar saudável
        if (-not (Wait-ForHealthy "postgres-infra")) {
            Write-Host "[ERRO] PostgreSQL nao ficou saudavel" -ForegroundColor Red
            return $false
        }
        
        # Aguardar RabbitMQ ficar saudável
        if (-not (Wait-ForHealthy "rabbitmq-infra")) {
            Write-Host "[ERRO] RabbitMQ nao ficou saudavel" -ForegroundColor Red
            return $false
        }
        
        Write-Host "[SUCESSO] Infraestrutura configurada com sucesso!" -ForegroundColor Green
        Write-Host ""
        Write-Host "[SERVICOS] Servicos disponiveis:" -ForegroundColor Cyan
        Write-Host "PostgreSQL: localhost:5432" -ForegroundColor White
        Write-Host "RabbitMQ Management: http://localhost:15672" -ForegroundColor White
        Write-Host ""
        
        # Mostrar qual rede foi criada
        $networkName = docker inspect postgres-infra --format='{{range $name, $network := .NetworkSettings.Networks}}{{$name}}{{end}}' 2>$null
        Write-Host "[REDE] Infraestrutura rodando na rede: $networkName" -ForegroundColor Cyan
        
        return $true
    } else {
        Write-Host "[ERRO] Erro ao configurar infraestrutura" -ForegroundColor Red
        return $false
    }
}

function Start-Migrations {
    Write-Host "[MIGRATIONS] Executando migrations..." -ForegroundColor Cyan
    
    # Verificar se a rede existe
    $networkExists = docker network ls --format "{{.Name}}" | Select-String "microservices-network"
    if (-not $networkExists) {
        Write-Host "[ERRO] Rede microservices-network nao encontrada. Execute infra primeiro." -ForegroundColor Red
        return $false
    }
    
    # Verificar se o PostgreSQL está rodando e saudável
    $postgresRunning = docker ps --format "{{.Names}}" | Select-String "postgres-infra"
    if (-not $postgresRunning) {
        Write-Host "[ERRO] PostgreSQL nao esta rodando. Execute infra primeiro." -ForegroundColor Red
        return $false
    }
    
    $postgresHealthy = docker inspect --format='{{.State.Health.Status}}' postgres-infra 2>$null
    if ($postgresHealthy -ne "healthy") {
        Write-Host "[ERRO] PostgreSQL nao esta saudavel. Status: $postgresHealthy" -ForegroundColor Red
        return $false
    }
    
    # Executar migrations
    Write-Host "[DB] Aplicando migrations no banco de dados..." -ForegroundColor Yellow
    docker-compose -f docker-compose.migrations.yml run --rm proposta-migrations
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[SUCESSO] Migrations executadas com sucesso!" -ForegroundColor Green
        # Cleanup
        docker-compose -f docker-compose.migrations.yml down --remove-orphans >$null 2>&1
        Write-Host "[DB] Banco de dados atualizado e pronto para uso!" -ForegroundColor Green
        return $true
    } else {
        Write-Host "[ERRO] Erro ao executar migrations" -ForegroundColor Red
        docker-compose -f docker-compose.migrations.yml down --remove-orphans >$null 2>&1
        return $false
    }
}

function Start-Proposta {
    Write-Host "[PROPOSTA] Iniciando PropostaService..." -ForegroundColor Cyan
    
    # Verificar se a rede existe
    $networkExists = docker network ls --format "{{.Name}}" | Select-String "microservices-network"
    if (-not $networkExists) {
        Write-Host "[ERRO] Rede microservices-network nao encontrada. Execute infra primeiro." -ForegroundColor Red
        return $false
    }
    
    # Verificar se a infraestrutura está rodando e saudável
    $postgresRunning = docker ps --format "{{.Names}}" | Select-String "postgres-infra"
    $rabbitmqRunning = docker ps --format "{{.Names}}" | Select-String "rabbitmq-infra"
    
    if (-not $postgresRunning -or -not $rabbitmqRunning) {
        Write-Host "[ERRO] Infraestrutura nao esta completa. Execute infra primeiro." -ForegroundColor Red
        return $false
    }
    
    $postgresHealthy = docker inspect --format='{{.State.Health.Status}}' postgres-infra 2>$null
    $rabbitmqHealthy = docker inspect --format='{{.State.Health.Status}}' rabbitmq-infra 2>$null
    
    if ($postgresHealthy -ne "healthy" -or $rabbitmqHealthy -ne "healthy") {
        Write-Host "[ERRO] Infraestrutura nao esta saudavel. PostgreSQL: $postgresHealthy, RabbitMQ: $rabbitmqHealthy" -ForegroundColor Red
        return $false
    }
    
    # Subir o serviço de proposta
    Write-Host "[DOCKER] Subindo PropostaService..." -ForegroundColor Yellow
    docker-compose -f docker-compose.proposta.yml up -d
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[SUCESSO] PropostaService iniciado com sucesso!" -ForegroundColor Green
        Write-Host ""
        Write-Host "[SERVICO] Servico disponivel em:" -ForegroundColor Cyan
        Write-Host "API: http://localhost:5000" -ForegroundColor White
        Write-Host "Swagger: http://localhost:5000/swagger" -ForegroundColor White
        Write-Host "Health: http://localhost:5000/health" -ForegroundColor White
        Write-Host ""
        return $true
    } else {
        Write-Host "[ERRO] Erro ao iniciar PropostaService" -ForegroundColor Red
        return $false
    }
}

function Stop-All {
    Write-Host "[STOP] Parando todos os servicos..." -ForegroundColor Yellow
    docker-compose -f docker-compose.proposta.yml down
    docker-compose -f docker-compose.infra.yml down
    Write-Host "[SUCESSO] Todos os servicos foram parados" -ForegroundColor Green
}

function Show-Status {
    Write-Host "[STATUS] Status dos servicos:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "[INFRA] Infraestrutura:" -ForegroundColor Yellow
    docker-compose -f docker-compose.infra.yml ps
    Write-Host ""
    Write-Host "[PROPOSTA] PropostaService:" -ForegroundColor Yellow
    docker-compose -f docker-compose.proposta.yml ps
}

function Show-Logs {
    Write-Host "[LOGS] Logs dos servicos (Ctrl+C para sair):" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "[INFRA] Logs da infraestrutura:" -ForegroundColor Yellow
    docker-compose -f docker-compose.infra.yml logs --tail=50
    Write-Host ""
    Write-Host "[PROPOSTA] Logs do PropostaService:" -ForegroundColor Yellow
    docker-compose -f docker-compose.proposta.yml logs --tail=50
}

function Start-All {
    Write-Host "[INICIO] Iniciando configuracao completa..." -ForegroundColor Green
    
    if (-not (Start-Infra)) {
        Write-Host "[ERRO] Falha ao iniciar infraestrutura" -ForegroundColor Red
        return $false
    }
    
    Write-Host "[INFO] Pulando migrations separadas - serao executadas automaticamente pela aplicacao" -ForegroundColor Cyan
    
    if (-not (Start-Proposta)) {
        Write-Host "[ERRO] Falha ao iniciar PropostaService" -ForegroundColor Red
        return $false
    }
    
    Write-Host ""
    Write-Host "[COMPLETO] Configuracao completa finalizada!" -ForegroundColor Green
    Write-Host "[INFO] As migrations foram executadas automaticamente na inicializacao da aplicacao" -ForegroundColor Cyan
    Write-Host "[INFO] Use 'status' para verificar o estado dos servicos" -ForegroundColor Cyan
    return $true
}

# Executar ação baseada no parâmetro
switch ($Action) {
    "infra" { 
        Start-Infra | Out-Null
    }
    "migrations" { 
        Start-Migrations | Out-Null
    }
    "proposta" { 
        Start-Proposta | Out-Null
    }
    "all" { 
        Start-All | Out-Null
    }
    "stop" { 
        Stop-All 
    }
    "status" { 
        Show-Status 
    }
    "logs" { 
        Show-Logs 
    }
    "help" { 
        Show-Usage 
    }
    default { 
        Write-Host "[ERRO] Opcao invalida: $Action" -ForegroundColor Red
        Show-Usage
        exit 1
    }
}

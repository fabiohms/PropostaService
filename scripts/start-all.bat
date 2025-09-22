@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

echo [INICIO] Configuracao PropostaService
echo ====================================

if "%1"=="" (
    set ACTION=all
) else (
    set ACTION=%1
)

if "%ACTION%"=="help" goto :help
if "%ACTION%"=="infra" goto :infra
if "%ACTION%"=="migrations" goto :migrations
if "%ACTION%"=="proposta" goto :proposta
if "%ACTION%"=="all" goto :all
if "%ACTION%"=="stop" goto :stop
if "%ACTION%"=="status" goto :status
if "%ACTION%"=="logs" goto :logs

echo [ERRO] Opcao invalida: %ACTION%
goto :help

:help
echo Uso: start-all.bat [opcao]
echo.
echo Opcoes:
echo   infra       Apenas infraestrutura (PostgreSQL + RabbitMQ)
echo   migrations  Apenas executar migrations
echo   proposta    Apenas PropostaService
echo   all         Configuracao completa (padrao)
echo   stop        Parar todos os servicos
echo   status      Mostrar status dos servicos
echo   logs        Mostrar logs de todos os servicos
echo   help        Mostrar esta ajuda
goto :end

:infra
echo [INFRA] Iniciando infraestrutura...
docker network create microservices-network >nul 2>&1
echo [DOCKER] Subindo PostgreSQL e RabbitMQ...
docker-compose -f docker-compose.infra.yml up -d
if %errorlevel% neq 0 (
    echo [ERRO] Erro ao configurar infraestrutura
    exit /b 1
)
echo [SUCESSO] Infraestrutura configurada com sucesso!
echo [SERVICOS] PostgreSQL: localhost:5432
echo [SERVICOS] RabbitMQ Management: http://localhost:15672
goto :end

:migrations
echo [MIGRATIONS] Executando migrations...
docker-compose -f docker-compose.migrations.yml run --rm proposta-migrations
if %errorlevel% neq 0 (
    echo [ERRO] Erro ao executar migrations
    exit /b 1
)
docker-compose -f docker-compose.migrations.yml down --remove-orphans >nul 2>&1
echo [SUCESSO] Migrations executadas com sucesso!
goto :end

:proposta
echo [PROPOSTA] Iniciando PropostaService...
docker-compose -f docker-compose.proposta.yml up -d
if %errorlevel% neq 0 (
    echo [ERRO] Erro ao iniciar PropostaService
    exit /b 1
)
echo [SUCESSO] PropostaService iniciado com sucesso!
echo [API] Servico disponivel em: http://localhost:5000
goto :end

:all
echo [COMPLETO] Iniciando configuracao completa...
call :infra
if %errorlevel% neq 0 exit /b %errorlevel%
timeout /t 5 >nul
call :migrations
if %errorlevel% neq 0 exit /b %errorlevel%
timeout /t 2 >nul
call :proposta
if %errorlevel% neq 0 exit /b %errorlevel%
echo [COMPLETO] Configuracao completa finalizada!
goto :end

:stop
echo [STOP] Parando todos os servicos...
docker-compose -f docker-compose.proposta.yml down
docker-compose -f docker-compose.infra.yml down
echo [SUCESSO] Todos os servicos foram parados
goto :end

:status
echo [STATUS] Status dos servicos:
echo.
echo [INFRA] Infraestrutura:
docker-compose -f docker-compose.infra.yml ps
echo.
echo [PROPOSTA] PropostaService:
docker-compose -f docker-compose.proposta.yml ps
goto :end

:logs
echo [LOGS] Logs da infraestrutura:
docker-compose -f docker-compose.infra.yml logs --tail=20
echo.
echo [LOGS] Logs do PropostaService:
docker-compose -f docker-compose.proposta.yml logs --tail=20
goto :end

:end
echo.
echo [FINALIZADO] Operacao concluida

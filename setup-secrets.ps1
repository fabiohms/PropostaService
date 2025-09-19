# Script PowerShell para configurar secrets para o ambiente de desenvolvimento local
# Execute este script para criar os arquivos de secrets necessários

Write-Host 'Configurando Docker Secrets para PropostaService...' -ForegroundColor Green

# Criar diretório de secrets se não existir
if (!(Test-Path 'secrets')) {
    New-Item -ItemType Directory -Path 'secrets' | Out-Null
}

# PostgreSQL Secrets (usar ASCII para evitar BOM)
Set-Content -Path 'secrets\postgres_user.txt' -Value 'postgres' -Encoding ascii -NoNewline
Set-Content -Path 'secrets\postgres_password.txt' -Value 'postgres' -Encoding ascii -NoNewline

# RabbitMQ Secrets (usar ASCII para evitar BOM)
Set-Content -Path 'secrets\rabbitmq_user.txt' -Value 'guest' -Encoding ascii -NoNewline
Set-Content -Path 'secrets\rabbitmq_password.txt' -Value 'guest' -Encoding ascii -NoNewline

Write-Host '✅ Secrets configurados com sucesso!' -ForegroundColor Green
Write-Host ''
Write-Host 'Arquivos criados:' -ForegroundColor Yellow
Write-Host '  - secrets\postgres_user.txt'
Write-Host '  - secrets\postgres_password.txt'
Write-Host '  - secrets\rabbitmq_user.txt'
Write-Host '  - secrets\rabbitmq_password.txt'
Write-Host ''
Write-Host '⚠️  IMPORTANTE: Estes são valores padrão para desenvolvimento.' -ForegroundColor Red
Write-Host '   Em produção, use credenciais seguras e únicas!' -ForegroundColor Red
Write-Host ''
Write-Host 'ℹ️  O RabbitMQ agora usa um Dockerfile customizado que lê os secrets automaticamente.' -ForegroundColor Blue
Write-Host ''
Write-Host 'Para executar o projeto:' -ForegroundColor Cyan
Write-Host '  docker-compose up -d --build' -ForegroundColor Cyan

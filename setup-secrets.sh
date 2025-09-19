#!/bin/bash

# Script para configurar secrets para o ambiente de desenvolvimento local
# Execute este script para criar os arquivos de secrets necessários

echo "Configurando Docker Secrets para PropostaService..."

# Criar diretório de secrets se não existir
mkdir -p secrets

# PostgreSQL Secrets
echo "postgres" > secrets/postgres_user.txt
echo "postgres" > secrets/postgres_password.txt

# RabbitMQ Secrets  
echo "guest" > secrets/rabbitmq_user.txt
echo "guest" > secrets/rabbitmq_password.txt

echo "✅ Secrets configurados com sucesso!"
echo ""
echo "Arquivos criados:"
echo "  - secrets/postgres_user.txt"
echo "  - secrets/postgres_password.txt" 
echo "  - secrets/rabbitmq_user.txt"
echo "  - secrets/rabbitmq_password.txt"
echo ""
echo "⚠️  IMPORTANTE: Estes são valores padrão para desenvolvimento."
echo "   Em produção, use credenciais seguras e únicas!"
echo ""
echo "ℹ️  O RabbitMQ agora usa um Dockerfile customizado que lê os secrets automaticamente."
echo ""
echo "Para executar o projeto:"
echo "  docker-compose up -d --build"

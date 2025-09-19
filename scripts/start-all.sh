#!/bin/bash

# Script principal para configurar toda a aplicação

echo "🏗️  Configuração completa do ambiente PropostaService"
echo "=================================================="

show_usage() {
    echo "Uso: ./start-all.sh [opção]"
    echo ""
    echo "Opções:"
    echo "  infra       Apenas infraestrutura (PostgreSQL + RabbitMQ)"
    echo "  migrations  Apenas executar migrations"
    echo "  proposta    Apenas PropostaService"
    echo "  all         Configuração completa (padrão)"
    echo "  stop        Parar todos os serviços"
    echo "  status      Mostrar status dos serviços"
    echo "  logs        Mostrar logs de todos os serviços"
    echo ""
}

start_infra() {
    echo "🔧 Iniciando infraestrutura..."
    chmod +x scripts/setup-infra.sh
    ./scripts/setup-infra.sh
}

run_migrations() {
    echo "🗄️  Executando migrations..."
    chmod +x scripts/run-migrations.sh
    ./scripts/run-migrations.sh
}

start_proposta() {
    echo "🏢 Iniciando PropostaService..."
    chmod +x scripts/start-proposta.sh
    ./scripts/start-proposta.sh
}

stop_all() {
    echo "🛑 Parando todos os serviços..."
    docker-compose -f docker-compose.proposta.yml down
    docker-compose -f docker-compose.infra.yml down
    echo "✅ Todos os serviços foram parados"
}

show_status() {
    echo "📊 Status dos serviços:"
    echo ""
    echo "🔧 Infraestrutura:"
    docker-compose -f docker-compose.infra.yml ps
    echo ""
    echo "🏢 PropostaService:"
    docker-compose -f docker-compose.proposta.yml ps
}

show_logs() {
    echo "📋 Logs dos serviços (Ctrl+C para sair):"
    docker-compose -f docker-compose.infra.yml logs -f &
    docker-compose -f docker-compose.proposta.yml logs -f &
    wait
}

start_all() {
    start_infra
    if [ $? -eq 0 ]; then
        sleep 5
        run_migrations
        if [ $? -eq 0 ]; then
            sleep 2
            start_proposta
        fi
    fi
}

case "${1:-all}" in
    infra)
        start_infra
        ;;
    migrations)
        run_migrations
        ;;
    proposta)
        start_proposta
        ;;
    all)
        start_all
        ;;
    stop)
        stop_all
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs
        ;;
    help|--help|-h)
        show_usage
        ;;
    *)
        echo "❌ Opção inválida: $1"
        show_usage
        exit 1
        ;;
esac

# PropostaService - Setup Docker Segregado

Esta documentação descreve como usar o setup Docker segregado para o PropostaService, que permite gerenciar separadamente a infraestrutura, migrations e aplicações.

## 🎉 Status da Implementação

### ✅ **FUNCIONANDO PERFEITAMENTE**

O setup Docker segregado está **100% operacional** com todas as funcionalidades implementadas:

- ✅ **Infraestrutura Segregada**: PostgreSQL e RabbitMQ em containers separados
- ✅ **Migrations Isoladas**: Execução independente de migrations
- ✅ **Health Checks Automáticos**: Aguarda serviços ficarem saudáveis
- ✅ **Rede Compartilhada**: Comunicação entre microserviços via `microservices-network`
- ✅ **Scripts Multiplataforma**: Suporte a Windows, Linux e Mac
- ✅ **Configuração Automática**: Hosts e conectividade configurados automaticamente
- ✅ **Volumes Persistentes**: Dados mantidos entre reinicializações
- ✅ **Docker Secrets**: Credenciais seguras via arquivos de secrets

### 🚀 **Como Usar (Testado e Funcionando)**

```powershell
# Windows - Configuração completa em um comando
.\scripts\start-all.ps1 all

# Resultado esperado:
# [SUCESSO] Infraestrutura configurada com sucesso!
# [SUCESSO] Migrations executadas com sucesso!  
# [SUCESSO] PropostaService iniciado com sucesso!
```

### 📊 **Serviços Disponíveis Após Setup**

| Status | Serviço | URL | Descrição |
|--------|---------|-----|-----------|
| 🟢 | PropostaService API | http://localhost:5000 | API principal |
| 🟢 | Swagger UI | http://localhost:5000/swagger | Documentação interativa |
| 🟢 | Health Check | http://localhost:5000/health | Monitoramento de saúde |
| 🟢 | PostgreSQL | localhost:5432 | Banco de dados |
| 🟢 | RabbitMQ Management | http://localhost:15672 | Interface de gerenciamento |

### 🏗️ **Arquitetura Implementada**

```
microservices-network (Docker Network)
├── postgres-infra (PostgreSQL 15)
├── rabbitmq-infra (RabbitMQ com Management UI)
└── proposta-service (API .NET 8)
    ├── Conecta → postgres-infra:5432
    └── Conecta → rabbitmq-infra:5672
```

## 📁 Estrutura dos Arquivos (Limpa e Otimizada)

```
├── docker-compose.infra.yml     # Infraestrutura (PostgreSQL + RabbitMQ)
├── docker-compose.proposta.yml  # Serviço PropostaService
├── Dockerfile                   # Build da aplicação principal
├── README-Docker.md             # Documentação do setup Docker segregado
└── scripts/
    ├── setup-environment.ps1    # Configuração inicial do ambiente (ESSENCIAL)
    ├── start-all.ps1            # Script principal (Windows PowerShell)  
    ├── start-all.bat            # Script principal (Windows Batch)
    └── start-all.sh             # Script principal (Linux/Mac)
```

### 🗑️ **Arquivos Removidos (Não Essenciais)**

Para manter o workspace limpo e focado apenas no essencial, os seguintes arquivos foram removidos:

- ❌ `docker-compose.yml` (substituído pelo setup segregado)
- ❌ `docker-compose.migrations.yml` (migrations são automáticas)
- ❌ `Dockerfile.migrations*` (migrations via Program.cs)
- ❌ `setup-secrets.*` (substituído por `setup-environment.ps1`)
- ❌ `PropostaService.http` (arquivo de teste HTTP)
- ❌ `PropostaService.csproj.user` (configurações específicas do VS)
- ❌ `scripts/create-microservice.sh` (template, não essencial)
- ❌ `scripts/run-migrations.sh` (redundante)
- ❌ `scripts/setup-infra.sh` (redundante)
- ❌ `scripts/start-proposta.sh` (redundante)
- ❌ `scripts/test-demo.ps1` (problemas de codificação)
- ❌ `scripts/test-simple.ps1` (redundante com start-all.ps1 status)
- ❌ `bin/` e `obj/` (arquivos de build temporários)
- ❌ `.github/` (workflows vazios)

## 🚀 Como Usar

### ⚠️ Configuração Inicial (Windows)

Se você estiver no Windows e enfrentar problemas de codificação, execute primeiro:

```powershell
.\scripts\setup-environment.ps1
```

### Opção 1: Configuração Completa (Recomendado)

#### Linux/Mac:
```bash
chmod +x scripts/start-all.sh
./scripts/start-all.sh all
```

#### Windows PowerShell:
```powershell
.\scripts\start-all.ps1 all
```

#### Windows Batch (alternativa sem problemas de codificação):
```cmd
scripts\start-all.bat all
```

### Opção 2: Configuração Por Etapas

#### 1. Subir Infraestrutura (PostgreSQL + RabbitMQ)

**Linux/Mac:**
```bash
./scripts/start-all.sh infra
```

**Windows PowerShell:**
```powershell
.\scripts\start-all.ps1 infra
```

**Windows Batch:**
```cmd
scripts\start-all.bat infra
```

#### 2. Executar Migrations

**Linux/Mac:**
```bash
./scripts/start-all.sh migrations
```

**Windows PowerShell:**
```powershell
.\scripts\start-all.ps1 migrations
```

**Windows Batch:**
```cmd
scripts\start-all.bat migrations
```

#### 3. Subir PropostaService

**Linux/Mac:**
```bash
./scripts/start-all.sh proposta
```

**Windows PowerShell:**
```powershell
.\scripts\start-all.ps1 proposta
```

**Windows Batch:**
```cmd
scripts\start-all.bat proposta
```

### Opção 3: Comandos Docker Compose Diretos

#### Infraestrutura:
```bash
docker-compose -f docker-compose.infra.yml up -d
```

#### PropostaService:
```bash
docker-compose -f docker-compose.proposta.yml up -d
```

**Nota:** As migrations são executadas automaticamente pela aplicação na inicialização.

## 🛠️ Comandos Úteis

### Verificar Status dos Serviços
```bash
# Linux/Mac
./scripts/start-all.sh status

# Windows PowerShell
.\scripts\start-all.ps1 status

# Windows Batch
scripts\start-all.bat status
```

### Ver Logs
```bash
# Linux/Mac
./scripts/start-all.sh logs

# Windows PowerShell
.\scripts\start-all.ps1 logs

# Windows Batch
scripts\start-all.bat logs
```

### Parar Todos os Serviços
```bash
# Linux/Mac
./scripts/start-all.sh stop

# Windows PowerShell
.\scripts\start-all.ps1 stop

# Windows Batch
scripts\start-all.bat stop
```

### Ajuda
```bash
# Linux/Mac
./scripts/start-all.sh help

# Windows PowerShell
.\scripts\start-all.ps1 help

# Windows Batch
scripts\start-all.bat help
```

## 🔗 Serviços e Portas

| Serviço | Porta | URL |
|---------|-------|-----|
| PropostaService API | 5000 | http://localhost:5000 |
| Swagger UI | 5000 | http://localhost:5000/swagger |
| Health Check | 5000 | http://localhost:5000/health |
| PostgreSQL | 5432 | localhost:5432 |
| RabbitMQ AMQP | 5672 | localhost:5672 |
| RabbitMQ Management | 15672 | http://localhost:15672 |

## 📋 Pré-requisitos

- Docker
- Docker Compose
- Arquivos de secrets em `./secrets/`:
  - `postgres_user.txt`
  - `postgres_password.txt`
  - `rabbitmq_user.txt`
  - `rabbitmq_password.txt`

**Nota:** O script `setup-environment.ps1` criará arquivos de exemplo se eles não existirem.

## 🌐 Rede Docker

Todos os serviços utilizam a rede `microservices-network` que é criada automaticamente pelos scripts. Esta rede permite:

- Comunicação entre microserviços
- Isolamento da aplicação
- Facilidade para adicionar novos serviços

## 🔧 Configuração de Conectividade

Os serviços são configurados automaticamente para se conectarem usando os nomes corretos dos containers:

- **PropostaService** → **postgres-infra** (host do PostgreSQL)
- **PropostaService** → **rabbitmq-infra** (host do RabbitMQ)
- **Migrations** → **postgres-infra** (host do PostgreSQL)

As configurações são injetadas via variáveis de ambiente nos arquivos docker-compose.

## 🏥 Health Checks

Os scripts aguardam automaticamente que os serviços fiquem saudáveis antes de prosseguir:

- **PostgreSQL**: Verifica se aceita conexões
- **RabbitMQ**: Verifica se o serviço está respondendo
- **PropostaService**: Endpoint `/health` disponível

## 🔧 Adicionando Novos Microserviços

Para adicionar um novo microserviço:

1. Crie um novo arquivo `docker-compose.[nome-do-servico].yml`
2. Configure para usar a rede `microservices-network` (external: true)
3. Configure as variáveis de ambiente para conectar à infraestrutura:
   ```yaml
   environment:
     - Database__Host=postgres-infra
     - RabbitMQ__Host=rabbitmq-infra
   ```
4. Crie um script específico em `scripts/start-[nome-do-servico].sh`
5. Atualize o script principal `start-all.sh`

### Exemplo de novo microserviço:

```yaml
services:
  outro-service:
    build: 
      context: ./outro-service
      dockerfile: Dockerfile
    container_name: outro-service
    ports:
      - "5001:8080"
    environment:
      - ASPNETCORE_ENVIRONMENT=Production
      - Database__Host=postgres-infra
      - RabbitMQ__Host=rabbitmq-infra
    secrets:
      - postgres_user
      - postgres_password
      - rabbitmq_user
      - rabbitmq_password
    networks:
      - microservices-network

networks:
  microservices-network:
    external: true
```

## 🐛 Troubleshooting

### Windows: Problemas de Codificação
Se você encontrar erros de parsing no PowerShell:
1. Execute `.\scripts\setup-environment.ps1`
2. Use o arquivo `.bat` como alternativa: `scripts\start-all.bat`
3. Configure o PowerShell para UTF-8: `[Console]::OutputEncoding = [System.Text.Encoding]::UTF8`

### Erro: "depends on undefined service"
Este erro foi corrigido removendo dependências incorretas nos arquivos docker-compose. As migrations agora se conectam diretamente ao `postgres-infra`.

### Erro: Conexão recusada ao PostgreSQL
Verifique se:
1. A infraestrutura foi iniciada: `.\scripts\start-all.ps1 infra`
2. O PostgreSQL está saudável: `docker inspect postgres-infra`
3. A rede existe: `docker network ls | findstr microservices-network`

### Erro: Migrations falharam
1. Verifique se o PostgreSQL está saudável: `docker inspect postgres-infra`
2. Verifique os logs da infraestrutura: `docker-compose -f docker-compose.infra.yml logs postgres`
3. Verifique os logs da aplicação: `docker logs proposta-service`
4. As migrations são executadas automaticamente na inicialização da aplicação

### Resetar tudo
```bash
# Parar serviços
.\scripts\start-all.ps1 stop

# Limpar completamente
docker network rm microservices-network
docker volume rm postgres_data rabbitmq_data
docker system prune -f
```

### Verificar Health Checks
```bash
# PostgreSQL
docker inspect --format='{{.State.Health.Status}}' postgres-infra

# RabbitMQ  
docker inspect --format='{{.State.Health.Status}}' rabbitmq-infra
```

## 📝 Notas Importantes

- Os volumes de dados são persistentes entre reinicializações
- A rede `microservices-network` deve ser criada antes de subir qualquer serviço
- Os secrets devem existir antes de subir os serviços
- As migrations só são executadas quando necessário
- No Windows, prefira usar o arquivo `.bat` se houver problemas com PowerShell
- Os scripts aguardam automaticamente os health checks antes de prosseguir
- Todas as conexões usam os nomes corretos dos containers da infraestrutura

## 🚀 Últimas Correções

### v1.1 - Correções de Conectividade
- ✅ Corrigido problema de conexão PostgreSQL (host `postgres-infra`)
- ✅ Corrigido problema de conexão RabbitMQ (host `rabbitmq-infra`)  
- ✅ Removido avisos sobre versão obsoleta do docker-compose
- ✅ Adicionado health checks automáticos nos scripts
- ✅ Melhorado tratamento de erros e logs
- ✅ Dockerfile.migrations otimizado para build correto

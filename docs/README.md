# PropostaService - Sistema de Gestão de Propostas

Este é um sistema de gestão de propostas implementado em .NET 8 seguindo princípios de Clean Architecture e Domain-Driven Design (DDD).

## Execução com Docker Compose

Siga este guia para subir todo o ambiente do zero usando Docker Compose (API, PostgreSQL e RabbitMQ). As credenciais são provisionadas via Docker Secrets através dos scripts fornecidos.

### Pré-requisitos
- Docker Desktop (Windows/macOS) ou Docker Engine (Linux)
- Docker Compose (já incluso no Docker Desktop; em Linux use `docker compose`)
- PowerShell (Windows) ou Bash (Linux/macOS)

### Passo 1: Configurar os Docker Secrets
Configure o ambiente e crie os arquivos de secrets locais com os scripts do repositório:
- Windows (PowerShell):
  - `.\scripts\setup-environment.ps1`
- Linux/macOS (Bash):
  - `bash ./setup-secrets.sh`

Isso criará a pasta `./secrets` com:
- `secrets/postgres_user.txt` e `secrets/postgres_password.txt` (padrão: postgres/postgres)
- `secrets/rabbitmq_user.txt` e `secrets/rabbitmq_password.txt` (padrão: guest/guest)

Observações:
- Os scripts gravam em UTF-8 sem nova linha para evitar problemas de autenticação.
- Em produção, substitua por credenciais seguras.

### Passo 2: Subir os serviços
- `docker compose up -d --build`

O Compose sobe 3 serviços:
- `proposta-service` (API .NET 8)
- `postgres` (PostgreSQL 15)
- `rabbitmq` (RabbitMQ com UI de gerenciamento)

A API aguarda o Postgres e o RabbitMQ ficarem saudáveis, e aplica as migrações do EF Core automaticamente na inicialização.

### Passo 3: Verificar status e logs
- Ver status: `docker compose ps`
- Seguir logs: `docker compose logs -f`
- Logs de um serviço específico: `docker compose logs -f proposta-service`

### Endereços úteis
- API: http://localhost:5000
- Swagger: http://localhost:5000/swagger
- Health check: http://localhost:5000/health
- RabbitMQ UI: http://localhost:15672 (usuário/senha dos secrets; padrão guest/guest)
- PostgreSQL: localhost:5432 (DB: `propostadb`; usuário/senha dos secrets; padrão postgres/postgres)

### Migrações do EF Core
Não é necessário rodar comandos manuais. A aplicação chama `context.Database.Migrate()` no startup e aplica automaticamente as migrações pendentes quando o container sobe.

### Comandos úteis
- Subir/atualizar stack: `docker compose up -d --build`
- Parar stack: `docker compose down`
- Reset total (apaga volumes/dados): `docker compose down -v`
- Ver saúde dos serviços: `curl http://localhost:5000/health`

### Solução de problemas
- Conflito de portas: altere os mapeamentos no `docker-compose.yml` (ex.: `5000:8080`, `5432:5432`, `15672:15672`).
- Secrets ausentes/incorretos: execute novamente `.\scripts\setup-environment.ps1`.
- Credenciais inválidas no RabbitMQ: os scripts e a imagem customizada normalizam quebras de linha; recrie os secrets e reinicie: `docker compose down && docker compose up -d --build`.
- Banco não inicia: remova volumes e suba novamente: `docker compose down -v && docker compose up -d --build`.

---

## Arquitetura

O projeto segue uma arquitetura em camadas bem definida:

```
PropostaService/
├── Domain/           # Camada de Domínio (Entities, Events, Ports)
├── Application/      # Camada de Aplicação (Services, Use Cases)
├── Infrastructure/   # Camada de Infraestrutura (Data, Messaging)
├── Api/              # Camada de Apresentação (Controllers, DTOs)
└── Tests/            # Testes Unitários
```

### Camadas
- Domain: Regras de negócio, entidades e eventos
- Application: Orquestração dos casos de uso
- Infrastructure: Repositórios e integrações externas
- API: Controllers e contratos da API REST
- Tests: Testes unitários com xUnit e Moq

## Tecnologias Utilizadas
- .NET 8
- Entity Framework Core
- PostgreSQL
- RabbitMQ
- xUnit e Moq
- Swagger/OpenAPI
- Docker e Docker Compose

## Endpoints da API (principais)
- GET `/api/propostas`
- GET `/api/propostas/{id}`
- POST `/api/propostas`
- PATCH `/api/propostas/{id}/status`

Exemplos de payloads estão na seção original do projeto e podem ser exercitados via Swagger.

## Qualidade de Código
- Clean Architecture e DDD
- SOLID
- Testes unitários
- Documentação Swagger
- Eventos de domínio

Desenvolvido por: Fábio H. M. Silva em 19/09/2025

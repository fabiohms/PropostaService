using Microsoft.EntityFrameworkCore;
using PropostaService.Infrastructure.Configuration;
using PropostaService.Infrastructure.Data;
using RabbitMQ.Client;
using Microsoft.Extensions.Diagnostics.HealthChecks;

namespace PropostaService.Infrastructure.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddDatabaseWithSecrets(this IServiceCollection services, IConfiguration configuration)
    {
        string connectionString;
        
        if (DockerSecretsReader.IsRunningInContainer())
        {
            // Executando em container com secrets
            var host = configuration["Database:Host"] ?? "postgres";
            var database = configuration["Database:Name"] ?? "propostadb";
            var port = configuration.GetValue<int>("Database:Port", 5432);
            
            connectionString = DockerSecretsReader.BuildPostgresConnectionString(host, database, port);
        }
        else
        {
            // Executando localmente - usar configuração padrão
            connectionString = configuration.GetConnectionString("DefaultConnection") 
                ?? throw new InvalidOperationException("DefaultConnection string not found");
        }
        
        services.AddDbContext<PropostaDbContext>(options =>
            options.UseNpgsql(connectionString));
            
        return services;
    }
    
    public static IServiceCollection AddRabbitMQWithSecrets(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddSingleton<IConnection>(sp =>
        {
            var factory = new ConnectionFactory();
            
            if (DockerSecretsReader.IsRunningInContainer())
            {
                // Executando em container com secrets
                var (username, password) = DockerSecretsReader.GetRabbitMQCredentials();
                factory.HostName = configuration["RabbitMQ:Host"] ?? "rabbitmq";
                factory.UserName = username;
                factory.Password = password;
                factory.Port = configuration.GetValue<int>("RabbitMQ:Port", 5672);
            }
            else
            {
                // Executando localmente - usar configuração padrão
                factory.HostName = configuration["RabbitMQ:Host"] ?? "localhost";
                factory.UserName = configuration["RabbitMQ:Username"] ?? "guest";
                factory.Password = configuration["RabbitMQ:Password"] ?? "guest";
                factory.Port = configuration.GetValue<int>("RabbitMQ:Port", 5672);
            }
            
            return factory.CreateConnectionAsync().Result;
        });
        
        return services;
    }
    
    public static IServiceCollection AddHealthChecksWithSecrets(this IServiceCollection services, IConfiguration configuration)
    {
        var healthChecks = services.AddHealthChecks();
        
        if (DockerSecretsReader.IsRunningInContainer())
        {
            // Health checks com secrets
            var host = configuration["Database:Host"] ?? "postgres";
            var database = configuration["Database:Name"] ?? "propostadb";
            var port = configuration.GetValue<int>("Database:Port", 5432);
            var connectionString = DockerSecretsReader.BuildPostgresConnectionString(host, database, port);
            
            var (rabbitUsername, rabbitPassword) = DockerSecretsReader.GetRabbitMQCredentials();
            var rabbitHost = configuration["RabbitMQ:Host"] ?? "rabbitmq";
            var rabbitPort = configuration.GetValue<int>("RabbitMQ:Port", 5672);
            
            healthChecks
                .AddNpgSql(connectionString)
                .AddCheck("rabbitmq", () => 
                {
                    try
                    {
                        var factory = new ConnectionFactory
                        {
                            HostName = rabbitHost,
                            UserName = rabbitUsername,
                            Password = rabbitPassword,
                            Port = rabbitPort
                        };
                        using var connection = factory.CreateConnectionAsync().Result;
                        return HealthCheckResult.Healthy("RabbitMQ is accessible");
                    }
                    catch (Exception ex)
                    {
                        return HealthCheckResult.Unhealthy("RabbitMQ connection failed", ex);
                    }
                });
        }
        else
        {
            // Health checks locais
            var connectionString = configuration.GetConnectionString("DefaultConnection")!;
            var rabbitUsername = configuration["RabbitMQ:Username"] ?? "guest";
            var rabbitPassword = configuration["RabbitMQ:Password"] ?? "guest";
            var rabbitHost = configuration["RabbitMQ:Host"] ?? "localhost";
            var rabbitPort = configuration.GetValue<int>("RabbitMQ:Port", 5672);
            
            healthChecks
                .AddNpgSql(connectionString)
                .AddCheck("rabbitmq", () => 
                {
                    try
                    {
                        var factory = new ConnectionFactory
                        {
                            HostName = rabbitHost,
                            UserName = rabbitUsername,
                            Password = rabbitPassword,
                            Port = rabbitPort
                        };
                        using var connection = factory.CreateConnectionAsync().Result;
                        return HealthCheckResult.Healthy("RabbitMQ is accessible");
                    }
                    catch (Exception ex)
                    {
                        return HealthCheckResult.Unhealthy("RabbitMQ connection failed", ex);
                    }
                });
        }
        
        return services;
    }
}

using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using PropostaService.Infrastructure.Configuration;
using PropostaService.Infrastructure.Data;

namespace PropostaService;

public class PropostaDbContextFactory : IDesignTimeDbContextFactory<PropostaDbContext>
{
    public PropostaDbContext CreateDbContext(string[] args)
    {
        var optionsBuilder = new DbContextOptionsBuilder<PropostaDbContext>();
        
        // Para migrations, sempre usar Docker secrets se disponível, senão usar padrão local
        string connectionString;
        
        if (DockerSecretsReader.IsRunningInContainer())
        {
            // Executando em container - usar secrets
            var host = Environment.GetEnvironmentVariable("Database__Host") ?? "postgres-infra";
            var database = Environment.GetEnvironmentVariable("Database__Name") ?? "propostadb";
            var port = int.Parse(Environment.GetEnvironmentVariable("Database__Port") ?? "5432");
            
            connectionString = DockerSecretsReader.BuildPostgresConnectionString(host, database, port);
        }
        else
        {
            // Executando localmente - usar connection string padrão para development
            connectionString = "Host=localhost;Port=5432;Database=propostadb;Username=postgres;Password=postgres";
        }
        
        optionsBuilder.UseNpgsql(connectionString);
        
        return new PropostaDbContext(optionsBuilder.Options);
    }
}

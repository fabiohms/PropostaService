using System.Text;

namespace PropostaService.Infrastructure.Configuration;

public static class DockerSecretsReader
{
    private const string SecretsPath = "/run/secrets";
    
    public static string? ReadSecret(string secretName)
    {
        try
        {
            var secretPath = Path.Combine(SecretsPath, secretName);
            
            if (!File.Exists(secretPath))
            {
                return null;
            }
            
            return File.ReadAllText(secretPath, Encoding.UTF8).Trim();
        }
        catch (Exception)
        {
            return null;
        }
    }
    
    public static bool IsRunningInContainer()
    {
        return Directory.Exists(SecretsPath);
    }
    
    public static string BuildPostgresConnectionString(string host, string database, int port = 5432)
    {
        var username = ReadSecret("postgres_user");
        var password = ReadSecret("postgres_password");
        
        if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password))
        {
            throw new InvalidOperationException("PostgreSQL secrets not found or empty");
        }
        
        return $"Host={host};Port={port};Database={database};Username={username};Password={password}";
    }
    
    public static (string username, string password) GetRabbitMQCredentials()
    {
        var username = ReadSecret("rabbitmq_user");
        var password = ReadSecret("rabbitmq_password");
        
        if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password))
        {
            throw new InvalidOperationException("RabbitMQ secrets not found or empty");
        }
        
        return (username, password);
    }
}

using Microsoft.EntityFrameworkCore;
using PropostaService.Domain.Ports;
using PropostaService.Infrastructure.Data;
using PropostaService.Infrastructure.Messaging;
using PropostaService.Infrastructure.Extensions;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Database with Docker Secrets support
builder.Services.AddDatabaseWithSecrets(builder.Configuration);

// RabbitMQ with Docker Secrets support
builder.Services.AddRabbitMQWithSecrets(builder.Configuration);

// Services
builder.Services.AddScoped<IPropostaRepository, PropostaRepository>();
builder.Services.AddScoped<IEventPublisher, RabbitMQEventPublisher>();
builder.Services.AddScoped<PropostaService.Application.PropostaService>();

// Health Checks with Docker Secrets support
builder.Services.AddHealthChecksWithSecrets(builder.Configuration);

var app = builder.Build();

// Auto-migrate database on startup (for Docker)
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<PropostaDbContext>();
    try
    {
        context.Database.Migrate();
        app.Logger.LogInformation("Database migrations applied successfully");
    }
    catch (Exception ex)
    {
        app.Logger.LogError(ex, "Error applying database migrations");
    }
}

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}
else
{
    // Habilitar Swagger em produção para demonstração
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "PropostaService API V1");
        c.RoutePrefix = "swagger";
    });
}

// Habilite redireção HTTPS somente quando houver suporte (p.ex. em dev com cert ou quando ASPNETCORE_HTTPS_PORTS estiver definido)
var httpsPorts = Environment.GetEnvironmentVariable("ASPNETCORE_HTTPS_PORTS");
if (app.Environment.IsDevelopment() || !string.IsNullOrEmpty(httpsPorts))
{
    app.UseHttpsRedirection();
}

app.UseAuthorization();
app.MapControllers();

// Health check endpoint
app.MapHealthChecks("/health");

app.Run();

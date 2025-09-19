using Microsoft.EntityFrameworkCore;
using PropostaService.Domain.Entities;

namespace PropostaService.Infrastructure.Data;

public class PropostaDbContext : DbContext
{
    public PropostaDbContext(DbContextOptions<PropostaDbContext> options) : base(options)
    {
    }

    public DbSet<Proposta> Propostas { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Proposta>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Cliente).IsRequired();
            entity.Property(e => e.Valor).HasPrecision(18, 2);
            entity.Property(e => e.Status).HasConversion<string>();
            entity.Property(e => e.Motivo).IsRequired(false).HasMaxLength(500);
            entity.OwnsMany(e => e.Coberturas, cobertura =>
            {
                cobertura.Property(c => c.Nome).IsRequired();
                cobertura.Property(c => c.Valor).HasPrecision(18, 2);
            });
        });
    }
}
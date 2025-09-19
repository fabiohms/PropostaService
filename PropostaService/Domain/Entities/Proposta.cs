using System;
using System.Collections.Generic;

namespace PropostaService.Domain.Entities;

public class Proposta
{
    public Guid Id { get; private set; }
    public string Cliente { get; private set; } = default!;
    public IReadOnlyCollection<Cobertura> Coberturas => _coberturas.AsReadOnly();
    public decimal Valor { get; private set; }
    public StatusProposta Status { get; private set; }
    public string? Motivo { get; private set; }
    public DateTime CreatedAt { get; private set; }

    private readonly List<Cobertura> _coberturas = new();

    // Parameterless constructor for EF Core
    private Proposta()
    {
    }

    public Proposta(string cliente, List<Cobertura> coberturas, decimal valor)
    {
        Id = Guid.NewGuid();
        Cliente = cliente ?? throw new ArgumentNullException(nameof(cliente));
        _coberturas = coberturas ?? throw new ArgumentNullException(nameof(coberturas));
        Valor = valor;
        Status = StatusProposta.EmAnalise;
        CreatedAt = DateTime.UtcNow;
    }

    public void AlterarStatus(StatusProposta novoStatus, string? motivo = null)
    {
        if (Status == StatusProposta.Aprovada || Status == StatusProposta.Rejeitada)
            throw new InvalidOperationException("Não é possível alterar o status de uma proposta já finalizada.");

        if (novoStatus == StatusProposta.Rejeitada && string.IsNullOrWhiteSpace(motivo))
            throw new ArgumentException("Motivo deve ser fornecido ao rejeitar uma proposta.");

        Status = novoStatus;
        Motivo = motivo;
    }
}
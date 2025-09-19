namespace PropostaService.Domain.Entities;

public class Cobertura
{
    public string Nome { get; private set; } = default!;
    public decimal Valor { get; private set; }

    // Parameterless constructor for EF Core
    private Cobertura()
    {
    }

    public Cobertura(string nome, decimal valor)
    {
        Nome = nome ?? throw new ArgumentNullException(nameof(nome));
        Valor = valor;
    }
}
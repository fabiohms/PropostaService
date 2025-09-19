using PropostaService.Domain.Entities;

namespace PropostaService.Domain.Ports;

public interface IPropostaRepository
{
    Task<Proposta> CreateAsync(Proposta proposta);
    Task<Proposta?> GetByIdAsync(Guid id);
    Task<IEnumerable<Proposta>> GetAllAsync();
    Task UpdateAsync(Proposta proposta);
}
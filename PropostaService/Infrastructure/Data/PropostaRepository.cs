using Microsoft.EntityFrameworkCore;
using PropostaService.Domain.Entities;
using PropostaService.Domain.Ports;

namespace PropostaService.Infrastructure.Data;

public class PropostaRepository : IPropostaRepository
{
    private readonly PropostaDbContext _context;

    public PropostaRepository(PropostaDbContext context)
    {
        _context = context;
    }

    public async Task<Proposta> CreateAsync(Proposta proposta)
    {
        await _context.Propostas.AddAsync(proposta);
        await _context.SaveChangesAsync();
        return proposta;
    }

    public async Task<IEnumerable<Proposta>> GetAllAsync()
    {
        return await _context.Propostas.ToListAsync();
    }

    public async Task<Proposta?> GetByIdAsync(Guid id)
    {
        return await _context.Propostas.FindAsync(id);
    }

    public async Task UpdateAsync(Proposta proposta)
    {
        _context.Propostas.Update(proposta);
        await _context.SaveChangesAsync();
    }
}
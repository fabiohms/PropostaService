using PropostaService.Domain.Entities;
using PropostaService.Domain.Events;
using PropostaService.Domain.Ports;

namespace PropostaService.Application;

public class PropostaService
{
    private readonly IPropostaRepository _repository;
    private readonly IEventPublisher _eventPublisher;

    public PropostaService(IPropostaRepository repository, IEventPublisher eventPublisher)
    {
        _repository = repository;
        _eventPublisher = eventPublisher;
    }

    public async Task<Proposta> CriarPropostaAsync(string cliente, List<Cobertura> coberturas, decimal valor)
    {
        var proposta = new Proposta(cliente, coberturas, valor);
        await _repository.CreateAsync(proposta);
        return proposta;
    }

    public async Task<IEnumerable<Proposta>> ListarPropostasAsync()
    {
        return await _repository.GetAllAsync();
    }

    public async Task<Proposta?> ObterPropostaAsync(Guid id)
    {
        return await _repository.GetByIdAsync(id);
    }

    public async Task<Proposta> AlterarStatusAsync(Guid id, StatusProposta novoStatus, string? motivo = null)
    {
        var proposta = await _repository.GetByIdAsync(id) 
            ?? throw new KeyNotFoundException("Proposta não encontrada");

        proposta.AlterarStatus(novoStatus, motivo);

        if (novoStatus == StatusProposta.Aprovada)
        {
            var evento = new PropostaAprovadaEvent(proposta.Id, proposta.Cliente, proposta.Valor);
            await _eventPublisher.PublishAsync(evento);
        } 
        else if (novoStatus == StatusProposta.Rejeitada)
        {
            var evento = new PropostaRejeitadaEvent(proposta.Id, proposta.Cliente, proposta.Valor, motivo!);
            await _eventPublisher.PublishAsync(evento);
        }

        await _repository.UpdateAsync(proposta);
        return proposta;
    }
}
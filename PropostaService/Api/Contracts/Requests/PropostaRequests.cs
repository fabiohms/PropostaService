using PropostaService.Domain.Entities;

namespace PropostaService.Api.Contracts.Requests;

public record CriarPropostaRequest(string Cliente, List<CoberturaRequest> Coberturas, decimal Valor);

public record CoberturaRequest(string Nome, decimal Valor);

public record AlterarStatusRequest(StatusProposta Status, string? Motivo = null);
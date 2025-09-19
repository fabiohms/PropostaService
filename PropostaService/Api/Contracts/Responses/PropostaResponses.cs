using PropostaService.Domain.Entities;

namespace PropostaService.Api.Contracts.Responses;

public record PropostaResponse(
    Guid Id,
    string Cliente,
    List<CoberturaResponse> Coberturas,
    decimal Valor,
    StatusProposta Status,
    string? Motivo,
    DateTime CreatedAt
);

public record CoberturaResponse(string Nome, decimal Valor);

public record ErrorResponse(string Message);
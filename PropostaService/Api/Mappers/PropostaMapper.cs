using PropostaService.Api.Contracts.Requests;
using PropostaService.Api.Contracts.Responses;
using PropostaService.Domain.Entities;

namespace PropostaService.Api.Mappers;

public static class PropostaMapper
{
    public static List<Cobertura> ToEntities(this List<CoberturaRequest> coberturas)
    {
        return coberturas.Select(c => new Cobertura(c.Nome, c.Valor)).ToList();
    }

    public static PropostaResponse ToResponse(this Proposta proposta)
    {
        return new PropostaResponse(
            proposta.Id,
            proposta.Cliente,
            proposta.Coberturas.Select(c => new CoberturaResponse(c.Nome, c.Valor)).ToList(),
            proposta.Valor,
            proposta.Status,
            proposta.Motivo,
            proposta.CreatedAt
        );
    }

    public static List<PropostaResponse> ToResponse(this IEnumerable<Proposta> propostas)
    {
        return propostas.Select(p => p.ToResponse()).ToList();
    }
}
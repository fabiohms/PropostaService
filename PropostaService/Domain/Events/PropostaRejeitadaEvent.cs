namespace PropostaService.Domain.Events;

public record PropostaRejeitadaEvent(Guid PropostaId, string Cliente, decimal Valor, string Motivo);
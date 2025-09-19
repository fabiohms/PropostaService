namespace PropostaService.Domain.Ports;

public interface IEventPublisher
{
    Task PublishAsync<T>(T @event) where T : class;
}
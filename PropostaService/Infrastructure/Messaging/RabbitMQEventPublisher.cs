using RabbitMQ.Client;
using System.Text.Json;
using System.Text;
using PropostaService.Domain.Ports;

namespace PropostaService.Infrastructure.Messaging;

public class RabbitMQEventPublisher : IEventPublisher
{
    private readonly IChannel _channel;

    public RabbitMQEventPublisher(IConnection connection)
    {
        _channel = connection.CreateChannelAsync().Result;
        _channel.ExchangeDeclareAsync("proposta_events", ExchangeType.Topic, durable: true);
    }

    public async Task PublishAsync<T>(T @event) where T : class
    {
        var message = JsonSerializer.Serialize(@event);
        var body = Encoding.UTF8.GetBytes(message);

        await _channel.BasicPublishAsync(
            exchange: "proposta_events",
            routingKey: typeof(T).Name,
            body: body);
    }
}
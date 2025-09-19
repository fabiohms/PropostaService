using Moq;
using PropostaService.Domain.Entities;
using PropostaService.Domain.Events;
using PropostaService.Domain.Ports;
using Xunit;

namespace PropostaService.Tests;

public class PropostaServiceTests
{
    [Fact]
    public async Task CriarProposta_SavesAndReturnsProposta()
    {
        // Arrange
        var repoMock = new Mock<IPropostaRepository>();
        var publisherMock = new Mock<IEventPublisher>();

        repoMock.Setup(r => r.CreateAsync(It.IsAny<Proposta>()))
            .ReturnsAsync((Proposta p) => p);

        var service = new Application.PropostaService(repoMock.Object, publisherMock.Object);

        var coberturas = new List<Cobertura> { new Cobertura("A", 100) };

        // Act
        var result = await service.CriarPropostaAsync("Cliente 1", coberturas, 1000);

        // Assert
        Assert.NotNull(result);
        Assert.Equal("Cliente 1", result.Cliente);
        repoMock.Verify(r => r.CreateAsync(It.IsAny<Proposta>()), Times.Once);
    }

    [Fact]
    public async Task AlterarStatusAsync_Aprovar_PublishesEvent()
    {
        // Arrange
        var repoMock = new Mock<IPropostaRepository>();
        var publisherMock = new Mock<IEventPublisher>();

        var proposta = new Proposta("Cliente 1", new List<Cobertura>{ new Cobertura("A", 100) }, 1000);
        repoMock.Setup(r => r.GetByIdAsync(proposta.Id)).ReturnsAsync(proposta);
        repoMock.Setup(r => r.UpdateAsync(It.IsAny<Proposta>())).Returns(Task.CompletedTask);

        var service = new Application.PropostaService(repoMock.Object, publisherMock.Object);

        // Act
        var updated = await service.AlterarStatusAsync(proposta.Id, StatusProposta.Aprovada);

        // Assert
        Assert.Equal(StatusProposta.Aprovada, updated.Status);
        publisherMock.Verify(p => p.PublishAsync(It.IsAny<PropostaAprovadaEvent>()), Times.Once);
    }

    [Fact]
    public async Task AlterarStatusAsync_Rejeitar_ComMotivo_PublishesEvent()
    {
        // Arrange
        var repoMock = new Mock<IPropostaRepository>();
        var publisherMock = new Mock<IEventPublisher>();

        var proposta = new Proposta("Cliente 2", new List<Cobertura>{ new Cobertura("B", 200) }, 2000);
        repoMock.Setup(r => r.GetByIdAsync(proposta.Id)).ReturnsAsync(proposta);
        repoMock.Setup(r => r.UpdateAsync(It.IsAny<Proposta>())).Returns(Task.CompletedTask);

        var service = new Application.PropostaService(repoMock.Object, publisherMock.Object);

        // Act
        var updated = await service.AlterarStatusAsync(proposta.Id, StatusProposta.Rejeitada, "Motivo X");

        // Assert
        Assert.Equal(StatusProposta.Rejeitada, updated.Status);
        Assert.Equal("Motivo X", updated.Motivo);
        publisherMock.Verify(p => p.PublishAsync(It.IsAny<object>()), Times.Once);
    }

    [Fact]
    public async Task AlterarStatusAsync_Rejeitar_SemMotivo_ThrowsArgumentException()
    {
        // Arrange
        var repoMock = new Mock<IPropostaRepository>();
        var publisherMock = new Mock<IEventPublisher>();

        var proposta = new Proposta("Cliente 3", new List<Cobertura>{ new Cobertura("C", 300) }, 3000);
        repoMock.Setup(r => r.GetByIdAsync(proposta.Id)).ReturnsAsync(proposta);

        var service = new Application.PropostaService(repoMock.Object, publisherMock.Object);

        // Act & Assert
        await Assert.ThrowsAsync<ArgumentException>(async () =>
            await service.AlterarStatusAsync(proposta.Id, StatusProposta.Rejeitada));
    }

    [Theory]
    [InlineData((int)StatusProposta.Rejeitada, (int)StatusProposta.Aprovada, "Motivo existente")]
    [InlineData((int)StatusProposta.Aprovada, (int)StatusProposta.Rejeitada, null)]
    public async Task AlterarStatusAsync_WhenAlreadyFinalized_ThrowsInvalidOperationException(int initialStatusInt, int attemptedStatusInt, string? initialMotivo)
    {
        // Arrange
        var repoMock = new Mock<IPropostaRepository>();
        var publisherMock = new Mock<IEventPublisher>();

        var proposta = new Proposta("Cliente 4", new List<Cobertura>{ new Cobertura("D", 400) }, 4000);

        var initialStatus = (StatusProposta)initialStatusInt;
        var attemptedStatus = (StatusProposta)attemptedStatusInt;

        // Set initial finalized status on the aggregate
        if (initialStatus == StatusProposta.Rejeitada)
        {
            proposta.AlterarStatus(StatusProposta.Rejeitada, initialMotivo ?? "motivo");
        }
        else
        {
            proposta.AlterarStatus(StatusProposta.Aprovada);
        }

        repoMock.Setup(r => r.GetByIdAsync(proposta.Id)).ReturnsAsync(proposta);

        var service = new Application.PropostaService(repoMock.Object, publisherMock.Object);

        // Act & Assert: attempting any status change should throw InvalidOperationException
        await Assert.ThrowsAsync<InvalidOperationException>(async () =>
            await service.AlterarStatusAsync(proposta.Id, attemptedStatus));
    }
}
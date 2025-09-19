using Microsoft.AspNetCore.Mvc;
using PropostaService.Api.Contracts.Requests;
using PropostaService.Api.Contracts.Responses;
using PropostaService.Api.Mappers;

namespace PropostaService.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class PropostasController : ControllerBase
{
    private readonly Application.PropostaService _propostaService;

    public PropostasController(Application.PropostaService propostaService)
    {
        _propostaService = propostaService;
    }

    [HttpPost]
    public async Task<ActionResult<PropostaResponse>> Create([FromBody] CriarPropostaRequest request)
    {
        var proposta = await _propostaService.CriarPropostaAsync(
            request.Cliente,
            request.Coberturas.ToEntities(),
            request.Valor
        );
        
        var response = proposta.ToResponse();
        return CreatedAtAction(nameof(GetById), new { id = proposta.Id }, response);
    }

    [HttpGet]
    public async Task<ActionResult<List<PropostaResponse>>> GetAll()
    {
        var propostas = await _propostaService.ListarPropostasAsync();
        var response = propostas.ToResponse();
        return Ok(response);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<PropostaResponse>> GetById(Guid id)
    {
        var proposta = await _propostaService.ObterPropostaAsync(id);
        if (proposta == null)
            return NotFound();

        var response = proposta.ToResponse();
        return Ok(response);
    }

    [HttpPatch("{id}/status")]
    public async Task<ActionResult<PropostaResponse>> UpdateStatus(Guid id, [FromBody] AlterarStatusRequest request)
    {
        try
        {
            var proposta = await _propostaService.AlterarStatusAsync(id, request.Status, request.Motivo);
            var response = proposta.ToResponse();
            return Ok(response);
        }
        catch (KeyNotFoundException)
        {
            return NotFound();
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new ErrorResponse(ex.Message));
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new ErrorResponse(ex.Message));
        }
    }
}
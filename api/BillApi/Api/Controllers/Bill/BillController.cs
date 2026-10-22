using BillApi.Application.Services;
using Microsoft.AspNetCore.Mvc;

namespace BillApi.Api.Controllers.Bill
{
    [Route("api/bill")]
    [ApiController]
    public class BillController(IBillService billService, IBillReminderService reminderService) : ControllerBase
    {
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            return Ok(await billService.GetAll());
        }

        [HttpGet("client/{clientId}")]
        public async Task<IActionResult> GetByClientId(string clientId)
        {
            return Ok(await billService.GetByClientId(clientId));
        }

        // Envía el recordatorio y avanza el estado de las facturas de todos los clientes.
        [HttpPost("status")]
        public async Task<IActionResult> UpdateStatusAllClients()
        {
            return Ok(await reminderService.ProcessAllClients());
        }

        [HttpPost("status/{clientId}")]
        public async Task<IActionResult> UpdateStatus(string clientId)
        {
            var result = await reminderService.ProcessClient(clientId);
            if (result is null)
            {
                return NotFound(new { message = $"Client {clientId} not found." });
            }
            return Ok(result);
        }
    }
}

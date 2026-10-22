using BillApi.Application.Services;
using Microsoft.AspNetCore.Mvc;

namespace BillApi.Api.Controllers.Client
{
    [Route("api/client")]
    [ApiController]
    public class ClientController(IClientService clientService) : ControllerBase
    {
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            return Ok(await clientService.GetAll());
        }
    }
}

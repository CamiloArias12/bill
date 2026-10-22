using BillApi.Api.Controllers.Client;
using BillApi.Application.Services;
using BillApi.Domain.Entities;
using Microsoft.AspNetCore.Mvc;
using Moq;

namespace BillApi.Tests.V1.Controllers
{
    public class ClientControllerTests
    {
        private readonly Mock<IClientService> _mockClientService;
        private readonly ClientController _clientController;

        public ClientControllerTests()
        {
            _mockClientService = new Mock<IClientService>();
            _clientController = new ClientController(_mockClientService.Object);
        }

        [Fact]
        public async Task GetAll_ReturnsOkResult_WhenClientsExist()
        {
            _mockClientService.Setup(service => service.GetAll()).ReturnsAsync(new List<Client>()); // Retorna una lista vacía

            var result = await _clientController.GetAll();

            var okResult = Assert.IsType<OkObjectResult>(result);

            Assert.IsAssignableFrom<List<Client>>(okResult.Value);
        }

       
    }
}
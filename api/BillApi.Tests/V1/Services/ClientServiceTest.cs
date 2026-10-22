using BillApi.Domain.Entities;
using BillApi.Persistence.Repositories;
using BillApi.Application.Services;
using Moq;

namespace BillApi.Tests.V1.Services
{
    public class ClientServiceTests
    {
        private readonly Mock<IClientRepository> _mockClientRepository;
        private readonly ClientService _clientService;

        public ClientServiceTests()
        {
            _mockClientRepository = new Mock<IClientRepository>();
            _clientService = new ClientService(_mockClientRepository.Object);
        }

        [Fact]
        public async Task GetAll_ReturnsListOfClients_WhenClientsExist()
        {
            // Arrange
            var clients = new List<Client> {
                new() { Name = "Prueba desarrollo 1",Nit="111.111.111-1", Email = "ariaspira13@gmail.com" },
                new() { Name = "Prueba desarrollo 2",Nit="222.222.222-2", Email = "ariaspira13@gmail.com" },
                new() { Name = "Prueba desarrollo 3",Nit="333.333.333-3", Email = "ariaspira13@gmail.com" },
                new() { Name = "Prueba desarrollo 4",Nit="444.444.444-4", Email = "ariaspira13@gmail.com" },
                new() { Name = "Prueba desarrollo 5",Nit="555.555.555-5" ,Email = "ariaspira13@gmail.com" }
             };
            _mockClientRepository.Setup(repo => repo.GetAll()).ReturnsAsync(clients);

            // Act
            var result = await _clientService.GetAll();

            // Assert
            Assert.NotNull(result);
            Assert.IsType<List<Client>>(result);
            Assert.NotEmpty(result);
        }

    }

}
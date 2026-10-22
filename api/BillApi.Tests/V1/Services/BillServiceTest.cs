using BillApi.Application.Services;
using BillApi.Domain.Entities;
using BillApi.Persistence.Repositories;
using Moq;

namespace BillApi.Tests.V1.Services
{
    public class BillServiceTests
    {
        private readonly Mock<IBillRepository> _mockBillRepository = new();
        private readonly BillService _billService;

        public BillServiceTests()
        {
            _billService = new BillService(_mockBillRepository.Object);
        }

        [Fact]
        public async Task GetAll_ReturnsListOfBills_WhenBillsExist()
        {
            _mockBillRepository.Setup(r => r.GetAll()).ReturnsAsync(new List<Bill> { new() { BillCode = "P-00001" } });

            var result = await _billService.GetAll();

            Assert.Single(result);
        }

        [Fact]
        public async Task GetAll_ReturnsEmptyList_WhenNoBillsExist()
        {
            _mockBillRepository.Setup(r => r.GetAll()).ReturnsAsync(new List<Bill>());

            var result = await _billService.GetAll();

            Assert.Empty(result);
        }

        [Fact]
        public async Task GetByClientId_ReturnsBillsOfClient()
        {
            var bills = new List<Bill> { new() { BillCode = "P-00001", ClientId = "c1" } };
            _mockBillRepository.Setup(r => r.FindByClientId("c1")).ReturnsAsync(bills);

            var result = await _billService.GetByClientId("c1");

            Assert.Same(bills, result);
        }
    }
}

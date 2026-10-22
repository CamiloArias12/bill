using BillApi.Api.Controllers.Bill;
using BillApi.Application.Common.Dto;
using BillApi.Application.Services;
using BillApi.Domain.Entities;
using Microsoft.AspNetCore.Mvc;
using Moq;

namespace BillApi.Tests.V1.Controllers
{
    public class BillControllerTests
    {
        private readonly Mock<IBillService> _mockBillService = new();
        private readonly Mock<IBillReminderService> _mockReminderService = new();
        private readonly BillController _billController;

        public BillControllerTests()
        {
            _billController = new BillController(_mockBillService.Object, _mockReminderService.Object);
        }

        [Fact]
        public async Task GetAll_ReturnsOkResult_WithBills()
        {
            _mockBillService.Setup(s => s.GetAll()).ReturnsAsync(new List<Bill>());

            var result = await _billController.GetAll();

            var okResult = Assert.IsType<OkObjectResult>(result);
            Assert.IsAssignableFrom<List<Bill>>(okResult.Value);
        }

        [Fact]
        public async Task UpdateStatus_ReturnsOkResult_WhenClientExists()
        {
            var reminderResult = new ReminderResultDto { ClientId = "c1", ClientName = "Cliente 1" };
            _mockReminderService.Setup(s => s.ProcessClient("c1")).ReturnsAsync(reminderResult);

            var result = await _billController.UpdateStatus("c1");

            var okResult = Assert.IsType<OkObjectResult>(result);
            Assert.Same(reminderResult, okResult.Value);
        }

        [Fact]
        public async Task UpdateStatus_ReturnsNotFound_WhenClientDoesNotExist()
        {
            _mockReminderService.Setup(s => s.ProcessClient("missing")).ReturnsAsync((ReminderResultDto?)null);

            var result = await _billController.UpdateStatus("missing");

            Assert.IsType<NotFoundObjectResult>(result);
        }

        [Fact]
        public async Task UpdateStatusAllClients_ReturnsOkResult_WithResults()
        {
            _mockReminderService.Setup(s => s.ProcessAllClients()).ReturnsAsync(new List<ReminderResultDto>());

            var result = await _billController.UpdateStatusAllClients();

            Assert.IsType<OkObjectResult>(result);
        }
    }
}

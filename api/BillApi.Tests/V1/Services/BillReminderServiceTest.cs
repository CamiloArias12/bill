using BillApi.Application.Common.Dto;
using BillApi.Application.Interfaces;
using BillApi.Application.Services;
using BillApi.Domain.Entities;
using BillApi.Domain.Enums;
using BillApi.Persistence.Repositories;
using Microsoft.Extensions.Logging.Abstractions;
using Moq;

namespace BillApi.Tests.V1.Services
{
    public class BillReminderServiceTests
    {
        private readonly Mock<IBillRepository> _mockBillRepository = new();
        private readonly Mock<IClientRepository> _mockClientRepository = new();
        private readonly Mock<IEmailService> _mockEmailService = new();
        private readonly BillReminderService _service;

        private static readonly Client _client = new() { Id = "c1", Name = "Cliente 1", Nit = "1", Email = "c1@test.com" };

        public BillReminderServiceTests()
        {
            _mockClientRepository.Setup(r => r.GetById("c1")).ReturnsAsync(_client);
            _mockEmailService.Setup(e => e.SendEmail(It.IsAny<EmailMessageDto>())).ReturnsAsync(true);

            _service = new BillReminderService(
                _mockBillRepository.Object,
                _mockClientRepository.Object,
                _mockEmailService.Object,
                new ReminderEmailBuilder(),
                NullLogger<BillReminderService>.Instance);
        }

        private void GivenBills(params Bill[] bills)
        {
            _mockBillRepository.Setup(r => r.FindByClientId("c1")).ReturnsAsync(bills.ToList());
        }

        [Fact]
        public async Task ProcessClient_ReturnsNull_WhenClientDoesNotExist()
        {
            var result = await _service.ProcessClient("missing");

            Assert.Null(result);
            _mockEmailService.Verify(e => e.SendEmail(It.IsAny<EmailMessageDto>()), Times.Never);
        }

        [Fact]
        public async Task ProcessClient_MovesFirstReminderToSecondReminder()
        {
            GivenBills(new Bill { Id = "b1", BillCode = "P-1", Status = "primerrecordatorio" });

            var result = await _service.ProcessClient("c1");

            _mockBillRepository.Verify(r => r.UpdateStatus("b1", BillStatus.SecondReminder.ToValue()), Times.Once);
            var transition = Assert.Single(result!.Updated);
            Assert.Equal("segundorecordatorio", transition.NewStatus);
        }

        [Fact]
        public async Task ProcessClient_MovesSecondReminderToDisabled()
        {
            GivenBills(new Bill { Id = "b1", BillCode = "P-1", Status = "segundoRecordatorio" });

            await _service.ProcessClient("c1");

            _mockBillRepository.Verify(r => r.UpdateStatus("b1", BillStatus.Disabled.ToValue()), Times.Once);
        }

        [Fact]
        public async Task ProcessClient_SendsEmailToClientWithMessageForNewStatus()
        {
            GivenBills(
                new Bill { Id = "b1", BillCode = "P-1", Status = "primerrecordatorio" },
                new Bill { Id = "b2", BillCode = "P-2", Status = "segundorecordatorio" });

            await _service.ProcessClient("c1");

            _mockEmailService.Verify(e => e.SendEmail(It.Is<EmailMessageDto>(m =>
                m.To == "c1@test.com" && m.Body.Contains("P-1") && m.Body.Contains("segundo recordatorio"))), Times.Once);
            _mockEmailService.Verify(e => e.SendEmail(It.Is<EmailMessageDto>(m =>
                m.To == "c1@test.com" && m.Body.Contains("P-2") && m.Body.Contains("desactivada"))), Times.Once);
        }

        [Theory]
        [InlineData("desactivado")]
        [InlineData("pagada")]
        [InlineData(null)]
        public async Task ProcessClient_IgnoresBillsWithoutReminderStatus(string? status)
        {
            GivenBills(new Bill { Id = "b1", BillCode = "P-1", Status = status });

            var result = await _service.ProcessClient("c1");

            Assert.Empty(result!.Updated);
            _mockEmailService.Verify(e => e.SendEmail(It.IsAny<EmailMessageDto>()), Times.Never);
            _mockBillRepository.Verify(r => r.UpdateStatus(It.IsAny<string>(), It.IsAny<string>()), Times.Never);
        }

        [Fact]
        public async Task ProcessClient_DoesNotUpdateStatus_WhenEmailFails()
        {
            GivenBills(
                new Bill { Id = "b1", BillCode = "P-1", Status = "primerrecordatorio" },
                new Bill { Id = "b2", BillCode = "P-2", Status = "primerrecordatorio" });
            _mockEmailService.Setup(e => e.SendEmail(It.Is<EmailMessageDto>(m => m.Body.Contains("P-1")))).ReturnsAsync(false);

            var result = await _service.ProcessClient("c1");

            Assert.Equal(["P-1"], result!.FailedBillCodes);
            _mockBillRepository.Verify(r => r.UpdateStatus("b1", It.IsAny<string>()), Times.Never);
            _mockBillRepository.Verify(r => r.UpdateStatus("b2", "segundorecordatorio"), Times.Once);
        }

        [Fact]
        public async Task ProcessAllClients_ProcessesEveryClient()
        {
            var clients = new List<Client>
            {
                _client,
                new() { Id = "c2", Name = "Cliente 2", Nit = "2", Email = "c2@test.com" },
                new() { Id = "c3", Name = "Cliente 3", Nit = "3", Email = "c3@test.com" }
            };
            _mockClientRepository.Setup(r => r.GetAll()).ReturnsAsync(clients);
            _mockBillRepository.Setup(r => r.FindByClientId(It.IsAny<string>()))
                .ReturnsAsync((string id) => [new Bill { Id = $"b-{id}", BillCode = $"P-{id}", Status = "primerrecordatorio" }]);

            var results = await _service.ProcessAllClients();

            Assert.Equal(3, results.Count);
            Assert.All(results, r => Assert.Single(r.Updated));
            _mockEmailService.Verify(e => e.SendEmail(It.IsAny<EmailMessageDto>()), Times.Exactly(3));
        }
    }
}

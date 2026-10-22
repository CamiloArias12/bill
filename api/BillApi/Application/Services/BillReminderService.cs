using BillApi.Application.Common.Dto;
using BillApi.Application.Interfaces;
using BillApi.Domain.Entities;
using BillApi.Domain.Enums;
using BillApi.Persistence.Repositories;

namespace BillApi.Application.Services
{
    public class BillReminderService(
        IBillRepository billRepository,
        IClientRepository clientRepository,
        IEmailService emailService,
        IReminderEmailBuilder emailBuilder,
        ILogger<BillReminderService> logger) : IBillReminderService
    {
        public async Task<ReminderResultDto?> ProcessClient(string clientId)
        {
            var client = await clientRepository.GetById(clientId);
            return client is null ? null : await Process(client);
        }

        public async Task<List<ReminderResultDto>> ProcessAllClients()
        {
            var results = new List<ReminderResultDto>();
            foreach (var client in await clientRepository.GetAll())
            {
                results.Add(await Process(client));
            }
            return results;
        }

        private async Task<ReminderResultDto> Process(Client client)
        {
            var result = new ReminderResultDto { ClientId = client.Id!, ClientName = client.Name };
            var bills = await billRepository.FindByClientId(client.Id!);

            foreach (var bill in bills)
            {
                if (!BillStatusExtensions.TryParse(bill.Status, out var current) || current.NextReminderStatus() is not { } next)
                {
                    continue;
                }

                // El estado solo se actualiza si el correo se envió, para no cambiarlo sin notificar al cliente.
                var sent = await emailService.SendEmail(emailBuilder.Build(client, bill, next));
                if (!sent)
                {
                    logger.LogWarning("No se pudo notificar la factura {BillCode} del cliente {ClientId}", bill.BillCode, client.Id);
                    result.FailedBillCodes.Add(bill.BillCode);
                    continue;
                }

                await billRepository.UpdateStatus(bill.Id!, next.ToValue());
                result.Updated.Add(new BillTransitionDto(bill.BillCode, current.ToValue(), next.ToValue()));
            }

            return result;
        }
    }
}

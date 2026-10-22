using BillApi.Application.Common.Dto;
using BillApi.Application.Interfaces;
using BillApi.Domain.Entities;
using BillApi.Domain.Enums;

namespace BillApi.Application.Services
{
    public class ReminderEmailBuilder : IReminderEmailBuilder
    {
        public EmailMessageDto Build(Client client, Bill bill, BillStatus newStatus)
        {
            var message = newStatus switch
            {
                BillStatus.SecondReminder =>
                    $"Su factura <b>{bill.BillCode}</b> ha pasado a <b>segundo recordatorio</b>. Le invitamos a realizar el pago lo antes posible.",
                BillStatus.Disabled =>
                    $"Su factura <b>{bill.BillCode}</b> se encontraba en segundo recordatorio y <b>va a ser desactivada</b>.",
                _ => throw new ArgumentOutOfRangeException(nameof(newStatus), newStatus, "Estado sin notificación asociada.")
            };

            return new EmailMessageDto
            {
                To = client.Email,
                Subject = $"Factura {bill.BillCode}: {newStatus.ToValue()}",
                Body = $"<h1>Hola, {client.Name}</h1><p>{message}</p>"
            };
        }
    }
}

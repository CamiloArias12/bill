using BillApi.Application.Common.Dto;
using BillApi.Domain.Entities;
using BillApi.Domain.Enums;

namespace BillApi.Application.Interfaces
{
    public interface IReminderEmailBuilder
    {
        EmailMessageDto Build(Client client, Bill bill, BillStatus newStatus);
    }
}

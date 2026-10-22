using BillApi.Application.Common.Dto;

namespace BillApi.Application.Services
{
    public interface IBillReminderService
    {
        // Retorna null si el cliente no existe.
        Task<ReminderResultDto?> ProcessClient(string clientId);
        Task<List<ReminderResultDto>> ProcessAllClients();
    }
}

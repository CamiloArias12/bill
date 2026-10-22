using BillApi.Domain.Entities;

namespace BillApi.Application.Services
{
    public interface IBillService : IService<Bill>
    {
        Task<List<Bill>> GetByClientId(string clientId);
    }
}

using BillApi.Domain.Entities;

namespace BillApi.Persistence.Repositories
{
    public interface IBillRepository : IRepository<Bill>
    {
        Task<List<Bill>> FindByClientId(string clientId);
        Task UpdateStatus(string id, string status);
    }
}

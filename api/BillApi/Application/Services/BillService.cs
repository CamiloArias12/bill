using BillApi.Domain.Entities;
using BillApi.Persistence.Repositories;

namespace BillApi.Application.Services
{
    public class BillService(IBillRepository billRepository) : Service<Bill>(billRepository), IBillService
    {
        private readonly IBillRepository _billRepository = billRepository;

        public async Task<List<Bill>> GetByClientId(string clientId)
        {
            return await _billRepository.FindByClientId(clientId);
        }
    }
}

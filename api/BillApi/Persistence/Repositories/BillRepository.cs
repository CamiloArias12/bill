using BillApi.Domain.Entities;
using MongoDB.Driver;
namespace BillApi.Persistence.Repositories
{
    public class BillRepository(IMongoDatabase database) : Repository<Bill>(database, "Bills"), IBillRepository
    {
        public async Task<List<Bill>> FindByClientId(string clientId)
        {
            return await _collection.Find(b => b.ClientId == clientId).ToListAsync();
        }

        public async Task UpdateStatus(string id, string status)
        {
            var update = Builders<Bill>.Update.Set(b => b.Status, status);
            await _collection.UpdateOneAsync(b => b.Id == id, update);
        }
    }
}

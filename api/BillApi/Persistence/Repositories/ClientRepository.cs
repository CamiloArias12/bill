using BillApi.Domain.Entities;
using MongoDB.Driver;
namespace BillApi.Persistence.Repositories
{
    public class ClientRepository(IMongoDatabase database) : Repository<Client>(database, "Clients"), IClientRepository
    {

    }
}

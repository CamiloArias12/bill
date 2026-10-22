using BillApi.Domain.Entities;
using BillApi.Persistence.Repositories;

namespace BillApi.Application.Services
{
    public class ClientService(IClientRepository clientRepository) : Service<Client>(clientRepository), IClientService
    {

    }
}

using BillApi.Domain.Entities;
using BillApi.Domain.Enums;
using BillApi.Persistence.Repositories;

namespace BillApi.Persistence.Seed
{
    // Crea 3 clientes con facturas en cada estado para poder probar el flujo de recordatorios.
    public class DatabaseSeeder(IClientRepository clientRepository, IBillRepository billRepository)
    {
        private static readonly string[] _cities = ["Bogota", "Medellin", "Cali"];

        public async Task Seed()
        {
            if ((await clientRepository.GetAll()).Any())
            {
                return;
            }

            var clients = new List<Client>
            {
                new() { Name = "Prueba desarrollo 1", Nit = "111.111.111-1", Email = "ariaspira13@gmail.com" },
                new() { Name = "Prueba desarrollo 2", Nit = "222.222.222-2", Email = "ariaspira13@gmail.com" },
                new() { Name = "Prueba desarrollo 3", Nit = "333.333.333-3", Email = "ariaspira13@gmail.com" }
            };

            var billNumber = 1;
            for (var i = 0; i < clients.Count; i++)
            {
                var client = clients[i];
                await clientRepository.Create(client);

                foreach (var status in new[] { BillStatus.FirstReminder, BillStatus.SecondReminder, BillStatus.FirstReminder })
                {
                    var subtotal = 10000 * billNumber;
                    var vat = subtotal * 0.19;
                    var withholding = subtotal * 0.025;
                    await billRepository.Create(new Bill
                    {
                        ClientId = client.Id,
                        BillCode = $"P-{billNumber:D5}",
                        Subtotal = subtotal,
                        VAT = vat,
                        Withholding = withholding,
                        BillTotal = subtotal + vat - withholding,
                        CreationDate = DateTime.UtcNow.AddDays(-billNumber * 3),
                        Status = status.ToValue(),
                        City = _cities[i],
                        IsPaid = false
                    });
                    billNumber++;
                }
            }
        }
    }
}

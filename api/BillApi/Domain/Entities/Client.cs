using BillApi.Domain.Common;
using System.ComponentModel.DataAnnotations;

namespace BillApi.Domain.Entities
{
    public class Client : BaseEntity
    {
        public required string Name { get; set; }

        public required string Nit { get; set; }
        [EmailAddress]
        public required string Email { get; set; }

    }
}

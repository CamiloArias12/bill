using BillApi.Domain.Common;

namespace BillApi.Domain.Entities
{
    public class Bill : BaseEntity
    {
        public required string BillCode { get; set; }

        public double? BillTotal { get; set; }

        public double? Subtotal { get; set; }

        public double? VAT { get; set; }

        public double? Withholding { get; set; }

        public DateTime CreationDate { get; set; }

        public string? Status { get; set; }

        public string? City { get; set; }

        public bool? IsPaid { get; set; }

        public DateTime? PaymentDate { get; set; }

        public string? ClientId { get; set; }

    }
}

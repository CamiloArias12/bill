namespace BillApi.Domain.Enums
{
    public enum BillStatus
    {
        FirstReminder,
        SecondReminder,
        Disabled
    }

    public static class BillStatusExtensions
    {
        private static readonly Dictionary<BillStatus, string> _values = new()
        {
            { BillStatus.FirstReminder, "primerrecordatorio" },
            { BillStatus.SecondReminder, "segundorecordatorio" },
            { BillStatus.Disabled, "desactivado" }
        };

        public static string ToValue(this BillStatus status)
        {
            return _values[status];
        }

        // Comparación sin distinguir mayúsculas: la base puede tener "primerRecordatorio" o "primerrecordatorio".
        public static bool TryParse(string? value, out BillStatus status)
        {
            foreach (var pair in _values)
            {
                if (string.Equals(pair.Value, value?.Trim(), StringComparison.OrdinalIgnoreCase))
                {
                    status = pair.Key;
                    return true;
                }
            }

            status = default;
            return false;
        }

        // primerrecordatorio -> segundorecordatorio -> desactivado. Un estado desactivado no avanza.
        public static BillStatus? NextReminderStatus(this BillStatus status)
        {
            return status switch
            {
                BillStatus.FirstReminder => BillStatus.SecondReminder,
                BillStatus.SecondReminder => BillStatus.Disabled,
                _ => null
            };
        }
    }
}

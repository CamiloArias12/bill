using BillApi.Domain.Enums;

namespace BillApi.Tests.V1.Domain
{
    public class BillStatusTests
    {
        [Theory]
        [InlineData("primerrecordatorio", BillStatus.FirstReminder)]
        [InlineData("primerRecordatorio", BillStatus.FirstReminder)]
        [InlineData(" SEGUNDORECORDATORIO ", BillStatus.SecondReminder)]
        [InlineData("desactivado", BillStatus.Disabled)]
        public void TryParse_ReturnsStatus_IgnoringCase(string value, BillStatus expected)
        {
            Assert.True(BillStatusExtensions.TryParse(value, out var status));
            Assert.Equal(expected, status);
        }

        [Theory]
        [InlineData(null)]
        [InlineData("")]
        [InlineData("pagada")]
        public void TryParse_ReturnsFalse_WhenValueIsUnknown(string? value)
        {
            Assert.False(BillStatusExtensions.TryParse(value, out _));
        }

        [Theory]
        [InlineData(BillStatus.FirstReminder, BillStatus.SecondReminder)]
        [InlineData(BillStatus.SecondReminder, BillStatus.Disabled)]
        public void NextReminderStatus_AdvancesStatus(BillStatus current, BillStatus expected)
        {
            Assert.Equal(expected, current.NextReminderStatus());
        }

        [Fact]
        public void NextReminderStatus_ReturnsNull_WhenDisabled()
        {
            Assert.Null(BillStatus.Disabled.NextReminderStatus());
        }
    }
}

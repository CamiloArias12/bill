namespace BillApi.Application.Common.Dto
{
    public record BillTransitionDto(string BillCode, string PreviousStatus, string NewStatus);

    public class ReminderResultDto
    {
        public required string ClientId { get; init; }
        public required string ClientName { get; init; }
        public List<BillTransitionDto> Updated { get; } = [];
        public List<string> FailedBillCodes { get; } = [];
    }
}

using BillApi.Application.Common.Dto;

namespace BillApi.Application.Interfaces
{
    public interface IEmailService
    {
        Task<bool> SendEmail(EmailMessageDto message);
    }
}

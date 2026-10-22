using BillApi.Application.Common.Dto;
using BillApi.Application.Interfaces;
using MailKit.Net.Smtp;
using Microsoft.Extensions.Options;
using MimeKit;
using MimeKit.Text;

namespace BillApi.Infrastructure.Email
{
    public class EmailService(IOptions<SmtpConfig> options, ILogger<EmailService> logger) : IEmailService
    {
        private readonly SmtpConfig _config = options.Value;

        public async Task<bool> SendEmail(EmailMessageDto message)
        {
            var email = new MimeMessage();
            email.From.Add(MailboxAddress.Parse(_config.Username));
            email.To.Add(MailboxAddress.Parse(message.To));
            email.Subject = message.Subject;
            email.Body = new TextPart(TextFormat.Html) { Text = message.Body };

            try
            {
                using var smtp = new SmtpClient();
                await smtp.ConnectAsync(_config.Host, _config.Port);
                await smtp.AuthenticateAsync(_config.Username, _config.Password);
                await smtp.SendAsync(email);
                await smtp.DisconnectAsync(true);
                return true;
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "Error enviando correo a {To}", message.To);
                return false;
            }
        }
    }
}

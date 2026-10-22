using BillApi.Application.Interfaces;
using BillApi.Application.Services;
using BillApi.Infrastructure.Email;
using BillApi.Persistence.Config;
using BillApi.Persistence.Repositories;
using BillApi.Persistence.Seed;
using Microsoft.Extensions.Options;
using MongoDB.Driver;

namespace BillApi.Extensions
{
    // Registro de dependencias agrupado por capa, para que Program.cs solo componga la aplicación.
    public static class DependencyInjection
    {
        public static IServiceCollection AddPersistence(this IServiceCollection services, IConfiguration configuration)
        {
            services.Configure<MongoSettings>(configuration.GetSection("MongoSettings"));

            services.AddSingleton<IMongoClient>(sp =>
            {
                var settings = sp.GetRequiredService<IOptions<MongoSettings>>().Value;
                return new MongoClient(settings.ConnectionString);
            });

            services.AddSingleton(sp =>
            {
                var settings = sp.GetRequiredService<IOptions<MongoSettings>>().Value;
                return sp.GetRequiredService<IMongoClient>().GetDatabase(settings.Database);
            });

            services.AddScoped<IBillRepository, BillRepository>();
            services.AddScoped<IClientRepository, ClientRepository>();
            services.AddTransient<DatabaseSeeder>();

            return services;
        }

        public static IServiceCollection AddInfrastructure(this IServiceCollection services, IConfiguration configuration)
        {
            services.Configure<SmtpConfig>(configuration.GetSection("EmailConfiguration"));
            services.AddTransient<IEmailService, EmailService>();

            return services;
        }

        public static IServiceCollection AddApplication(this IServiceCollection services)
        {
            services.AddScoped<IBillService, BillService>();
            services.AddScoped<IClientService, ClientService>();
            services.AddScoped<IBillReminderService, BillReminderService>();
            services.AddSingleton<IReminderEmailBuilder, ReminderEmailBuilder>();

            return services;
        }
    }
}

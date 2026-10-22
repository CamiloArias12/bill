
namespace BillApi.Application.Services
{
    public interface IService<T> where T : class
    {
        Task<T> GetById(string id);
        Task<IEnumerable<T>> GetAll();
        Task Create(T entity);
        Task Update(string id, T entity);
        Task Delete(string id);
    }
}


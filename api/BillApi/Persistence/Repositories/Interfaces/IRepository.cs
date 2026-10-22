namespace BillApi.Persistence.Repositories
{
    public interface IRepository<T>
    {
        Task<T> GetById(string id);
        Task<IEnumerable<T>> GetAll();
        Task Create(T entity);
        Task Update(string id, T entity);
        Task Delete(string id);
    }
}


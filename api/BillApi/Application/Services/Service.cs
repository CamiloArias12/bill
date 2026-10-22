using BillApi.Persistence.Repositories;

namespace BillApi.Application.Services
{
    public class Service<T>(IRepository<T> repository) : IService<T> where T : class
    {
        protected readonly IRepository<T> _repository = repository;

        public async Task<T> GetById(string id)
        {
            return await _repository.GetById(id);
        }

        public async Task<IEnumerable<T>> GetAll()
        {
            return await _repository.GetAll();
        }

        public async Task Create(T entity)
        {
            await _repository.Create(entity);
        }

        public async Task Update(string id, T entity)
        {
            await _repository.Update(id, entity);
        }

        public async Task Delete(string id)
        {
            await _repository.Delete(id);
        }
    }
}


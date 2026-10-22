using MongoDB.Driver;

namespace BillApi.Persistence.Repositories
{
    public class Repository<T>(IMongoDatabase database, string collectionName) : IRepository<T> where T : class
    {
        protected readonly IMongoCollection<T> _collection = database.GetCollection<T>(collectionName);

        public async Task<T> GetById(string id)
        {
            var filter = Builders<T>.Filter.Eq("Id", id);
            return await _collection.Find(filter).FirstOrDefaultAsync();
        }

        public async Task<IEnumerable<T>> GetAll()
        {
            return await _collection.Find(_ => true).ToListAsync();
        }

        public async Task Create(T entity)
        {
            await _collection.InsertOneAsync(entity);
        }

        public async Task Update(string id, T entity)
        {
            var filter = Builders<T>.Filter.Eq("Id", id);
            await _collection.ReplaceOneAsync(filter, entity);
        }

        public async Task Delete(string id)
        {
            var filter = Builders<T>.Filter.Eq("Id", id);
            await _collection.DeleteOneAsync(filter);
        }
    }
}


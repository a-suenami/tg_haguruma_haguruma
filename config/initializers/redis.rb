# typed: true

RedisClient.new(url: Settings.redis.url, db: 0).call('ping') if defined? Rails::Server

class RedisClient
  extend T::Sig

  sig { returns(RedisClient::Pooled) }
  def self.pool
    return @pool if @pool

    timeout = 1 # in seconds
    size = ENV.fetch('RAILS_MAX_THREADS', 10).to_i

    redis_config = RedisClient.config(url: Settings.redis.url, db: 2)
    @pool = redis_config.new_pool(timeout:, size:)
  end
end

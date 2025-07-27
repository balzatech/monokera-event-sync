require 'redis'
require 'httparty'

class CustomerCacheValidator
  include HTTParty
  base_uri ENV.fetch('CUSTOMER_SERVICE_URL', 'http://customer_service:3000')

  def initialize(customer_id)
    @customer_id = customer_id
    @redis = Redis.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"))
  end

  def valid?
    if cached_customer
      true
    else
      fetch_and_cache_customer
    end
  end

  private

  def cache_key
    "customer:#{@customer_id}"
  end

  def cached_customer
    @redis.get(cache_key)
  end

  def fetch_and_cache_customer
    response = self.class.get("/customers/#{@customer_id}")

    if response.success?
      @redis.setex(cache_key, 604800, response.body) # cache por 1 semana
      true
    else
      false
    end
  rescue => e
    Rails.logger.error("Error fetching customer: #{e.message}")
    false
  end
end

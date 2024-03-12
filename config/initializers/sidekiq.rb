unless Rails.env.production?
  Sidekiq.configure_server do |config|
    config.redis = { url: 'redis:localhost:6379/0' }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: 'redis:localhost:6379/0' }
  end
else
  redis_conf = Rails.application.credentials.redis
  redis_url = "redis://#{redis_conf[:host]}:#{redis_conf[:port]}"

  Sidekiq.configure_server do |config|
    config.redis = { url: redis_url }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: redis_url }
  end

  Rails.logger.info "connection pool: #{ActiveRecord::Base.connection_pool.size}"
end

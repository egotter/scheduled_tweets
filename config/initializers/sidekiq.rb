Sidekiq.logger.level = Logger::DEBUG

Sidekiq.configure_server do |config|
  config.redis = {url: "redis://#{ENV['REDIS_HOST']}:6379", namespace: Rails.application.class.module_parent.to_s}
end

Sidekiq.configure_client do |config|
  config.redis = {url: "redis://#{ENV['REDIS_HOST']}:6379", namespace: Rails.application.class.module_parent.to_s}
end

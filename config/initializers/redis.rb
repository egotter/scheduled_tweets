require 'redis'

class Redis
  class << self
    def instance
      new(host: ENV['REDIS_HOST'])
    end
  end
end

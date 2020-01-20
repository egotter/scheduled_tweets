require 'twitter'

class ApiClient
  delegate_missing_to :@client

  def initialize(user)
    options = {
        consumer_key: ENV['TWITTER_CONSUMER_KEY'],
        consumer_secret: ENV['TWITTER_CONSUMER_SECRET'],
        access_token: user.credential.token,
        access_token_secret: user.credential.secret
    }

    @client = Twitter::REST::Client.new(options)
  end
end

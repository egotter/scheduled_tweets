class CreateTweetWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default', retry: 3, backtrace: false

  def perform(scheduled_tweet_id, options = {})
    tweet = ScheduledTweet.find(scheduled_tweet_id)
    user = tweet.user
    client = user.api_client

    if tweet.images.any?
      tweet.images[0].open do |file|
        client.update_with_media(tweet.text, file)
      end
    else
      client.update(tweet.text)
    end
  end
end

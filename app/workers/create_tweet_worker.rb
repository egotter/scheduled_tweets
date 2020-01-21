class CreateTweetWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default', retry: 3, backtrace: false

  def perform(scheduled_tweet_id, options = {})
    tweet = ScheduledTweet.find(scheduled_tweet_id)
    return if tweet.published?

    user = tweet.user
    client = user.api_client

    if tweet.images.any?
      tweet.images[0].open do |file|
        status = client.update_with_media(tweet.text, file)
        tweet.update(tweet_id: status.id, published_at: Time.zone.now)
      end
    else
      status = client.update(tweet.text)
      tweet.update(tweet_id: status.id, published_at: Time.zone.now)
    end
  end
end

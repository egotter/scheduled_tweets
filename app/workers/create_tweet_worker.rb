class CreateTweetWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default', retry: 3, backtrace: false

  def perform(scheduled_tweet_id, options = {})
    tweet = ScheduledTweet.find(scheduled_tweet_id)
    return if tweet.published?
    return if (Time.zone.now - tweet.time).abs > 5.minutes

    tweet.publish!
  end
end

class ScheduledTweetsController < ApplicationController
  def index
    @preview_user = PreviewUser.new(user: current_user)
    @preview_tweet = ScheduledTweet.new(text: '', time: Time.zone.now)

    if user_signed_in?
      tweets = current_user.scheduled_tweets
      @scheduled_tweets = tweets.will_be_published
      @published_tweets = tweets.already_published.order(time: :desc).limit(10).reverse
      @failed_tweets = tweets.failed_to_publish.order(time: :desc).limit(10).reverse
    else
      @scheduled_tweets = ScheduledTweet.none
      @published_tweets = ScheduledTweet.none
      @failed_tweets = ScheduledTweet.none
    end
  end
end

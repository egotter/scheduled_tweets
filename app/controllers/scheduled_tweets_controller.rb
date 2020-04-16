class ScheduledTweetsController < ApplicationController
  def index
    @preview_user = PreviewUser.new(user: current_user)
    @preview_tweet = ScheduledTweet.new(text: '', time: Time.zone.now)
    @scheduled_tweets = user_signed_in? ? current_user.scheduled_tweets : ScheduledTweet.none
  end
end

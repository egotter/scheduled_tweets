class Api::V1::ScheduledTweetsController < ApiController
  before_action :authenticate_user!

  def index
    render json: current_user.scheduled_tweets
  end

  def create
    logger.warn params.inspect

    tweet = ScheduledTweet.new(
        user_id: current_user.id,
        text: params[:tweet_text],
        specified_date: params['scheduled-date'],
        specified_time: params['scheduled-time']
    )

    if tweet.save
      if params['input-image']
        tweet.images.attach(params['input-image'])
      end

      render json: tweet
    else
      render json: {error: tweet.errors.full_messages, error_attributes: tweet.errors.keys, model: tweet}, status: :unprocessable_entity
    end
  end
end

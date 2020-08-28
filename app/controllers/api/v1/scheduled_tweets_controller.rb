class Api::V1::ScheduledTweetsController < ApiController
  before_action :authenticate_user!

  rescue_from Exception do |e|
    render json: {error: e.message}, status: :internal_server_error
  end

  def index
    render json: current_user.scheduled_tweets
  end

  def create
    tweet = ScheduledTweet.new(
        user_id: current_user.id,
        text: params[:tweet_text],
        time_str: "#{params['scheduled-date']} #{params['scheduled-time']}",
        uploaded_files: params['input-images'],
        repeat_type: params[:repeat_type],
    )

    if tweet.save
      if tweet.repeat_specified?
        copied_tweets = tweet.copy_for_repeat(params['input-images'])
        ApplicationRecord.transaction { copied_tweets.each(&:save!) }
      end

      message = I18n.t('scheduled_tweets.create.message', time: tweet.time.in_time_zone('Tokyo').strftime("%Y/%m/%d %H:%M"))
      render json: {message: message}
    else
      response = {error: tweet.errors.full_messages}
      logger.warn "tweet.save failed #{response.inspect}"
      render json: response, status: :unprocessable_entity
    end
  end

  def destroy
    tweet = current_user.scheduled_tweets.will_be_published.find_by(id: params[:id]).destroy
    message = I18n.t('scheduled_tweets.destroy.message', time: tweet.time.in_time_zone('Tokyo').strftime("%Y/%m/%d %H:%M"))
    render json: {message: message}
  end
end

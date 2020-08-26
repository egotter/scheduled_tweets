class Api::V1::ScheduledTweetsController < ApiController
  before_action :authenticate_user!

  rescue_from Exception do |e|
    render json: {error: e.message}, status: :internal_server_error
  end

  def index
    render json: current_user.scheduled_tweets
  end

  def create
    if params['input-image']
      uploaded_file = UploadedFile.new(size: params['input-image'].size, content_type: params['input-image'].content_type)
      unless uploaded_file.valid?
        render json: {error: uploaded_file.errors.full_messages}, status: :unprocessable_entity
        return
      end
    end

    datetime = ScheduledTweetTime.new(date: params['scheduled-date'], time: params['scheduled-time'])
    unless datetime.valid?
      render json: {error: datetime.errors.full_messages}, status: :unprocessable_entity
      return
    end

    tweet = ScheduledTweet.new(
        user_id: current_user.id,
        text: params[:tweet_text],
        time: datetime.datetime,
        repeat_type: params['repeat_type'],
    )

    if tweet.save
      if params['input-image']
        tweet.images.attach(params['input-image'])
      end

      CreateTweetWorker.perform_at(tweet.time, tweet.id, user_id: current_user.id, text: tweet.text)
      message = I18n.t('scheduled_tweets.create.message', time: tweet.time.in_time_zone('Tokyo').strftime("%Y/%m/%d %H:%M"))
      render json: {message: message}
    else
      response = {error: tweet.errors.full_messages}
      logger.warn "tweet.save failed #{response.inspect}"
      render json: response, status: :unprocessable_entity
    end
  end

  def destroy
    tweet = ScheduledTweet.find(params[:id])
    message = I18n.t('scheduled_tweets.destroy.message', time: tweet.time.in_time_zone('Tokyo').strftime("%Y/%m/%d %H:%M"))
    render json: {message: message, record: tweet.destroy}
  end
end

class Api::V1::ScheduledTweetsController < ApiController
  before_action :authenticate_user!

  rescue_from Exception do |e|
    render json: {error: e.message}, status: :internal_server_error
  end

  def index
    render json: current_user.scheduled_tweets
  end

  def create
    logger.warn params.inspect

    if params['input-image']
      uploaded_file = UploadedFile.new(size: params['input-image'].size, content_type: params['input-image'].content_type)
      unless uploaded_file.valid?
        render json: {error: uploaded_file.errors.full_messages, error_attributes: uploaded_file.errors.keys, record: uploaded_file}, status: :unprocessable_entity
        return
      end
    end

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

      message = I18n.t('scheduled_tweets.create.message', time: tweet.time.in_time_zone('Tokyo').strftime("%Y/%m/%d %H:%M"))
      render json: {message: message, record: tweet}
    else
      render json: {error: tweet.errors.full_messages, error_attributes: tweet.errors.keys, record: tweet}, status: :unprocessable_entity
    end
  end
end

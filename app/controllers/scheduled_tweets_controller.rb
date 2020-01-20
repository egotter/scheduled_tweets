class ScheduledTweetsController < ApplicationController
  before_action :set_scheduled_tweet, only: [:show, :edit, :update, :destroy]

  # GET /scheduled_tweets
  # GET /scheduled_tweets.json
  def index
    @preview_user = PreviewUser.new(user: current_user)
    @preview_tweet = ScheduledTweet.new(text: '', time: Time.zone.now)
    @scheduled_tweets = user_signed_in? ? current_user.scheduled_tweets : ScheduledTweet.none
  end

  # GET /scheduled_tweets/1
  # GET /scheduled_tweets/1.json
  def show
  end

  # GET /scheduled_tweets/new
  def new
    @scheduled_tweet = ScheduledTweet.new
  end

  # GET /scheduled_tweets/1/edit
  def edit
  end

  # POST /scheduled_tweets
  # POST /scheduled_tweets.json
  def create
    @scheduled_tweet = ScheduledTweet.new(scheduled_tweet_params)

    respond_to do |format|
      if @scheduled_tweet.save
        format.html { redirect_to @scheduled_tweet, notice: 'Scheduled tweet was successfully created.' }
        format.json { render :show, status: :created, location: @scheduled_tweet }
      else
        format.html { render :new }
        format.json { render json: @scheduled_tweet.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /scheduled_tweets/1
  # PATCH/PUT /scheduled_tweets/1.json
  def update
    respond_to do |format|
      if @scheduled_tweet.update(scheduled_tweet_params)
        format.html { redirect_to @scheduled_tweet, notice: 'Scheduled tweet was successfully updated.' }
        format.json { render :show, status: :ok, location: @scheduled_tweet }
      else
        format.html { render :edit }
        format.json { render json: @scheduled_tweet.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /scheduled_tweets/1
  # DELETE /scheduled_tweets/1.json
  def destroy
    @scheduled_tweet.destroy
    respond_to do |format|
      format.html { redirect_to scheduled_tweets_url, notice: 'Scheduled tweet was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_scheduled_tweet
      @scheduled_tweet = ScheduledTweet.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def scheduled_tweet_params
      params.require(:scheduled_tweet).permit(:uid, :text, :properties)
    end
end
